import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijak_belajar/providers/app_state.dart';
import 'package:bijak_belajar/screens/learn_numbers_screen.dart';
import 'package:bijak_belajar/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const ttsChannel = MethodChannel('flutter_tts');
  final calls = <MethodCall>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'zh'});
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (call) async {
          calls.add(call);
          if (call.method == 'getVoices') {
            return [
              {'name': 'Tingting', 'locale': 'zh-CN'},
            ];
          }
          return 1;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  testWidgets('tapping a counting object speaks its ordinal in selected language',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final progress = ProgressService();
    await progress.load();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressServiceProvider.overrideWith((ref) => progress),
        ],
        child: const MaterialApp(home: LearnNumbersScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 500));
    calls.clear();

    final scroller = find
        .descendant(
          of: find.byType(SingleChildScrollView).first,
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Tap objects to count'),
      500,
      scrollable: scroller,
    );
    await tester.pump();
    final countingPanel = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_CountingObjectsPanel',
    );
    final secondObject = find.descendant(
      of: countingPanel,
      matching: find.byType(InkWell),
    ).at(1);
    tester.widget<InkWell>(secondObject).onTap!();
    await tester.pump();

    expect(
      calls.where((call) => call.method == 'speak').map((call) => call.arguments),
      contains('二'),
    );
  });
}
