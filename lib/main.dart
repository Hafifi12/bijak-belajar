import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/app_state.dart';
import 'services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressService = ProgressService();

  try {
    await progressService.load();
  } catch (e, stack) {
    debugPrint('[main] ProgressService.load() failed: $e\n$stack');
    runApp(const _LoadErrorApp());
    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        // Inject the pre-loaded ProgressService so Riverpod providers
        // can depend on it without a second async load.
        progressServiceProvider.overrideWith((ref) => progressService),
      ],
      child: const TinyFinderApp(),
    ),
  );
}

/// Minimal error screen shown when [ProgressService.load()] fails on launch.
class _LoadErrorApp extends StatelessWidget {
  const _LoadErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F8FF),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.red, size: 64),
                SizedBox(height: 20),
                Text(
                  'Could not load your progress.\nPlease restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333355),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
