import 'package:flutter/material.dart';

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
import 'theme/app_theme.dart';

class TinyFinderApp extends StatelessWidget {
  const TinyFinderApp({
    super.key,
    this.initialRoute = SplashScreen.routeName,
  });

  final String initialRoute;

  // Maps every route name to its screen builder. Kept as a lookup table so
  // onGenerateRoute can wrap each screen in the same custom transition.
  static final Map<String, WidgetBuilder> _screens = {
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
  };

  /// Builds a soft fade + scale-up transition shared by every route in the
  /// app, so navigating between screens feels continuous rather than an
  /// abrupt platform-default slide/cut.
  static PageRouteBuilder<T> _buildRoute<T>(
    String name,
    WidgetBuilder builder,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ProviderScope is initialised in main.dart — services are provided via
    // Riverpod providers in lib/providers/app_state.dart.
    return MaterialApp(
        title: 'Bijak Belajar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: initialRoute,
        navigatorObservers: [appRouteObserver],
        onGenerateRoute: (settings) {
          final builder = _screens[settings.name];
          if (builder == null) return null;
          return _buildRoute(settings.name!, builder, settings);
        },
    );
  }
}
