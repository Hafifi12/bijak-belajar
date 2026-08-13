import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijak_belajar/providers/app_state.dart';
import 'package:bijak_belajar/screens/math_practice_screen.dart';
import 'package:bijak_belajar/services/progress_service.dart';

/// Regression test for the blank MathQuizScreen body.
///
/// The quiz body used to be wrapped in `IntrinsicHeight`, which measures the
/// intrinsic height of its subtree. The subtree contains lazy viewports (the
/// answer-options `GridView` and the counting-objects `SingleChildScrollView`),
/// and viewports throw `RenderShrinkWrappingViewport does not support returning
/// intrinsic dimensions` when measured — leaving the whole body blank.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'language': 'en'});
  });

  Future<void> pumpQuiz(WidgetTester tester, MathOp op) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final progressService = ProgressService();
    await progressService.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressServiceProvider.overrideWith((ref) => progressService),
        ],
        child: MaterialApp(
          home: MathQuizScreen(op: op, color: const Color(0xFF00C9A7)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('renders the quiz body without an intrinsic-viewport crash',
      (tester) async {
    await pumpQuiz(tester, MathOp.count);

    // The bug surfaced as a layout-phase exception; assert none was thrown.
    expect(tester.takeException(), isNull);
    // And the answer-options grid (previously blanked) is laid out.
    expect(find.byType(GridView), findsWidgets);
  });

  testWidgets('renders for a non-counting op too (number bonds)',
      (tester) async {
    await pumpQuiz(tester, MathOp.bond);

    expect(tester.takeException(), isNull);
    expect(find.byType(GridView), findsWidgets);
  });
}
