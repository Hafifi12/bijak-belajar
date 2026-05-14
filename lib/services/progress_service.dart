import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/badge_data.dart';
import '../models/app_language.dart';
import '../models/badge.dart';
import '../models/challenge.dart';
import '../models/progress.dart';

class ProgressService extends ChangeNotifier {
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

  // ── Module lesson tracking ─────────────────────────────────────
  final Map<String, int> _moduleLessons = {};
  final Map<String, Set<String>> _moduleSeenLessons = {};
  final Map<String, String> _lastLesson = {};
  int _coloringSessions = 0;

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

    // Load per-module lesson counts
    for (final key in _trackedModules) {
      final seenLessons = (prefs.getStringList('$_moduleSeenPrefix$key') ?? [])
          .toSet();
      _moduleSeenLessons[key] = seenLessons;
      _moduleLessons[key] = seenLessons.isNotEmpty
          ? seenLessons.length
          : prefs.getInt('$_modulePrefix$key') ?? 0;
      _lastLesson[key] = prefs.getString('$_lastLessonPrefix$key') ?? '';
    }

    notifyListeners();
  }

  /// Call when a child views/completes a lesson in a module.
  Future<void> markModuleLesson(String moduleId, String lessonLabel) async {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    final seenLessons = _moduleSeenLessons.putIfAbsent(moduleId, () => {});
    final isNewLesson = seenLessons.add(lessonLabel);
    if (isNewLesson) {
      _moduleLessons[moduleId] = seenLessons.length;
      _stars += 1;
      await prefs.setStringList(
        '$_moduleSeenPrefix$moduleId',
        seenLessons.toList()..sort(),
      );
      await prefs.setInt('$_modulePrefix$moduleId', seenLessons.length);
      await prefs.setInt(_starsKey, _stars);
    }
    _lastLesson[moduleId] = lessonLabel;
    await prefs.setString('$_lastLessonPrefix$moduleId', lessonLabel);
    notifyListeners();
  }

  Future<void> incrementColoringSessions() async {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    _coloringSessions++;
    await prefs.setInt(_coloringSessionsKey, _coloringSessions);
    notifyListeners();
  }

  Future<void> addStars(int amount) async {
    if (amount <= 0) return;
    _stars += amount;
    await _save();
    notifyListeners();
  }

  Future<FinderBadge?> completeChallenge(ChallengeMode mode) async {
    _stars += 1;
    _completedChallenges += 1;
    _completedByMode[mode] = (_completedByMode[mode] ?? 0) + 1;

    final newBadge = _nextEarnedBadge();
    if (newBadge != null) {
      _badgeIds.add(newBadge.id);
    }

    await _save();
    notifyListeners();
    return newBadge;
  }

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

  Future<void> resetProgress() async {
    _stars = 0;
    _completedChallenges = 0;
    _badgeIds.clear();
    _moduleLessons.clear();
    _moduleSeenLessons.clear();
    _lastLesson.clear();
    _coloringSessions = 0;
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
    notifyListeners();
  }

  bool hasBadge(String badgeId) => _badgeIds.contains(badgeId);

  int countFor(ChallengeMode mode) => _completedByMode[mode] ?? 0;

  FinderBadge? _nextEarnedBadge() {
    for (final badge in badges) {
      if (_completedChallenges >= badge.requiredChallenges &&
          !_badgeIds.contains(badge.id)) {
        return badge;
      }
    }
    return null;
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
