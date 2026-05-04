import 'package:flutter/services.dart';

import '../models/app_language.dart';

class AudioService {
  const AudioService();

  static const _ttsChannel = MethodChannel('tiny_finder/tts');

  Future<void> playCelebration({required bool enabled}) async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.alert);
  }

  /// Play a short UI sound — 'correct' (clap/chime) or 'wrong' (soft buzz).
  Future<void> playEffect(String name, {required bool enabled}) async {
    if (!enabled) return;
    try {
      await _ttsChannel.invokeMethod<void>('playEffect', {'name': name});
    } catch (_) {
      // Fallback to system sounds if native not available
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> speak(
    String message, {
    required bool enabled,
    required AppLanguage language,
  }) {
    if (!enabled) return Future<void>.value();
    return _speak(message, language.ttsLocale);
  }

  /// Speak [message] using an explicit BCP-47 [locale] tag (e.g. 'ar-SA').
  Future<void> speakLocale(
    String message, {
    required bool enabled,
    required String locale,
  }) {
    if (!enabled) return Future<void>.value();
    return _speak(message, locale);
  }

  Future<void> _speak(String message, String locale) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    try {
      await _ttsChannel.invokeMethod<void>('speak', {
        'text': trimmed,
        'locale': locale,
      });
    } catch (_) {
      // Some simulators/devices may not have every voice installed.
    }
  }

  Future<void> dispose() async {
    try {
      await _ttsChannel.invokeMethod<void>('stop');
    } catch (_) {
      // The platform channel may be unavailable in widget tests.
    }
  }
}
