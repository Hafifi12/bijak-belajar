import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/badge_data.dart';
import '../models/app_language.dart';
import '../models/badge.dart';
import '../models/challenge.dart';
import '../models/level.dart';
import '../models/progress.dart';
import '../models/quest.dart';

class ProgressService extends ChangeNotifier {
  // ── Existing keys ──────────────────────────────────────────────
  static const _starsKey = 'stars';
  static const _completedKey = 'completed_challenges';
  static const _badgesKey = 'badges';
  static const _backgroundMusicEnabledKey = 'background_music_enabled';
  static const _soundEnabledKey = 'sound_enabled';
  static const _voiceEnabledKey = 'voice_enabled';
  static const _languageKey = 'language';
  static const _modePrefix = 'completed_mode_';
  static const _modulePrefix = 'module_lessons_';
  static const _moduleSeenPrefix = 'module_seen_lessons_';
  static const _lastLessonPrefix = 'last_lesson_';
  static const _coloringSessionsKey = 'coloring_sessions';
  static const _trackedModules = [
    'numbers',
    'letters',
    'jawi',
    'bodyparts',
    'math',
  ];

  // ── New keys ───────────────────────────────────────────────────
  static const _streakKey = 'current_streak';
  static const _longestStreakKey = 'longest_streak';
  static const _lastLoginDateKey = 'last_login_date';
  static const _questDateKey = 'quest_date';
  static const _questProgressKey = 'quest_progress';

  // ── State ──────────────────────────────────────────────────────
  SharedPreferences? _preferences;

  int _stars = 0;
  int _completedChallenges = 0;
  final Map<ChallengeMode, int> _completedByMode = {
    for (final mode in ChallengeMode.values) mode: 0,
  };
  final Set<String> _badgeIds = {};
  bool _backgroundMusicEnabled = false;
  bool _soundEnabled = true;
  bool _voiceEnabled = true;
  AppLanguage _language = AppLanguage.english;

  final Map<String, int> _moduleLessons = {};
  final Map<String, Set<String>> _moduleSeenLessons = {};
  final Map<String, String> _lastLesson = {};
  int _coloringSessions = 0;

  // ── Gamification state ─────────────────────────────────────────
  int _currentStreak = 0;
  int _longestStreak = 0;
  String _lastLoginDate = '';
  bool _shouldShowDailyReward = false;
  AppLevel? _pendingLevelUp;
  final List<FinderBadge> _pendingBadges = [];
  List<int> _questProgress = [0, 0, 0];
  String _questDate = '';

  // ── Getters: existing ─────────────────────────────────────────
  int get stars => _stars;
  int get completedChallenges => _completedChallenges;
  Set<String> get badgeIds => Set.unmodifiable(_badgeIds);
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get voiceEnabled => _voiceEnabled;
  AppLanguage get language => _language;
  int get coloringSessions => _coloringSessions;

  int getModuleLessons(String moduleId) => _moduleLessons[moduleId] ?? 0;
  String getLastLesson(String moduleId) => _lastLesson[moduleId] ?? '';

  // ── Getters: new ──────────────────────────────────────────────
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  bool get shouldShowDailyReward => _shouldShowDailyReward;

  AppLevel get currentLevel => levelForStars(_stars);

  int get dailyRewardStars {
    if (_currentStreak <= 2) return 2;
    if (_currentStreak <= 6) return 3;
    if (_currentStreak <= 13) return 5;
    if (_currentStreak <= 29) return 7;
    return 10;
  }

  List<int> get questProgress {
    _ensureQuestDateCurrent();
    return List.unmodifiable(_questProgress);
  }

  ProgressSnapshot get snapshot => ProgressSnapshot(
    stars: _stars,
    completedChallenges: _completedChallenges,
    completedByMode: Map.unmodifiable(_completedByMode),
    badgeIds: Set.unmodifiable(_badgeIds),
    backgroundMusicEnabled: _backgroundMusicEnabled,
    soundEnabled: _soundEnabled,
    voiceEnabled: _voiceEnabled,
    language: _language,
  );

