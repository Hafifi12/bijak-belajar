import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/app_state.dart';
import 'services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressService = ProgressService();
  await progressService.load();

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
