import 'app_language.dart';
import 'challenge.dart';

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.stars,
    required this.completedChallenges,
    required this.completedByMode,
    required this.badgeIds,
    required this.soundEnabled,
    required this.voiceEnabled,
    required this.language,
  });

  final int stars;
  final int completedChallenges;
  final Map<ChallengeMode, int> completedByMode;
  final Set<String> badgeIds;
  final bool soundEnabled;
  final bool voiceEnabled;
  final AppLanguage language;

  int countFor(ChallengeMode mode) => completedByMode[mode] ?? 0;
}
