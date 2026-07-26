import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_finder/app.dart';
import 'package:tiny_finder/models/memory_item.dart';
import 'package:tiny_finder/providers/app_state.dart';
import 'package:tiny_finder/screens/home_screen.dart';
import 'package:tiny_finder/screens/learn_body_parts_screen.dart';
import 'package:tiny_finder/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('high memory board remains usable on a phone', () {
    expect(MemoryStage.high.gridSize, lessThanOrEqualTo(6));
    expect(MemoryStage.high.totalCards, lessThanOrEqualTo(36));
  });

  testWidgets('core routes render on a small phone at maximum text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({
      'last_login_date': '2099-01-01',
      'language': 'en',
    });
    final progress = ProgressService();
    await progress.load();

    const routes = <String>[
      '/learn-numbers',
      '/learn-letters',
      '/jawi-asas',
      '/learn-body-parts',
      '/math-practice',
      '/games-hub',
      '/find-explorer',
      '/memory',
      '/puzzle',
      '/coloring',
      '/progress',
      '/parent-gate',
      '/parent-settings',
    ];

    for (final route in routes) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [progressServiceProvider.overrideWith((ref) => progress)],
          child: TinyFinderApp(initialRoute: route),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull, reason: 'Route $route failed');
    }
  });

  testWidgets('unknown routes show a recoverable page', (tester) async {
    await tester.pumpWidget(const TinyFinderApp(initialRoute: '/missing'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Page not found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home and daily missions fit a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'last_login_date': '2099-01-01',
      'language': 'en',
    });
    final progress = ProgressService();
    await progress.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [progressServiceProvider.overrideWith((ref) => progress)],
        child: const TinyFinderApp(initialRoute: HomeScreen.routeName),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);

    final mission = find.textContaining('Daily Missions');
    if (mission.evaluate().isNotEmpty) {
      await tester.tap(mission.first);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsWidgets);
    }
  });

  testWidgets('body parts lesson has clean non-overlapping primary controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'last_login_date': '2099-01-01',
      'language': 'en',
    });
    final progress = ProgressService();
    await progress.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [progressServiceProvider.overrideWith((ref) => progress)],
        child: const MaterialApp(home: LearnBodyPartsScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('body-anatomy-stage')), findsOneWidget);
    expect(find.byKey(const Key('body-vocabulary-card')), findsOneWidget);
    expect(find.byKey(const Key('body-doctor-says-button')), findsOneWidget);
    expect(find.byKey(const Key('body-next-button')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final controls = <Finder>[
      find.byKey(const Key('body-doctor-says-button')),
      find.byKey(const Key('body-back-button')),
      find.byKey(const Key('body-next-button')),
    ];
    final rects = controls.map(tester.getRect).toList();
    for (var i = 0; i < rects.length; i++) {
      expect(rects[i].width, greaterThanOrEqualTo(48));
      expect(rects[i].height, greaterThanOrEqualTo(48));
      for (var j = i + 1; j < rects.length; j++) {
        expect(rects[i].overlaps(rects[j]), isFalse);
      }
    }
  });
}
