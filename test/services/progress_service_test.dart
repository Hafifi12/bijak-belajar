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
    expect(earnedBadge?.id, 'badge_first_five');
    expect(progressService.hasBadge('badge_first_five'), isTrue);

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.stars, 5);
    expect(reloaded.countFor(ChallengeMode.findExplorer), 5);
    expect(reloaded.countFor(ChallengeMode.memory), 0);
    expect(reloaded.hasBadge('badge_first_five'), isTrue);
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

    await progressService.resetProgress();

    expect(progressService.stars, 0);
    expect(progressService.completedChallenges, 0);
    expect(progressService.countFor(ChallengeMode.numberTrain), 0);
    expect(progressService.countFor(ChallengeMode.letterTrain), 0);
    expect(progressService.countFor(ChallengeMode.memory), 0);
    expect(progressService.backgroundMusicEnabled, isTrue);
    expect(progressService.soundEnabled, isFalse);
    expect(progressService.voiceEnabled, isFalse);
  });

  test('module lessons are counted once and persist locally', () async {
    final progressService = ProgressService();
    await progressService.load();

    await progressService.markModuleLesson('numbers', '1');
    await progressService.markModuleLesson('numbers', '1');
    await progressService.markModuleLesson('numbers', '2');

    expect(progressService.getModuleLessons('numbers'), 2);
    expect(progressService.getLastLesson('numbers'), '2');
    expect(progressService.stars, 2);

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.getModuleLessons('numbers'), 2);
    expect(reloaded.getLastLesson('numbers'), '2');
    expect(reloaded.stars, 2);
  });

  test('stores selected Indonesian language locally', () async {
    final progressService = ProgressService();
    await progressService.load();

    await progressService.setLanguage(AppLanguage.indonesian);

    final reloaded = ProgressService();
    await reloaded.load();

    expect(reloaded.language, AppLanguage.indonesian);
  });
}
