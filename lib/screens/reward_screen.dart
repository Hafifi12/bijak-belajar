import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/badge.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
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

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 3000),
    )..play();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as RewardArgs?;
    final badge = args?.badge;
    final progress = context.watch<ProgressService>();
    final language = progress.language;
    final isMalay = progress.language.name == 'malay';

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1F6B), Color(0xFF1565C0), AppTheme.skyBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Floating stars ──
          ..._buildBgStars(),

          // ── Content ──
          SafeArea(
            child: ScaleTransition(
              scale: _scale,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  // Top close button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => _goHome(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Trophy animation ──
                  Center(
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.sunnyYellow, width: 4),
                        boxShadow: [BoxShadow(color: AppTheme.sunnyYellow.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 5)],
                      ),
                      child: Center(
                        child: Text(
                          badge != null ? '🏅' : '⭐',
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Heading ──
                  Text(
                    badge == null
                        ? (isMalay ? 'Tahniah! 🎉' : 'Well Done! 🎉')
                        : (isMalay ? 'Lencana Baru! 🏅' : 'New Badge! 🏅'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.sunnyYellow,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 4))],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    badge == null
                        ? '${AppText.ui('greatWorkIn', language)} ${args?.modeLabel ?? 'Bijak Belajar'}!'
                        : '${badge.title}: ${badge.description}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Star counter card ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              '${progress.stars}',
                              style: const TextStyle(color: AppTheme.sunnyYellow, fontSize: 32, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              isMalay ? 'jumlah bintang' : 'total stars',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Encouragement message ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _encouragement(progress.stars, isMalay),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Action buttons ──
                  GestureDetector(
                    onTap: () => _playAgain(context, args),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.sunnyYellow, Color(0xFFFFB300)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: AppTheme.sunnyYellow.withValues(alpha: 0.6), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🚀', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Text(
                            AppText.ui('playAgain', language),
                            style: const TextStyle(color: AppTheme.ink, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _goHome(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            AppText.ui('home', language),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Confetti ──
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.06,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [AppTheme.sunnyYellow, Colors.white, AppTheme.turquoise, AppTheme.appleRed, AppTheme.leafGreen],
            ),
          ),
        ],
      ),
    );
  }

  String _encouragement(int stars, bool isMalay) {
    if (stars < 5) return isMalay ? '🌱 Permulaan yang hebat! Teruskan belajar setiap hari!' : '🌱 Great start! Keep learning every day!';
    if (stars < 20) return isMalay ? '🌟 Kamu semakin bijak! Setiap bintang = ilmu baru!' : '🌟 You\'re getting smarter! Every star = new knowledge!';
    if (stars < 50) return isMalay ? '🏅 Pelajar yang cemerlang! Ibu bapa bangga dengan kamu!' : '🏅 Excellent learner! Your parents are proud of you!';
    return isMalay ? '🏆 WOW! Kamu seorang bintang belajar sejati! Luar biasa!' : '🏆 WOW! You\'re a true learning star! Incredible!';
  }

  List<Widget> _buildBgStars() {
    final rng = math.Random(42);
    return List.generate(12, (i) {
      return Positioned(
        left: rng.nextDouble() * 400,
        top: rng.nextDouble() * 800,
        child: Opacity(
          opacity: 0.08 + rng.nextDouble() * 0.12,
          child: Text('⭐', style: TextStyle(fontSize: 20 + rng.nextDouble() * 20)),
        ),
      );
    });
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.settings.name == HomeScreen.routeName);
  }

  void _playAgain(BuildContext context, RewardArgs? args) {
    if (args == null) { _goHome(context); return; }
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.settings.name == HomeScreen.routeName);
    navigator.pushNamed(args.nextRoute, arguments: args.nextArguments);
  }
}
