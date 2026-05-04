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
  static const _soundEnabledKey = 'sound_enabled';
  static const _voiceEnabledKey = 'voice_enabled';
  static const _languageKey = 'language';
  static const _modePrefix = 'completed_mode_';

  SharedPreferences? _preferences;
  int _stars = 0;
  int _completedChallenges = 0;
  final Map<ChallengeMode, int> _completedByMode = {
    for (final mode in ChallengeMode.values) mode: 0,
  };
  final Set<String> _badgeIds = {};
  bool _soundEnabled = true;
  bool _voiceEnabled = true;
  AppLanguage _language = AppLanguage.english;

  int get stars => _stars;
  int get completedChallenges => _completedChallenges;
  Set<String> get badgeIds => Set.unmodifiable(_badgeIds);
  bool get soundEnabled => _soundEnabled;
  bool get voiceEnabled => _voiceEnabled;
  AppLanguage get language => _language;

  ProgressSnapshot get snapshot => ProgressSnapshot(
    stars: _stars,
    completedChallenges: _completedChallenges,
    completedByMode: Map.unmodifiable(_completedByMode),
    badgeIds: Set.unmodifiable(_badgeIds),
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
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _voiceEnabled = prefs.getBool(_voiceEnabledKey) ?? true;
    _language = AppLanguageDetails.fromCode(prefs.getString(_languageKey));

    for (final mode in ChallengeMode.values) {
      _completedByMode[mode] =
          prefs.getInt('$_modePrefix${mode.storageKey}') ?? 0;
    }

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
    for (final mode in ChallengeMode.values) {
      _completedByMode[mode] = 0;
    }

    await _save();
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
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
    await prefs.setBool(_voiceEnabledKey, _voiceEnabled);
    await prefs.setString(_languageKey, _language.code);

    for (final mode in ChallengeMode.values) {
      await prefs.setInt(
        '$_modePrefix${mode.storageKey}',
        _completedByMode[mode] ?? 0,
      );
    }
  }
}
