import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/badge.dart';
import '../theme/app_theme.dart';
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

/// The emotional peak of a session — "Lesson Complete". A star-burst, Zara the
/// owl reacting with praise, the rewards earned, and a story-style track that
/// shows how close the child is to the next level, all forward-first.
class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});
  static const routeName = '/reward';

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _scaleCtrl;
  late final AnimationController _zaraCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _zaraScale;

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
    _zaraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _zaraScale = CurvedAnimation(parent: _zaraCtrl, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _zaraCtrl.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleCtrl.dispose();
    _zaraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as RewardArgs?;
    final badge = args?.badge;
    final progress = ref.watch(progressServiceProvider);
    final language = progress.language;
    final isMalay = language.name == 'malay';
    final level = progress.currentLevel;
    final modeLabel = args?.modeLabel ?? 'Bijak Belajar';

    final frac = level.progressFraction(progress.stars).clamp(0.0, 1.0);
    final toNext = level.starsToNext(progress.stars);
    final maxed = level.maxStars < 0;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Radial night-violet backdrop ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.45),
                radius: 1.15,
                colors: [Color(0xFF2D1060), Color(0xFF0A0F1E)],
              ),
            ),
            child: SizedBox.expand(),
          ),
          ..._buildBgStars(),

          // ── Content ──
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
              children: [
                // Close
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => _goHome(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // ── Star burst + complete badge ──
                ScaleTransition(
                  scale: _scale,
                  child: Column(
                    children: [
                      Text(
                        badge != null ? '🏅' : '⭐⭐⭐',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: badge != null ? 74 : 46,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: AppTheme.gold.withValues(alpha: 0.85),
                              blurRadius: 26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.gold, AppTheme.ember],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.ember.withValues(alpha: 0.5),
                              blurRadius: 18,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          badge != null
                              ? (isMalay ? '🎉 LENCANA BARU!' : '🎉 NEW BADGE!')
                              : (isMalay
                                    ? '🎉 PELAJARAN SELESAI!'
                                    : '🎉 LESSON COMPLETE!'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Zara reacts ──
                ScaleTransition(
                  scale: _zaraScale,
                  child: Column(
                    children: [
                      const Text('🦉', style: TextStyle(fontSize: 62)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              badge != null
                                  ? (isMalay
                                        ? 'Wah! Kamu buka lencana baru! 🌟'
                                        : 'Wow! You unlocked a new badge! 🌟')
                                  : (isMalay
                                        ? 'Hebat sekali! Kamu selesai $modeLabel!'
                                        : 'Amazing! You finished $modeLabel!'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _encouragement(progress.stars, isMalay),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Reward chips ──
                Row(
                  children: [
                    Expanded(
                      child: _RewardChip(
                        icon: '⭐',
                        value: '${progress.stars}',
                        label: isMalay ? 'Bintang' : 'Stars',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RewardChip(
                        icon: '🔥',
                        value: '${progress.currentStreak}',
                        label: isMalay ? 'Streak' : 'Streak',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RewardChip(
                        icon: level.emoji,
                        value: '${level.level}',
                        label: isMalay ? 'Tahap' : 'Level',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Level "story" track ──
                _LevelTrack(
                  isMalay: isMalay,
                  fraction: frac.toDouble(),
                  starsToNext: toNext,
                  nextLevel: level.level + 1,
                  maxed: maxed,
                  levelTitle: isMalay ? level.titleMalay : level.title,
                ),

                const SizedBox(height: 22),

                // ── Buttons (forward-first) ──
                GestureDetector(
                  onTap: () => _playAgain(context, args),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.violet, AppTheme.lilac],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.violet.withValues(alpha: 0.6),
                          blurRadius: 22,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🚀', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Text(
                          isMalay
                              ? 'Teruskan Pengembaraan!'
                              : 'Continue the Adventure!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _goHome(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🗺️', style: TextStyle(fontSize: 17)),
                        const SizedBox(width: 8),
                        Text(
                          isMalay ? 'Kembali ke Peta' : 'Back to Map',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              colors: const [
                AppTheme.gold,
                AppTheme.lilac,
                AppTheme.coral,
                AppTheme.turquoise,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _encouragement(int stars, bool isMalay) {
    if (stars < 5) {
      return isMalay
          ? 'Permulaan yang hebat — teruskan!'
          : 'A great start — keep going!';
    }
    if (stars < 20) {
      return isMalay
          ? 'Kamu semakin bijak setiap hari!'
          : "You're getting smarter every day!";
    }
    if (stars < 50) {
      return isMalay
          ? 'Pelajar yang cemerlang!'
          : "You're an excellent learner!";
    }
    return isMalay
        ? 'Kamu bintang belajar sejati!'
        : "You're a true learning star!";
  }

  List<Widget> _buildBgStars() {
    final rng = math.Random(42);
    return List.generate(14, (i) {
      return Positioned(
        left: rng.nextDouble() * 400,
        top: rng.nextDouble() * 800,
        child: Opacity(
          opacity: 0.08 + rng.nextDouble() * 0.14,
          child: Text(
            i.isEven ? '⭐' : '✨',
            style: TextStyle(fontSize: 14 + rng.nextDouble() * 20),
          ),
        ),
      );
    });
  }

  void _goHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
  }

  void _playAgain(BuildContext context, RewardArgs? args) {
    if (args == null) {
      _goHome(context);
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      args.nextRoute,
      (route) => false,
      arguments: args.nextArguments,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reward chip (glass)
// ─────────────────────────────────────────────────────────────────────────────
class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.value,
    required this.label,
  });
  final String icon, value, label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level story-track (nodes + connectors + unlock text)
// ─────────────────────────────────────────────────────────────────────────────
class _LevelTrack extends StatelessWidget {
  const _LevelTrack({
    required this.isMalay,
    required this.fraction,
    required this.starsToNext,
    required this.nextLevel,
    required this.maxed,
    required this.levelTitle,
  });
  final bool isMalay;
  final double fraction;
  final int starsToNext;
  final int nextLevel;
  final bool maxed;
  final String levelTitle;

  @override
  Widget build(BuildContext context) {
    const nodeCount = 5;
    final doneCount = maxed
        ? nodeCount
        : (fraction * (nodeCount - 1)).round().clamp(0, nodeCount - 1);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMalay ? 'KEMAJUAN — $levelTitle' : 'PROGRESS — $levelTitle',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < nodeCount; i++) ...[
                _node(i, doneCount, nodeCount),
                if (i < nodeCount - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i < doneCount
                            ? AppTheme.leafGreen
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              maxed
                  ? (isMalay
                        ? '👑 Kamu di tahap tertinggi!'
                        : '👑 You reached the top level!')
                  : (isMalay
                        ? 'Lagi $starsToNext bintang untuk Tahap $nextLevel!'
                        : '$starsToNext more stars to reach Level $nextLevel!'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.lilac,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _node(int i, int doneCount, int nodeCount) {
    final isDone = i < doneCount;
    final isCurrent = i == doneCount;
    final isTrophy = i == nodeCount - 1;

    Color bg;
    Color border;
    String glyph;
    if (isDone) {
      bg = AppTheme.leafGreen;
      border = AppTheme.leafGreen;
      glyph = '✓';
    } else if (isCurrent) {
      bg = AppTheme.violet;
      border = AppTheme.lilac;
      glyph = '📍';
    } else {
      bg = Colors.white.withValues(alpha: 0.05);
      border = Colors.white.withValues(alpha: 0.12);
      glyph = isTrophy ? '🏆' : '🔒';
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.violet.withValues(alpha: 0.6),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: isDone ? 14 : 12,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
