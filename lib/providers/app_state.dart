import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_service.dart';
import '../services/progress_service.dart';

// ── Core service providers ────────────────────────────────────────────────

/// Riverpod wrapper around [ProgressService].
/// Override in [ProviderScope] with the pre-loaded instance from main().
final progressServiceProvider = ChangeNotifierProvider<ProgressService>(
  (ref) => throw UnimplementedError(
    'progressServiceProvider must be overridden in ProviderScope',
  ),
);

/// Lazily-created [AudioService] using flutter_tts.
/// Disposed automatically when the provider is destroyed.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Granular provider for voice-enabled state.
/// Widgets that only need this flag should watch here instead of
/// [progressServiceProvider], so they rebuild only when voice toggles —
/// not on every XP gain, badge unlock, or streak update.
final voiceEnabledProvider = Provider<bool>(
  (ref) => ref.watch(progressServiceProvider).voiceEnabled,
);
