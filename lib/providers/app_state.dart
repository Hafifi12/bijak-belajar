import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

/// Riverpod wrapper around [PackageInfo].
/// Override in [ProviderScope] with the pre-loaded instance from main().
final packageInfoProvider = Provider<PackageInfo>(
  (ref) => throw UnimplementedError(
    'packageInfoProvider must be overridden in ProviderScope',
  ),
);

/// Lazily-created [AudioService] using flutter_tts.
/// Disposed automatically when the provider is destroyed.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

// ── AppState data class ───────────────────────────────────────────────────

/// Lightweight read-only snapshot of the four gamification fields.
/// Computed from [progressServiceProvider] so it stays in sync automatically.
@immutable
class AppState {
  const AppState({
    required this.xp,
    required this.level,
    required this.streak,
    required this.unlockedBadges,
  });

  /// Stars / XP total.
  final int xp;

  /// Current level (1–10).
  final int level;

  /// Consecutive daily login streak.
  final int streak;

  /// IDs of all earned badges.
  final List<String> unlockedBadges;

  @override
  bool operator ==(Object other) =>
      other is AppState &&
      other.xp == xp &&
      other.level == level &&
      other.streak == streak &&
      listEquals(other.unlockedBadges, unlockedBadges);

  @override
  int get hashCode => Object.hash(xp, level, streak, unlockedBadges);

  @override
  String toString() =>
      'AppState(xp: $xp, level: $level, streak: $streak, badges: ${unlockedBadges.length})';
}

/// Computed provider — derives [AppState] directly from [ProgressService].
/// Any widget watching this rebuilds only when xp/level/streak/badges change.
final appStateProvider = Provider<AppState>((ref) {
  final ps = ref.watch(progressServiceProvider);
  return AppState(
    xp: ps.stars,
    level: ps.currentLevel.level,
    streak: ps.currentStreak,
    unlockedBadges: ps.badgeIds.toList(),
  );
});

/// Granular provider for voice-enabled state.
/// Widgets that only need this flag should watch here instead of
/// [progressServiceProvider], so they rebuild only when voice toggles —
/// not on every XP gain, badge unlock, or streak update.
final voiceEnabledProvider = Provider<bool>(
  (ref) => ref.watch(progressServiceProvider).voiceEnabled,
);
