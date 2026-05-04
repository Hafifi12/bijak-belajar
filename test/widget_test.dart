import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_finder/app.dart';
import 'package:tiny_finder/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the Tiny Finder home modes', (tester) async {
    final progressService = ProgressService();
    await progressService.load();

    await tester.pumpWidget(TinyFinderApp(progressService: progressService));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('What can you learn today?'), findsOneWidget);
    expect(find.text('Find Explorer'), findsOneWidget);
    expect(find.text('Number Train'), findsOneWidget);
    expect(find.text('Letter Train'), findsOneWidget);
    expect(find.text('Memory Game'), findsOneWidget);
    expect(find.text('Color Hunt'), findsNothing);
    expect(find.text('Shape Hunt'), findsNothing);
    expect(find.text('Object Hunt'), findsNothing);
    expect(find.text('Sound Guess'), findsNothing);
  });

  testWidgets('opens the number train sorting game', (tester) async {
    final progressService = ProgressService();
    await progressService.load();

    await tester.pumpWidget(TinyFinderApp(progressService: progressService));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Number Train'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tap number 1.'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('opens memory categories and starts an animal game', (
    tester,
  ) async {
    final progressService = ProgressService();
    await progressService.load();

    await tester.pumpWidget(TinyFinderApp(progressService: progressService));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Memory Game'));
    await tester.pumpAndSettle();

    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Shapes'), findsOneWidget);
    expect(find.text('Colors'), findsOneWidget);

    await tester.tap(find.text('Animals'));
    await tester.pumpAndSettle();

    expect(find.text('Animals'), findsOneWidget);
    expect(find.text('Look carefully'), findsOneWidget);
    expect(find.text('0 / 6 pairs'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Find the pairs'), findsOneWidget);
  });
}
