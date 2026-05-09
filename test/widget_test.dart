import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_finder/app.dart';
import 'package:tiny_finder/models/train_mode.dart';
import 'package:tiny_finder/screens/home_screen.dart';
import 'package:tiny_finder/screens/memory_category_screen.dart';
import 'package:tiny_finder/screens/train_sort_screen.dart';
import 'package:tiny_finder/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpAppAndOpenHome(
    WidgetTester tester,
    ProgressService progressService,
  ) async {
    await tester.pumpWidget(
      TinyFinderApp(
        progressService: progressService,
        initialRoute: HomeScreen.routeName,
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('shows the Bijak Belajar home modes', (tester) async {
    final progressService = ProgressService();
    await progressService.load();

    await pumpAppAndOpenHome(tester, progressService);

    expect(find.text('Bijak'), findsWidgets);
    expect(find.text('Belajar'), findsWidgets);
    expect(find.text('Numbers'), findsWidgets);
    expect(find.text('Letters'), findsWidgets);
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
