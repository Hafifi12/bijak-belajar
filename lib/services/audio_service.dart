import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/app_language.dart';

/// Central audio service.
///
/// TTS is handled by the flutter_tts package (offline, zero LLM calls).
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
    await _tts.setSpeechRate(0.45); // slightly slow — easier for young kids
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.2); // slightly higher — friendlier feel
    await _tts.awaitSpeakCompletion(true);
  }

  /// Chosen on-device voice per locale. `null` value = searched, none found
  /// (let the engine use its own mapping).
  final Map<String, Map<String, String>?> _voiceCache = {};

  Future<void> _setLocale(String locale) async {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    await _tts.setLanguage(locale);

    // setLanguage alone silently falls back to the system default voice
    // (usually English) when the requested language has no active voice —
    // which is how Malay words ended up spoken with an English accent.
    // Explicitly pick the best installed voice for this locale.
    final voice = await _pickVoice(locale);
    if (voice != null) {
      await _tts.setVoice(voice);
    }
  }

  /// Best installed voice for [locale]: exact locale match first, then same
  /// language, then (for Malay only) an Indonesian voice — which pronounces
  /// Bahasa Melayu far better than any English fallback.
  Future<Map<String, String>?> _pickVoice(String locale) async {
    if (_voiceCache.containsKey(locale)) return _voiceCache[locale];

    Map<String, String>? result;
    try {
      final raw = await _tts.getVoices;
      final voices = <Map<String, String>>[
        if (raw is List)
          for (final v in raw)
            if (v is Map && v['name'] != null && v['locale'] != null)
              {'name': '${v['name']}', 'locale': '${v['locale']}'},
      ];

      String norm(String s) => s.toLowerCase().replaceAll('_', '-');
      final want = norm(locale); // e.g. ms-my
      final wantLang = want.split('-').first; // e.g. ms

      Map<String, String>? firstWhereLocale(bool Function(String) test) {
        for (final v in voices) {
          if (test(norm(v['locale']!))) return v;
        }
        return null;
      }

      result =
          firstWhereLocale((l) => l == want) ??
          firstWhereLocale((l) => l.split('-').first == wantLang);

      // Malay-specific rescue: an Indonesian voice over an English default.
      if (result == null && wantLang == 'ms') {
        result = firstWhereLocale((l) => l.split('-').first == 'id');
      }
    } catch (_) {
      result = null; // voice listing unsupported — engine mapping it is
    }

    _voiceCache[locale] = result;
    return result;
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

  // REMOVED: playOfflinePronunciation — replaced with speakLocale at all call sites.
  // Use speakLocale(text, enabled: enabled, locale: locale) directly.

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