  // ── Consume flags (one-shot read + clear) ────────────────────
  bool consumeDailyRewardFlag() {
    if (!_shouldShowDailyReward) return false;
    _shouldShowDailyReward = false;
    return true;
  }

  AppLevel? consumeLevelUp() {
    final l = _pendingLevelUp;
    _pendingLevelUp = null;
    return l;
  }

  /// One-shot read of badges unlocked since the last consume. Clears the queue.
  List<FinderBadge> consumePendingBadges() {
    if (_pendingBadges.isEmpty) return const [];
    final badges = List<FinderBadge>.from(_pendingBadges);
    _pendingBadges.clear();
    return badges;
  }

  // ── Load ─────────────────────────────────────────────────────
  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    final prefs = _preferences!;

    _stars = prefs.getInt(_starsKey) ?? 0;
    _completedChallenges = prefs.getInt(_completedKey) ?? 0;
    _badgeIds
      ..clear()
      ..addAll(prefs.getStringList(_badgesKey) ?? const []);
    _backgroundMusicEnabled =
        prefs.getBool(_backgroundMusicEnabledKey) ?? false;
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _voiceEnabled = prefs.getBool(_voiceEnabledKey) ?? true;
    _language = AppLanguageDetails.fromCode(prefs.getString(_languageKey));
    _coloringSessions = prefs.getInt(_coloringSessionsKey) ?? 0;

    for (final mode in ChallengeMode.values) {
      _completedByMode[mode] =
          prefs.getInt('$_modePrefix${mode.storageKey}') ?? 0;
    }

    for (final key in _trackedModules) {
      final seenLessons = (prefs.getStringList('$_moduleSeenPrefix$key') ?? [])
          .toSet();
      _moduleSeenLessons[key] = seenLessons;
      _moduleLessons[key] = seenLessons.isNotEmpty
          ? seenLessons.length
          : prefs.getInt('$_modulePrefix$key') ?? 0;
      _lastLesson[key] = prefs.getString('$_lastLessonPrefix$key') ?? '';
    }

    // ── Gamification ─────────────────────────────────────────
    _currentStreak = prefs.getInt(_streakKey) ?? 0;
    _longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    _lastLoginDate = prefs.getString(_lastLoginDateKey) ?? '';

    final savedQuestDate = prefs.getString(_questDateKey) ?? '';
    final savedProgress = prefs.getStringList(_questProgressKey);
    if (savedProgress != null && savedProgress.length == 3) {
      _questProgress = savedProgress.map(int.parse).toList();
    }
    _questDate = savedQuestDate;

