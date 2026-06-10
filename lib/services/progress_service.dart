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

  // ── Schema version ─────────────────────────────────────────────
  static const _schemaVersionKey = 'schema_version';
  static const _currentSchemaVersion = 1;

  // ── New keys ───────────────────────────────────────────────────
  static const _streakKey = 'current_streak';
  static const _longestStreakKey = 'longest_streak';
  static const _streakFreezesKey = 'streak_freezes';
  static const _daily5DateKey = 'daily5_date';
  static const _weekStartDateKey = 'week_start_date';
  static const _weekStartStarsKey = 'week_start_stars';
  static const _weekStartChallengesKey = 'week_start_challenges';
  static const _weekStartColoringKey = 'week_start_coloring';
  static const _lastLoginDateKey = 'last_login_date';
  static const _questDateKey = 'quest_date';
  static const _questProgressKey = 'quest_progress';

  // ── State ──────────────────────────────────────────────────────
  SharedPreferences? _preferences;

  /// Safe accessor — throws [StateError] if [load()] has not been called yet.
  SharedPreferences get _prefs {
    assert(
      _preferences != null,
      'ProgressService.load() must be called before mutating state',
    );
    if (_preferences == null) throw StateError('ProgressService not initialised');
    return _preferences!;
  }

  int _stars = 0;
  int _completedChallenges = 0;
  final Map<ChallengeMode, int> _completedByMode = {
    for (final mode in ChallengeMode.values) mode: 0,
  };
  final Set<String> _badgeIds = {};
  bool _backgroundMusicEnabled = false;
  bool _soundEnabled = true;
  bool _voiceEnabled = true;
  // Malaysian-first: BM is the default for new installs (Settings can change it).
  AppLanguage _language = AppLanguage.malay;

  final Map<String, int> _moduleLessons = {};
  final Map<String, Set<String>> _moduleSeenLessons = {};
  final Map<String, String> _lastLesson = {};
  int _coloringSessions = 0;

  // ── Gamification state ─────────────────────────────────────────
  int _currentStreak = 0;
  int _longestStreak = 0;
  String _lastLoginDate = '';
  bool _shouldShowDailyReward = false;

  /// Streak-freeze tokens: earned every 7 consecutive days (max 2 held),
  /// spent automatically when the child misses exactly one day so the streak
  /// survives. Silent brutal streak resets are the top churn moment.
  int _streakFreezes = 0;
  bool _streakFreezeJustUsed = false;

  /// Date (yyyy-mm-dd) the Math "Daily 5" bonus was last claimed.
  String _daily5Date = '';

  /// Weekly snapshot (taken each Monday) so the parent recap can show
  /// this-week deltas without storing a full history.
  String _weekStartDate = '';
  int _weekStartStars = 0;
  int _weekStartChallenges = 0;
  int _weekStartColoring = 0;
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

  /// Whether [lessonLabel] has already been seen (and therefore already
  /// awarded its star). Lets screens detect "first time" moments — e.g. the
  /// Numbers band-completion bonus — without double-awarding.
  bool hasSeenLesson(String moduleId, String lessonLabel) =>
      _moduleSeenLessons[moduleId]?.contains(lessonLabel) ?? false;

  // ── Getters: new ──────────────────────────────────────────────
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  bool get shouldShowDailyReward => _shouldShowDailyReward;
  int get streakFreezes => _streakFreezes;

  /// True when today's login was rescued by a freeze token (session-local;
  /// the daily-reward dialog uses it to announce the save).
  bool get streakFreezeJustUsed => _streakFreezeJustUsed;

  /// Whether today's Math "Daily 5" bonus has already been claimed.
  bool get isDaily5DoneToday => _daily5Date == _todayString();

  // ── Mystery game of the day ───────────────────────────────────
  /// One playable game pays double stars each day (date-seeded, rotates
  /// through the hub's five games). Nudges play-pattern variety.
  ChallengeMode get mysteryGameToday {
    const pool = [
      ChallengeMode.numberTrain,
      ChallengeMode.letterTrain,
      ChallengeMode.memory,
      ChallengeMode.puzzle,
      ChallengeMode.findExplorer,
    ];
    final day = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    return pool[day % pool.length];
  }

  // ── Weekly recap (parent-facing) ──────────────────────────────
  int get starsThisWeek => (_stars - _weekStartStars).clamp(0, 1 << 31);
  int get gamesThisWeek =>
      (_completedChallenges - _weekStartChallenges).clamp(0, 1 << 31);
  int get coloringThisWeek =>
      (_coloringSessions - _weekStartColoring).clamp(0, 1 << 31);

  /// Claims the once-per-day Math "Daily 5" bonus (+5 ⭐). Returns the stars
  /// awarded (0 if already claimed today).
  Future<int> claimDaily5Bonus() async {
    if (isDaily5DoneToday) return 0;
    _daily5Date = _todayString();
    await _preferences?.setString(_daily5DateKey, _daily5Date);
    await addStars(5);
    return 5;
  }

  AppLevel get currentLevel => levelForStars(_stars);

  int get dailyRewardStars => _rewardForStreak(_currentStreak);

  /// What tomorrow pays if the streak continues — shown on the daily-reward
  /// dialog so the escalating table actually motivates a return visit.
  int get tomorrowRewardStars => _rewardForStreak(_currentStreak + 1);

  static int _rewardForStreak(int streak) {
    if (streak <= 2) return 2;
    if (streak <= 6) return 3;
    if (streak <= 13) return 5;
    if (streak <= 29) return 7;
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

    // ── Schema migration ───────────────────────────────────────
    final storedVersion = prefs.getInt(_schemaVersionKey) ?? 0;
    if (storedVersion < _currentSchemaVersion) {
      await _migrate(prefs, from: storedVersion);
      await prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
    }

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
    _streakFreezes = prefs.getInt(_streakFreezesKey) ?? 0;
    _daily5Date = prefs.getString(_daily5DateKey) ?? '';
    _weekStartDate = prefs.getString(_weekStartDateKey) ?? '';
    _weekStartStars = prefs.getInt(_weekStartStarsKey) ?? 0;
    _weekStartChallenges = prefs.getInt(_weekStartChallengesKey) ?? 0;
    _weekStartColoring = prefs.getInt(_weekStartColoringKey) ?? 0;

    final savedQuestDate = prefs.getString(_questDateKey) ?? '';
    final savedProgress = prefs.getStringList(_questProgressKey);
    if (savedProgress != null && savedProgress.length == 3) {
      try {
        _questProgress = savedProgress.map(int.parse).toList();
      } catch (e) {
        debugPrint('[ProgressService] Quest progress parse failed — resetting to [0,0,0]. Error: $e');
        _questProgress = [0, 0, 0];
      }
    }
    _questDate = savedQuestDate;

    await _checkStreak();
    await _checkWeek();
    _checkAllBadges(); // Award any badges earned from previous sessions
    notifyListeners();
  }

  // ── markModuleLesson ─────────────────────────────────────────
  Future<void> markModuleLesson(String moduleId, String lessonLabel) async {
    final prefs = _prefs;
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
    // Tolerate being called before load() so an early coloring session is
    // never lost to initialisation ordering.
    if (_preferences == null) await load();
    final prefs = _prefs;
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
  /// [stars] lets harder variants pay more (e.g. 4×4 puzzle = 2 ⭐, hard
  /// memory boards = 3 ⭐) so difficulty is worth choosing.
  Future<FinderBadge?> completeChallenge(
    ChallengeMode mode, {
    int stars = 1,
  }) async {
    final oldLevel = currentLevel;
    // Mystery game of the day pays double.
    final effectiveStars =
        mode == mysteryGameToday ? stars.clamp(1, 5) * 2 : stars.clamp(1, 5);
    _stars += effectiveStars;
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
    _streakFreezes = 0;
    _streakFreezeJustUsed = false;
    _daily5Date = '';
    _weekStartDate = '';
    _weekStartStars = 0;
    _weekStartChallenges = 0;
    _weekStartColoring = 0;
    _questProgress = [0, 0, 0];
    _questDate = '';
    _pendingLevelUp = null;
    _pendingBadges.clear();
    for (final mode in ChallengeMode.values) {
      _completedByMode[mode] = 0;
    }

    await _save();
    final prefs = _prefs;
    for (final key in _trackedModules) {
      await prefs.remove('$_modulePrefix$key');
      await prefs.remove('$_moduleSeenPrefix$key');
      await prefs.remove('$_lastLessonPrefix$key');
    }
    await prefs.remove(_streakKey);
    await prefs.remove(_longestStreakKey);
    await prefs.remove(_lastLoginDateKey);
    await prefs.remove(_streakFreezesKey);
    await prefs.remove(_daily5DateKey);
    await prefs.remove(_weekStartDateKey);
    await prefs.remove(_weekStartStarsKey);
    await prefs.remove(_weekStartChallengesKey);
    await prefs.remove(_weekStartColoringKey);
    await prefs.remove(_questDateKey);
    await prefs.remove(_questProgressKey);
    notifyListeners();
  }

  bool hasBadge(String badgeId) => _badgeIds.contains(badgeId);
  int countFor(ChallengeMode mode) => _completedByMode[mode] ?? 0;

  // ── Private helpers ───────────────────────────────────────────

  /// Runs all pending schema migrations in order.
  ///
  /// To add a future migration:
  ///   if (from < 2) { /* v1→v2 changes */ }
  Future<void> _migrate(SharedPreferences prefs, {required int from}) async {
    // v0 → v1: No structural key changes needed. The schema version key itself
    // is now written by load() after this method returns.
    // TODO: Add further migrations below as the schema evolves.
    debugPrint('[ProgressService] Migrated schema v$from → v$_currentSchemaVersion');
  }

  Future<void> _checkStreak() async {
    final today = _todayString();
    if (_lastLoginDate == today) return;

    final yesterday = _yesterdayString();
    if (_lastLoginDate == yesterday) {
      _currentStreak++;
      _maybeEarnFreeze();
    } else if (_lastLoginDate.isNotEmpty &&
        _lastLoginDate == _daysAgoString(2) &&
        _streakFreezes > 0) {
      // Missed exactly one day with a freeze token in hand: spend it and
      // keep the streak alive instead of resetting to 1.
      _streakFreezes--;
      _streakFreezeJustUsed = true;
      _currentStreak++;
      _maybeEarnFreeze();
    } else {
      _currentStreak = 1;
    }
    if (_currentStreak > _longestStreak) _longestStreak = _currentStreak;
    _lastLoginDate = today;
    _shouldShowDailyReward = true;

    final prefs = _preferences;
    if (prefs != null) {
      await prefs.setInt(_streakKey, _currentStreak);
      await prefs.setInt(_longestStreakKey, _longestStreak);
      await prefs.setString(_lastLoginDateKey, _lastLoginDate);
      await prefs.setInt(_streakFreezesKey, _streakFreezes);
    }
  }

  /// Snapshots counters at the start of each ISO week (Monday) so the parent
  /// recap can show this-week deltas.
  Future<void> _checkWeek() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayString =
        '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
    if (_weekStartDate == mondayString) return;
    _weekStartDate = mondayString;
    _weekStartStars = _stars;
    _weekStartChallenges = _completedChallenges;
    _weekStartColoring = _coloringSessions;
    final prefs = _preferences;
    if (prefs != null) {
      await prefs.setString(_weekStartDateKey, _weekStartDate);
      await prefs.setInt(_weekStartStarsKey, _weekStartStars);
      await prefs.setInt(_weekStartChallengesKey, _weekStartChallenges);
      await prefs.setInt(_weekStartColoringKey, _weekStartColoring);
    }
  }

  /// Every 7th consecutive day grants a freeze token, capped at 2 held.
  void _maybeEarnFreeze() {
    if (_currentStreak > 0 && _currentStreak % 7 == 0 && _streakFreezes < 2) {
      _streakFreezes++;
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

  String _yesterdayString() => _daysAgoString(1);

  String _daysAgoString(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveQuestProgress() async {
    final prefs = _prefs;
    await prefs.setString(_questDateKey, _questDate);
    await prefs.setStringList(
      _questProgressKey,
      _questProgress.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _save() async {
    final prefs = _prefs;
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
