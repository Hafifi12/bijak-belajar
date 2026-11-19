import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../models/app_language.dart';
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
                              ? (language.copy(ms: '🎉 LENCANA BARU!', en: '🎉 NEW BADGE!', zh: '🎉 新徽章！', ta: '🎉 புதிய பேட்ஜ்!'))
                              : (language.copy(ms: '🎉 PELAJARAN SELESAI!', en: '🎉 LESSON COMPLETE!', zh: '🎉 课程完成！', ta: '🎉 பாடம் முடிந்தது!')),
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
                                  ? (language.copy(ms: 'Wah! Kamu buka lencana baru! 🌟', en: 'Wow! You unlocked a new badge! 🌟', zh: '哇！你解锁了一枚新徽章！🌟', ta: 'வாவ்! நீ ஒரு புதிய பேட்ஜைப் பெற்றாய்! 🌟'))
                                  : (language.copy(ms: 'Hebat sekali! Kamu selesai $modeLabel!', en: 'Amazing! You finished $modeLabel!', zh: '太棒了！你完成了 $modeLabel！', ta: 'அற்புதம்! நீ $modeLabel-ஐ முடித்தாய்!')),
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
                              _encouragement(progress.stars, language),
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
                        label: language.copy(ms: 'Bintang', en: 'Stars', zh: '星星', ta: 'நட்சத்திரங்கள்'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RewardChip(
                        icon: '🔥',
                        value: '${progress.currentStreak}',
                        label: language.copy(ms: 'Streak', en: 'Streak', zh: '连续', ta: 'தொடர்ச்சி'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RewardChip(
                        icon: level.emoji,
                        value: '${level.level}',
                        label: language.copy(ms: 'Tahap', en: 'Level', zh: '级别', ta: 'நிலை'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Level "story" track ──
                _LevelTrack(
                  language: language,
                  fraction: frac.toDouble(),
                  starsToNext: toNext,
                  nextLevel: level.level + 1,
                  maxed: maxed,
                  levelTitle: language.usesMalayCopy ? level.titleMalay : level.title,
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
                          language.copy(ms: 'Teruskan Pengembaraan!', en: 'Continue the Adventure!', zh: '继续冒险！', ta: 'சாகசத்தைத் தொடர்!'),
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
                          language.copy(ms: 'Kembali ke Peta', en: 'Back to Map', zh: '返回地图', ta: 'வரைபடத்திற்குத் திரும்பு'),
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

  String _encouragement(int stars, AppLanguage language) {
    if (stars < 5) {
      return language.copy(ms: 'Permulaan yang hebat — teruskan!', en: 'A great start — keep going!', zh: '很好的开始——继续加油！', ta: 'சிறந்த தொடக்கம் — தொடர்ந்து செல்!');
    }
    if (stars < 20) {
      return language.copy(ms: 'Kamu semakin bijak setiap hari!', en: "You're getting smarter every day!", zh: '你每天都在变得更聪明！', ta: 'நீ ஒவ்வொரு நாளும் புத்திசாலியாகிறாய்!');
    }
    if (stars < 50) {
      return language.copy(ms: 'Pelajar yang cemerlang!', en: "You're an excellent learner!", zh: '你是一位优秀的学习者！', ta: 'நீ ஒரு சிறந்த கற்றவன்!');
    }
    return language.copy(ms: 'Kamu bintang belajar sejati!', en: "You're a true learning star!", zh: '你是真正的学习之星！', ta: 'நீ உண்மையான கற்றல் நட்சத்திரம்!');
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
    required this.language,
    required this.fraction,
    required this.starsToNext,
    required this.nextLevel,
    required this.maxed,
    required this.levelTitle,
  });
  final AppLanguage language;
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
            language.copy(ms: 'KEMAJUAN — $levelTitle', en: 'PROGRESS — $levelTitle', zh: '进度 — $levelTitle', ta: 'முன்னேற்றம் — $levelTitle'),
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
                  ? (language.copy(ms: '👑 Kamu di tahap tertinggi!', en: '👑 You reached the top level!', zh: '👑 你已到达最高级别！', ta: '👑 நீ உச்ச நிலையை அடைந்துவிட்டாய்!'))
                  : (language.copy(ms: 'Lagi $starsToNext bintang untuk Tahap $nextLevel!', en: '$starsToNext more stars to reach Level $nextLevel!', zh: '再获得 $starsToNext 颗星星即可升到 $nextLevel 级！', ta: 'நிலை $nextLevel-ஐ அடைய இன்னும் $starsToNext நட்சத்திரங்கள்!')),
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
