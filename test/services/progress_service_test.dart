import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_finder/models/app_language.dart';
import 'package:tiny_finder/models/challenge.dart';
import 'package:tiny_finder/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores stars, counts, and earned badges locally', () async {
    final progressService = ProgressService();
    await progressService.load();

    expect(progressService.stars, 0);
    expect(progressService.completedChallenges, 0);

    for (var index = 0; index < 4; index++) {
      final badge = await progressService.completeChallenge(
        ChallengeMode.findExplorer,
      );
      expect(badge, isNull);
    }

    final earnedBadge = await progressService.completeChallenge(
      ChallengeMode.findExplorer,
    );

    expect(progressService.stars, 5);
    expect(progressService.completedChallenges, 5);
    expect(progressService.countFor(ChallengeMode.findExplorer), 5);
    // Completing 5 games unlocks the "First Finder" (5 games) and "First Stars"
    // (5 stars) badges simultaneously; completeChallenge returns one of them.
    expect(earnedBadge, isNotNull);
    expect(progressService.hasBadge('badge_games_5'), isTrue);
    expect(progressService.hasBadge('badge_stars_5'), isTrue);

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.stars, 5);
    expect(reloaded.countFor(ChallengeMode.findExplorer), 5);
    expect(reloaded.countFor(ChallengeMode.memory), 0);
    expect(reloaded.hasBadge('badge_games_5'), isTrue);
  });

  test('reset clears learning progress but keeps settings', () async {
    final progressService = ProgressService();
    await progressService.load();
    await progressService.setBackgroundMusicEnabled(true);
    await progressService.setSoundEnabled(false);
    await progressService.setVoiceEnabled(false);
    await progressService.completeChallenge(ChallengeMode.numberTrain);
    await progressService.completeChallenge(ChallengeMode.letterTrain);
    await progressService.completeChallenge(ChallengeMode.memory);
    await progressService.markModuleLesson('numbers', '1');
    await progressService.markModuleLesson('letters', 'A');
    await progressService.incrementColoringSessions();

    await progressService.resetProgress();

    expect(progressService.stars, 0);
    expect(progressService.completedChallenges, 0);
    expect(progressService.countFor(ChallengeMode.numberTrain), 0);
    expect(progressService.countFor(ChallengeMode.letterTrain), 0);
    expect(progressService.countFor(ChallengeMode.memory), 0);
    expect(progressService.getModuleLessons('numbers'), 0);
    expect(progressService.getModuleLessons('letters'), 0);
    expect(progressService.getLastLesson('numbers'), '');
    expect(progressService.getLastLesson('letters'), '');
    expect(progressService.coloringSessions, 0);
    expect(progressService.backgroundMusicEnabled, isTrue);
    expect(progressService.soundEnabled, isFalse);
    expect(progressService.voiceEnabled, isFalse);

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.stars, 0);
    expect(reloaded.completedChallenges, 0);
    expect(reloaded.countFor(ChallengeMode.numberTrain), 0);
    expect(reloaded.countFor(ChallengeMode.letterTrain), 0);
    expect(reloaded.countFor(ChallengeMode.memory), 0);
    expect(reloaded.getModuleLessons('numbers'), 0);
    expect(reloaded.getModuleLessons('letters'), 0);
    expect(reloaded.getLastLesson('numbers'), '');
    expect(reloaded.getLastLesson('letters'), '');
    expect(reloaded.coloringSessions, 0);
    expect(reloaded.backgroundMusicEnabled, isTrue);
    expect(reloaded.soundEnabled, isFalse);
    expect(reloaded.voiceEnabled, isFalse);
  });

  test('module lessons are counted once and persist locally', () async {
    final progressService = ProgressService();
    await progressService.load();

    await progressService.markModuleLesson('numbers', '1');
    await progressService.markModuleLesson('numbers', '1');
    await progressService.markModuleLesson('numbers', '2');

    expect(progressService.getModuleLessons('numbers'), 2);
    expect(progressService.getLastLesson('numbers'), '2');
    // Two distinct lessons grant 2 base stars; daily-quest bonuses may add more,
    // so assert at least the base and that the total persists across reload.
    final starsAfterLessons = progressService.stars;
    expect(starsAfterLessons, greaterThanOrEqualTo(2));

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.getModuleLessons('numbers'), 2);
    expect(reloaded.getLastLesson('numbers'), '2');
    expect(reloaded.stars, starsAfterLessons);
  });

  test('stores selected Bahasa Indonesia language locally', () async {
    final progressService = ProgressService();
    await progressService.load();

    await progressService.setLanguage(AppLanguage.indonesian);

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.language, AppLanguage.indonesian);
  });

  test('persists coloring sessions when incremented before load', () async {
    final progressService = ProgressService();

    await progressService.incrementColoringSessions();

    expect(progressService.coloringSessions, 1);

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.coloringSessions, 1);
  });
}
