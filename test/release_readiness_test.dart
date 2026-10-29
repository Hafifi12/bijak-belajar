import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijak_belajar/app.dart';
import 'package:bijak_belajar/models/app_language.dart';
import 'package:bijak_belajar/providers/app_state.dart';
import 'package:bijak_belajar/screens/home_screen.dart';
import 'package:bijak_belajar/screens/parent_gate_screen.dart';
import 'package:bijak_belajar/screens/parent_settings_screen.dart';
import 'package:bijak_belajar/screens/splash_screen.dart';
import 'package:bijak_belajar/services/progress_service.dart';
import 'package:bijak_belajar/utils/app_text.dart';

/// Public-release guards: Android 16 large screens, the first-run splash in
/// every language, and store-safe claims.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProgressService> loadProgress(String languageCode) async {
    SharedPreferences.setMockInitialValues({
      'last_login_date': '2099-01-01',
      'language': languageCode,
    });
    final progress = ProgressService();
    await progress.load();
    return progress;
  }

  Future<void> pumpRoute(
    WidgetTester tester,
    ProgressService progress,
    String route,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [progressServiceProvider.overrideWith((ref) => progress)],
        child: BijakBelajarApp(initialRoute: route),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  void useSurface(WidgetTester tester, Size size, {double textScale = 1}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  // Targeting API 36, Android 16 ignores the portrait lock on large screens
  // (sw >= 600dp), so tablets and unfolded foldables can show any of these.
  const largeScreens = {
    'tablet landscape': Size(1280, 800),
    'tablet portrait': Size(800, 1280),
    'unfolded foldable': Size(884, 1104),
  };

  const routes = <String>[
    SplashScreen.routeName,
    HomeScreen.routeName,
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
    ParentSettingsScreen.routeName,
  ];

  for (final MapEntry(key: name, value: size) in largeScreens.entries) {
    testWidgets('core routes render on a $name', (tester) async {
      useSurface(tester, size);
      final progress = await loadProgress('en');

      for (final route in routes) {
        await pumpRoute(tester, progress, route);
        expect(
          tester.takeException(),
          isNull,
          reason: 'Route $route failed on a $name',
        );
      }
    });
  }

  for (final language in AppLanguage.values) {
    testWidgets(
      'splash is fully localized in ${language.displayName} on a small phone',
      (tester) async {
        useSurface(tester, const Size(320, 568), textScale: 1.3);
        final progress = await loadProgress(language.code);

        await pumpRoute(tester, progress, SplashScreen.routeName);

        expect(tester.takeException(), isNull);
        expect(
          find.text(AppText.ui('letsLearn', language)),
          findsOneWidget,
          reason: 'Call-to-action should be in ${language.displayName}',
        );
        expect(
          find.textContaining(AppText.ui('badgeNoData', language)),
          findsOneWidget,
        );
      },
    );
  }

  for (final language in AppLanguage.values) {
    testWidgets(
      'parent settings fits a small phone in ${language.displayName}',
      (tester) async {
        useSurface(tester, const Size(320, 568), textScale: 1.3);
        final progress = await loadProgress(language.code);

        await pumpRoute(tester, progress, ParentSettingsScreen.routeName);

        expect(tester.takeException(), isNull);
        expect(find.text(AppText.ui('safetyTitle', language)), findsOneWidget);
      },
    );
  }

  testWidgets('no screen claims Google Play "Teacher Approved" status', (
    tester,
  ) async {
    // "Teacher Approved" is a Google Play programme designation; claiming it
    // without enrolment breaks Play's Families/deceptive-behaviour rules.
    useSurface(tester, const Size(800, 1280));
    for (final code in ['en', 'ms']) {
      final progress = await loadProgress(code);
      for (final route in [SplashScreen.routeName, '/coloring']) {
        await pumpRoute(tester, progress, route);
        expect(find.textContaining('Teacher'), findsNothing, reason: route);
        expect(find.textContaining('Disahkan Guru'), findsNothing);
      }
    }
  });

  testWidgets('sharing gate asks a times-table question and reports success', (
    tester,
  ) async {
    useSurface(tester, const Size(800, 1280));
    final progress = await loadProgress('en');
    bool? passed;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [progressServiceProvider.overrideWith((ref) => progress)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  passed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const ParentGateScreen(forSharing: true),
                    ),
                  );
                },
                child: const Text('share'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('share'));
    await tester.pump(); // build the pushed route
    await tester.pump(const Duration(seconds: 1)); // finish its transition

    final question = tester.widget<Text>(find.textContaining('×')).data!;
    final factors = RegExp(r'\d+')
        .allMatches(question)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    expect(factors, hasLength(2));
    for (final f in factors) {
      expect(f, inInclusiveRange(3, 9));
    }

    await tester.enterText(find.byType(TextField), '${factors[0] * factors[1]}');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(passed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('parent settings has no English-only text in Malay', (
    tester,
  ) async {
    useSurface(tester, const Size(800, 1280));
    final progress = await loadProgress('ms');

    await pumpRoute(tester, progress, ParentSettingsScreen.routeName);

    expect(tester.takeException(), isNull);
    expect(find.text('Privasi & keselamatan'), findsOneWidget);
    for (final english in [
      'Child-Safe App',
      'Play challenge and reward sounds',
      'No Ads',
      'No Login',
    ]) {
      expect(find.text(english), findsNothing, reason: english);
    }
  });
}
