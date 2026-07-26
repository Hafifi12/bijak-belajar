import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_finder/app.dart';
import 'package:tiny_finder/models/train_mode.dart';
import 'package:tiny_finder/providers/app_state.dart';
import 'package:tiny_finder/screens/home_screen.dart';
import 'package:tiny_finder/screens/memory_category_screen.dart';
import 'package:tiny_finder/screens/train_sort_screen.dart';
import 'package:tiny_finder/services/progress_service.dart';

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Seed today's login date so the daily-reward dialog does not pop over the
    // home screen during these UI tests. Pin language to English because the
    // app now defaults to Bahasa Melayu (Malaysian-first) and these tests
    // assert English strings.
    SharedPreferences.setMockInitialValues({
      'last_login_date': _todayKey(),
      'language': 'en',
    });
  });

  Future<void> pumpAppAndOpenHome(
    WidgetTester tester,
    ProgressService progressService,
  ) async {
    // Use a tall surface so the scrolling home content (header + all module
    // tiles) is laid out without needing to scroll lazy slivers into view.
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressServiceProvider.overrideWith((ref) => progressService),
        ],
        child: const TinyFinderApp(initialRoute: HomeScreen.routeName),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('shows the Bijak Belajar adventure-map home', (tester) async {
    final progressService = ProgressService();
    await progressService.load();

    await pumpAppAndOpenHome(tester, progressService);

    // The home is now a zone-based adventure map with a bottom nav.
    expect(find.text('Home'), findsOneWidget); // localized home navigation
    expect(find.textContaining('Number'), findsWidgets); // Number Bazaar zone
    expect(find.textContaining('Letter'), findsWidgets); // Letter Village zone
  });

  testWidgets('opens the number train sorting game', (tester) async {
    final progressService = ProgressService();
    await progressService.load();

    await pumpAppAndOpenHome(tester, progressService);

    Navigator.of(tester.element(find.byType(HomeScreen))).pushNamed(
      TrainSortScreen.routeName,
      arguments: const TrainSortArgs(mode: TrainMode.numbers),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(TrainSortScreen), findsOneWidget);
    expect(find.text('Tap number 1.'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('opens memory categories', (tester) async {
    final progressService = ProgressService();
    await progressService.load();

    await pumpAppAndOpenHome(tester, progressService);

    Navigator.of(
      tester.element(find.byType(HomeScreen)),
    ).pushNamed(MemoryCategoryScreen.routeName);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(MemoryCategoryScreen), findsOneWidget);
    expect(find.text('Pick a memory game'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
  });
}
