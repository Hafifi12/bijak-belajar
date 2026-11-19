import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijak_belajar/models/app_language.dart';
import 'package:bijak_belajar/providers/app_state.dart';
import 'package:bijak_belajar/screens/learn_letters_screen.dart';
import 'package:bijak_belajar/services/progress_service.dart';
import 'package:bijak_belajar/utils/app_text.dart';

/// The speaking button only appears when the phone can recognise speech on
/// the device. The microphone is never requested just by opening the lesson.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('bijak_belajar/speech');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<void> pumpLetters(WidgetTester tester, String languageCode) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'last_login_date': '2099-01-01',
      'language': languageCode,
    });
    final progress = ProgressService();
    await progress.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [progressServiceProvider.overrideWith((ref) => progress)],
        child: const MaterialApp(home: LearnLettersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('offers speaking when the phone recognises speech offline', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(channel, (call) async => true);

    await pumpLetters(tester, 'en');

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('speak-button')), findsOneWidget);
    expect(find.byKey(const Key('speech-unavailable')), findsNothing);
  });

  testWidgets('explains in Malay why speaking is missing, without listening', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(channel, (call) async => false);

    await pumpLetters(tester, 'ms');

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('speak-button')), findsNothing);
    expect(
      find.text(AppText.ui('speechUnavailable', AppLanguage.malay)),
      findsOneWidget,
    );
  });
}
