import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/badge.dart';
import '../services/progress_service.dart';
import '../utils/app_text.dart';
import '../widgets/star_counter.dart';
import 'home_screen.dart';

class RewardArgs {
  const RewardArgs({
    required this.modeLabel,
    required this.nextRoute,
    this.nextArguments,
    this.badge,
  });

  final String modeLabel;
  final String nextRoute;
  final Object? nextArguments;
  final FinderBadge? badge;
}

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  static const routeName = '/reward';

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 900),
    )..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as RewardArgs?;
    final badge = args?.badge;
    final language = context.watch<ProgressService>().language;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                const StarCounter(large: true),
                const SizedBox(height: 28),
                Icon(
                  badge == null
                      ? Icons.star_rounded
                      : Icons.workspace_premium_rounded,
                  size: 96,
                  color: badge?.color ?? const Color(0xFFFFB000),
                ),
                const SizedBox(height: 18),
                Text(
                  badge == null
                      ? AppText.ui('earnedStar', language)
                      : AppText.ui('newBadge', language),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  badge == null
                      ? '${AppText.ui('greatWorkIn', language)} ${args?.modeLabel ?? 'Tiny Finder'}.'
                      : '${badge.title}: ${badge.description}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _playAgain(context, args),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(AppText.ui('playAgain', language)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _goHome(context),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(AppText.ui('home', language)),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.04,
              numberOfParticles: 14,
              gravity: 0.25,
            ),
          ],
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == HomeScreen.routeName);
  }

  void _playAgain(BuildContext context, RewardArgs? args) {
    if (args == null) {
      _goHome(context);
      return;
    }

    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.settings.name == HomeScreen.routeName);
    navigator.pushNamed(args.nextRoute, arguments: args.nextArguments);
  }
}
