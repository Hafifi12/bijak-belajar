import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/app_language.dart';

/// Central audio service.
///
/// TTS is handled by [flutter_tts] (offline, zero LLM calls).
/// Sound effects fall back to [SystemSound] if no native effect channel is
/// available — safe for offline use.
class AudioService {
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  String _currentLocale = '';

  // ── TTS initialisation ────────────────────────────────────────────────

  Future<void> _ensureReady() async {
    if (_ttsReady) return;
    _ttsReady = true;
    await _tts.setSpeechRate(0.45);   // slightly slow — easier for young kids
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.2);         // slightly higher — friendlier feel
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> _setLocale(String locale) async {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    await _tts.setLanguage(locale);
  }

  // ── Public API (unchanged from previous MethodChannel version) ────────

  /// Speak [message] in the app's selected [language].
  Future<void> speak(
    String message, {
    required bool enabled,
    required AppLanguage language,
  }) async {
    if (!enabled) return;
    await speakLocale(message, enabled: enabled, locale: language.ttsLocale);
  }

  /// Speak [message] with an explicit BCP-47 [locale] tag (e.g. 'ar-SA').
  Future<void> speakLocale(
    String message, {
    required bool enabled,
    required String locale,
  }) async {
    final trimmed = message.trim();
    if (!enabled || trimmed.isEmpty) return;
    try {
      await _ensureReady();
      await _setLocale(locale);
      await _tts.speak(trimmed);
    } catch (_) {
      // TTS unavailable on this device/simulator — fail silently.
    }
  }

  /// Play a pre-recorded pronunciation asset or fall back to TTS.
  Future<void> playOfflinePronunciation({
    required String assetPath,
    required bool enabled,
    required String fallbackText,
    required String locale,
  }) async {
    if (!enabled) return;
    // Asset-based playback is deferred to a future release.
    // For now, always speak via TTS — identical user experience.
    await speakLocale(fallbackText, enabled: enabled, locale: locale);
  }

  /// Play a short celebration sound.
  Future<void> playCelebration({required bool enabled}) async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.alert);
  }

  /// Play a named UI effect ('correct' or 'wrong').
  Future<void> playEffect(String name, {required bool enabled}) async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  /// Stop any in-progress speech and release TTS resources.
  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore disposal errors.
    }
  }
}
