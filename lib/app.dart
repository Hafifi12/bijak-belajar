import 'package:flutter/material.dart';

import 'utils/route_observer.dart';
import 'screens/coloring_screen.dart';
import 'screens/find_explorer_screen.dart';
import 'screens/games_hub_screen.dart';
import 'screens/home_screen.dart';
import 'screens/jawi_asas_screen.dart';
import 'screens/learn_body_parts_screen.dart';
import 'screens/learn_letters_screen.dart';
import 'screens/learn_numbers_screen.dart';
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
  const TinyFinderApp({super.key, this.initialRoute = SplashScreen.routeName});

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
    // ── Progress ────────────────────────────────────────────
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
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
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
        if (builder != null) {
          return _buildRoute(settings.name!, builder, settings);
        }
        return _buildRoute(
          settings.name ?? '/unknown',
          (_) => const _UnknownRouteScreen(),
          settings,
        );
      },
      builder: (context, child) {
        // Clamp system text scaling: layouts use fixed-height grids and
        // compact labels, so unbounded scaling overflows them, while very
        // small scales make kid-facing text illegible. 0.9–1.3 keeps both
        // accessibility headroom and layout integrity.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 96),
                const Icon(Icons.explore_off_rounded, size: 72),
                const SizedBox(height: 20),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        HomeScreen.routeName,
                        (route) => false,
                      ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Return home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
