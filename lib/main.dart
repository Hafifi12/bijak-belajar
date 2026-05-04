import 'package:flutter/material.dart';

import 'app.dart';
import 'services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressService = ProgressService();
  await progressService.load();

  runApp(TinyFinderApp(progressService: progressService));
}
