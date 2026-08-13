import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijak_belajar/providers/app_state.dart';
import 'package:bijak_belajar/screens/privacy_policy_screen.dart';
import 'package:bijak_belajar/services/progress_service.dart';

/// The in-app privacy policy is required by Google Play's User Data and
/// Families policies (the app requests the microphone). This guards that the
/// screen renders and keeps disclosing the microphone use.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'language': 'en'});
  });

  Future<void> pumpPolicy(WidgetTester tester) async {
    final progressService = ProgressService();
    await progressService.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressServiceProvider.overrideWith((ref) => progressService),
        ],
        child: const MaterialApp(home: PrivacyPolicyScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('renders and discloses microphone use', (tester) async {
    await pumpPolicy(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('Microphone'), findsWidgets);
    expect(find.textContaining('anfstudio.dev@gmail.com'), findsOneWidget);
  });
}
