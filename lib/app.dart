import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/coloring_screen.dart';
import 'screens/find_explorer_screen.dart';
import 'screens/games_hub_screen.dart';
import 'screens/home_screen.dart';
import 'screens/jawi_asas_screen.dart';
import 'screens/learn_body_parts_screen.dart';
import 'screens/learn_letters_screen.dart';
import 'screens/learn_numbers_screen.dart';
import 'screens/learning_path_screen.dart';
import 'screens/math_practice_screen.dart';
import 'screens/memory_category_screen.dart';
import 'screens/memory_game_screen.dart';
import 'screens/parent_gate_screen.dart';
import 'screens/parent_settings_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/puzzle_screen.dart';
import 'screens/reward_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/train_sort_screen.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';
import 'theme/app_theme.dart';

class TinyFinderApp extends StatelessWidget {
  const TinyFinderApp({
    super.key,
    required this.progressService,
    this.initialRoute = SplashScreen.routeName,
  });

  final ProgressService progressService;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: progressService),
        Provider(
          create: (_) => AudioService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Bijak Belajar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: initialRoute,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          // ── Learn ───────────────────────────────────────────────
          LearnNumbersScreen.routeName: (_) => const LearnNumbersScreen(),
          LearnLettersScreen.routeName: (_) => const LearnLettersScreen(),
          JawiAsasScreen.routeName: (_) => const JawiAsasScreen(),
          LearnBodyPartsScreen.routeName: (_) => const LearnBodyPartsScreen(),
          MathPracticeScreen.routeName: (_) => const MathPracticeScreen(),
          // ── Games ───────────────────────────────────────────────
          GamesHubScreen.routeName: (_) => const GamesHubScreen(),
          FindExplorerScreen.routeName: (_) => const FindExplorerScreen(),
          TrainSortScreen.routeName: (_) => const TrainSortScreen(),
          MemoryCategoryScreen.routeName: (_) => const MemoryCategoryScreen(),
          MemoryGameScreen.routeName: (_) => const MemoryGameScreen(),
          PuzzleScreen.routeName: (_) => const PuzzleScreen(),
          // ── Creative ────────────────────────────────────────────
          ColoringScreen.routeName: (_) => const ColoringScreen(),
          // ── Syllabus & Progress ─────────────────────────────────
          LearningPathScreen.routeName: (_) => const LearningPathScreen(),
          ProgressScreen.routeName: (_) => const ProgressScreen(),
          RewardScreen.routeName: (_) => const RewardScreen(),
          // ── Parent / Teacher ────────────────────────────────────
          ParentGateScreen.routeName: (_) => const ParentGateScreen(),
          ParentSettingsScreen.routeName: (_) => const ParentSettingsScreen(),
        },
      ),
    );
  }
}
