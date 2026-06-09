import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../data/badge_data.dart';
import '../models/app_language.dart';
import '../models/challenge.dart';
import '../models/train_mode.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import '../widgets/badge_card.dart';
import 'learning_path_screen.dart';
import 'memory_category_screen.dart';
import 'puzzle_screen.dart';
import 'train_sort_screen.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  static const routeName = '/progress';

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressServiceProvider);
    final language = progress.language;
    final isMalay = language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back',
        ),
        title: Text(
          isMalay ? '🏆 Kemajuan Saya' : '🏆 My Progress',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _StarHeroBanner(progress: progress, isMalay: isMalay),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _SyllabusProgressShortcut(
                  progress: progress,
                  isMalay: isMalay,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  emoji: '🎮',
                  title: isMalay
                      ? 'Aktiviti & Permainan'
                      : 'Activities & Games',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _ActivityStatsRow(progress: progress, isMalay: isMalay),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  emoji: '🏅',
                  title: AppText.ui('badges', language),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: BadgeCard(
                      badge: badges[i],
                      earned: progress.hasBadge(badges[i].id),
                    ),
                  ),
                  childCount: badges.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Star Hero Banner ──────────────────────────────────────────────────────────
class _StarHeroBanner extends ConsumerStatefulWidget {
  const _StarHeroBanner({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  ConsumerState<_StarHeroBanner> createState() => _StarHeroBannerState();
}

class _StarHeroBannerState extends ConsumerState<_StarHeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkCtrl;

  @override
  void initState() {
    super.initState();
    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkCtrl.dispose();
    super.dispose();
  }

  String _motivationalMessage(int stars, int done, bool isMalay) {
    if (done == 0) {
      return isMalay
          ? 'Mulakan perjalanan belajar kamu hari ini! 🚀'
          : 'Start your learning journey today! 🚀';
    }
    if (stars < 10) {
      return isMalay
          ? 'Bagus! Teruskan untuk dapat lebih bintang! 🌟'
          : 'Good start! Keep learning for more stars! 🌟';
    }
    if (stars < 30) {
      return isMalay
          ? 'Hebat! Kamu dalam perjalanan yang betul! 🎉'
          : 'Great job! You\'re on the right track! 🎉';
    }
    if (stars < 60) {
      return isMalay
          ? 'Luar biasa! Kamu pelajar yang handal! ⭐'
          : 'Amazing! You\'re a super learner! ⭐';
    }
    return isMalay
        ? 'WOW! Kamu seorang bintang belajar sejati! 🏆🌟'
        : 'WOW! You\'re a true learning star! 🏆🌟';
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.progress.stars;
    final done = widget.progress.completedChallenges;
    final isMalay = widget.isMalay;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1F6B), Color(0xFF1565C0), AppTheme.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _sparkCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned(
                top: math.sin(_sparkCtrl.value * 2 * math.pi) * 8,
                right: 16,
                child: Opacity(
                  opacity:
                      (0.5 + 0.5 * math.cos(_sparkCtrl.value * 2 * math.pi))
                          .clamp(0, 1),
                  child: const Text('✨', style: TextStyle(fontSize: 22)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMalay
                                  ? 'Bilik Trofi Kamu!'
                                  : 'Your Trophy Room!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              isMalay
                                  ? 'Teruskan belajar & kumpul bintang! ⭐'
                                  : 'Keep learning & collect stars! ⭐',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroBubble(
                          value: '$stars',
                          label: isMalay ? 'Bintang' : 'Stars',
                          icon: '⭐',
                          color: AppTheme.sunnyYellow,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroBubble(
                          value: '$done',
                          label: isMalay ? 'Selesai' : 'Completed',
                          icon: '✅',
                          color: AppTheme.leafGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroBubble(
                          value: '${widget.progress.coloringSessions}',
                          label: isMalay ? 'Mewarna' : 'Coloured',
                          icon: '🎨',
                          color: const Color(0xFFFF9F43),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _motivationalMessage(stars, done, isMalay),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroBubble extends ConsumerWidget {
  const _HeroBubble({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value, label, icon;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Syllabus Shortcut ─────────────────────────────────────────────────────────
class _SyllabusProgressShortcut extends ConsumerWidget {
  const _SyllabusProgressShortcut({
    required this.progress,
    required this.isMalay,
  });

  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 5,
      shadowColor: AppTheme.skyBlue.withValues(alpha: 0.18),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () =>
            Navigator.of(context).pushNamed(LearningPathScreen.routeName),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.skyBlue, AppTheme.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('📚', style: TextStyle(fontSize: 27)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMalay ? 'Kemajuan Sukatan' : 'Syllabus Progress',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isMalay
                          ? 'Lihat kemajuan modul lengkap di Laluan Pembelajaran.'
                          : 'See full module progress in the Learning Path.',
                      style: const TextStyle(
                        color: Color(0xFF68789F),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MiniProgressPill(
                          label:
                              '⭐ ${progress.stars} ${isMalay ? "bintang" : "stars"}',
                        ),
                        _MiniProgressPill(
                          label:
                              '✅ ${progress.completedChallenges} ${isMalay ? "aktiviti" : "activities"}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.skyBlue.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.skyBlue,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgressPill extends ConsumerWidget {
  const _MiniProgressPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.ink,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends ConsumerWidget {
  const _SectionHeader({required this.emoji, required this.title});
  final String emoji, title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }
}

// ── Activity Stats ─────────────────────────────────────────────────────────────
class _ActivityStatsRow extends ConsumerWidget {
  const _ActivityStatsRow({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = [
      _ActivityStat(
        '🚂',
        isMalay ? 'Tren\nNombor' : 'Number\nTrain',
        progress.countFor(ChallengeMode.numberTrain),
        AppTheme.appleRed,
        () => Navigator.of(context).pushNamed(
          TrainSortScreen.routeName,
          arguments: const TrainSortArgs(mode: TrainMode.numbers),
        ),
      ),
      _ActivityStat(
        '🚃',
        isMalay ? 'Tren\nHuruf' : 'Letter\nTrain',
        progress.countFor(ChallengeMode.letterTrain),
        AppTheme.turquoise,
        () => Navigator.of(context).pushNamed(
          TrainSortScreen.routeName,
          arguments: const TrainSortArgs(mode: TrainMode.letters),
        ),
      ),
      _ActivityStat(
        '🃏',
        isMalay ? 'Permainan\nMemori' : 'Memory\nGame',
        progress.countFor(ChallengeMode.memory),
        AppTheme.purple,
        () => Navigator.of(context).pushNamed(MemoryCategoryScreen.routeName),
      ),
      _ActivityStat(
        '🧩',
        isMalay ? 'Teka-Teki\nGambar' : 'Puzzle\nGame',
        progress.countFor(ChallengeMode.puzzle),
        AppTheme.leafGreen,
        () => Navigator.of(context).pushNamed(PuzzleScreen.routeName),
      ),
    ];
    return Row(
      children: [
        for (var index = 0; index < stats.length; index++) ...[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == stats.length - 1 ? 0 : 8,
              ),
              child: Semantics(
                button: true,
                label:
                    '${stats[index].label.replaceAll('\n', ' ')}: ${stats[index].count}',
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  elevation: 4,
                  shadowColor: stats[index].color.withValues(alpha: 0.2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: stats[index].onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        children: [
                          Text(
                            stats[index].emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${stats[index].count}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: stats[index].color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stats[index].label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityStat {
  const _ActivityStat(
    this.emoji,
    this.label,
    this.count,
    this.color,
    this.onTap,
  );

  final String emoji, label;
  final int count;
  final Color color;
  final VoidCallback onTap;
}