    _checkStreak();
    _checkAllBadges(); // Award any badges earned from previous sessions
    notifyListeners();
  }

  // ── markModuleLesson ─────────────────────────────────────────
  Future<void> markModuleLesson(String moduleId, String lessonLabel) async {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    final seenLessons = _moduleSeenLessons.putIfAbsent(moduleId, () => {});
    final isNewLesson = seenLessons.add(lessonLabel);
    if (isNewLesson) {
      final oldLevel = currentLevel;
      _moduleLessons[moduleId] = seenLessons.length;
      _stars += 1;
      _checkLevelUp(oldLevel);

      await prefs.setStringList(
        '$_moduleSeenPrefix$moduleId',
        seenLessons.toList()..sort(),
      );
      await prefs.setInt('$_modulePrefix$moduleId', seenLessons.length);

      _updateQuestProgress(QuestType.completeLesson);
      final moduleType = _moduleToQuestType(moduleId);
      if (moduleType != null) _updateQuestProgress(moduleType);
      _checkAllBadges();
      // Persist AFTER quest bonuses and badge checks so the extra stars and
      // newly earned badges are not lost on the next launch.
      await prefs.setInt(_starsKey, _stars);
      await prefs.setStringList(_badgesKey, _badgeIds.toList());
      await _saveQuestProgress();
    }
    _lastLesson[moduleId] = lessonLabel;
    await prefs.setString('$_lastLessonPrefix$moduleId', lessonLabel);
    notifyListeners();
  }

  // ── incrementColoringSessions ─────────────────────────────────
  Future<void> incrementColoringSessions() async {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    _coloringSessions++;
    await prefs.setInt(_coloringSessionsKey, _coloringSessions);
    _updateQuestProgress(QuestType.doColoring);
    _checkAllBadges();
    // Persist quest-bonus stars and any newly earned badges.
    await prefs.setInt(_starsKey, _stars);
    await prefs.setStringList(_badgesKey, _badgeIds.toList());
    await _saveQuestProgress();
    notifyListeners();
  }

  // ── addStars ──────────────────────────────────────────────────
  Future<void> addStars(int amount) async {
    if (amount <= 0) return;
    final oldLevel = currentLevel;
    _stars += amount;
    _checkLevelUp(oldLevel);
    _checkAllBadges();
    await _save();
    notifyListeners();
  }

  // ── completeChallenge ─────────────────────────────────────────
  Future<FinderBadge?> completeChallenge(ChallengeMode mode) async {
    final oldLevel = currentLevel;
    _stars += 1;
    _completedChallenges += 1;
    _completedByMode[mode] = (_completedByMode[mode] ?? 0) + 1;

    _checkLevelUp(oldLevel);

    _updateQuestProgress(QuestType.playGame);
    if (mode == ChallengeMode.memory) _updateQuestProgress(QuestType.playMemory);

    final newBadges = _checkAllBadges();
    await _save();
    await _saveQuestProgress();
    notifyListeners();
    return newBadges.isNotEmpty ? newBadges.first : null;
  }

  // ── Daily reward collect ──────────────────────────────────────
  Future<void> collectDailyReward() async {
    await addStars(dailyRewardStars);
  }

  // ── Settings ──────────────────────────────────────────────────
  Future<void> setBackgroundMusicEnabled(bool value) async {
    _backgroundMusicEnabled = value;
    await _preferences?.setBool(_backgroundMusicEnabledKey, value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _preferences?.setBool(_soundEnabledKey, value);
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool value) async {
    _voiceEnabled = value;
    await _preferences?.setBool(_voiceEnabledKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    await _preferences?.setString(_languageKey, language.code);
    notifyListeners();
  }

  // ── Reset ─────────────────────────────────────────────────────
  Future<void> resetProgress() async {
    _stars = 0;
    _completedChallenges = 0;
    _badgeIds.clear();
    _moduleLessons.clear();
    _moduleSeenLessons.clear();
    _lastLesson.clear();
    _coloringSessions = 0;
    _currentStreak = 0;
    _longestStreak = 0;
    _lastLoginDate = '';
    _questProgress = [0, 0, 0];
    _questDate = '';
    _pendingLevelUp = null;
    _pendingBadges.clear();
    for (final mode in ChallengeMode.values) {
      _completedByMode[mode] = 0;
    }

    await _save();
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    for (final key in _trackedModules) {
      await prefs.remove('$_modulePrefix$key');
      await prefs.remove('$_moduleSeenPrefix$key');
      await prefs.remove('$_lastLessonPrefix$key');
    }
    await prefs.remove(_streakKey);
    await prefs.remove(_longestStreakKey);
    await prefs.remove(_lastLoginDateKey);
    await prefs.remove(_questDateKey);
    await prefs.remove(_questProgressKey);
    notifyListeners();
  }

  bool hasBadge(String badgeId) => _badgeIds.contains(badgeId);
  int countFor(ChallengeMode mode) => _completedByMode[mode] ?? 0;

  // ── Private helpers ───────────────────────────────────────────

  void _checkStreak() {
    final today = _todayString();
    if (_lastLoginDate == today) return;

    final yesterday = _yesterdayString();
    if (_lastLoginDate == yesterday) {
      _currentStreak++;
    } else {
      _currentStreak = 1;
    }
    if (_currentStreak > _longestStreak) _longestStreak = _currentStreak;
    _lastLoginDate = today;
    _shouldShowDailyReward = true;

    final prefs = _preferences;
    if (prefs != null) {
      prefs.setInt(_streakKey, _currentStreak);
      prefs.setInt(_longestStreakKey, _longestStreak);
      prefs.setString(_lastLoginDateKey, _lastLoginDate);
    }
  }

  void _checkLevelUp(AppLevel oldLevel) {
    final newLevel = currentLevel;
    if (newLevel.level > oldLevel.level) {
      _pendingLevelUp = newLevel;
    }
  }

  List<FinderBadge> _checkAllBadges() {
    final earned = <FinderBadge>[];
    for (final badge in badges) {
      if (_badgeIds.contains(badge.id)) continue;
      if (_isBadgeEarned(badge)) {
        _badgeIds.add(badge.id);
        earned.add(badge);
        _pendingBadges.add(badge);
      }
    }
    return earned;
  }

  bool _isBadgeEarned(FinderBadge badge) {
    switch (badge.condition) {
      case BadgeCondition.completedChallenges:
        return _completedChallenges >= badge.requiredCount;
      case BadgeCondition.totalStars:
        return _stars >= badge.requiredCount;
      case BadgeCondition.streak:
        return _currentStreak >= badge.requiredCount;
      case BadgeCondition.level:
        return currentLevel.level >= badge.requiredCount;
      case BadgeCondition.moduleComplete:
        final done = _moduleLessons[badge.moduleId ?? ''] ?? 0;
        return done >= badge.requiredCount;
    }
  }

  void _ensureQuestDateCurrent() {
    final today = _todayString();
    if (_questDate != today) {
      _questProgress = [0, 0, 0];
      _questDate = today;
    }
  }

  void _updateQuestProgress(QuestType type) {
    _ensureQuestDateCurrent();
    final quests = todayQuests();
    for (int i = 0; i < quests.length; i++) {
      final q = quests[i];
      if (q.type == type && _questProgress[i] < q.requiredCount) {
        _questProgress[i] = min(_questProgress[i] + 1, q.requiredCount);
        if (_questProgress[i] >= q.requiredCount) {
          // Quest completed — bonus stars added silently
          _stars += q.rewardStars;
        }
      }
    }
  }

  QuestType? _moduleToQuestType(String moduleId) {
    switch (moduleId) {
      case 'numbers': return QuestType.learnNumbers;
      case 'letters': return QuestType.learnLetters;
      case 'jawi': return QuestType.learnJawi;
      case 'bodyparts': return QuestType.learnBodyParts;
      case 'math': return QuestType.doMath;
      default: return null;
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveQuestProgress() async {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    await prefs.setString(_questDateKey, _questDate);
    await prefs.setStringList(
      _questProgressKey,
      _questProgress.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _save() async {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    await prefs.setInt(_starsKey, _stars);
    await prefs.setInt(_completedKey, _completedChallenges);
    await prefs.setStringList(_badgesKey, _badgeIds.toList());
    await prefs.setBool(_backgroundMusicEnabledKey, _backgroundMusicEnabled);
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
    await prefs.setBool(_voiceEnabledKey, _voiceEnabled);
    await prefs.setString(_languageKey, _language.code);
    await prefs.setInt(_coloringSessionsKey, _coloringSessions);
    await prefs.setInt(_streakKey, _currentStreak);
    await prefs.setInt(_longestStreakKey, _longestStreak);
    await prefs.setString(_lastLoginDateKey, _lastLoginDate);

    for (final mode in ChallengeMode.values) {
      await prefs.setInt(
        '$_modePrefix${mode.storageKey}',
        _completedByMode[mode] ?? 0,
      );
    }

    for (final entry in _moduleLessons.entries) {
      await prefs.setInt('$_modulePrefix${entry.key}', entry.value);
    }
    for (final entry in _moduleSeenLessons.entries) {
      await prefs.setStringList(
        '$_moduleSeenPrefix${entry.key}',
        entry.value.toList()..sort(),
      );
    }
    for (final entry in _lastLesson.entries) {
      await prefs.setString('$_lastLessonPrefix${entry.key}', entry.value);
    }
  }
}
