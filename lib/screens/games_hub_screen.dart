import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../models/challenge.dart';
import '../models/train_mode.dart';
import 'find_explorer_screen.dart';
import 'memory_category_screen.dart';
import 'puzzle_screen.dart';
import 'train_sort_screen.dart';

class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});
  static const routeName = '/games-hub';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final isMalay = progress.language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back',
        ),
        title: Text(
          isMalay ? 'Permainan & Aktiviti 🎮' : 'Games & Activities 🎮',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _GamesHeader(isMalay: isMalay)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionLabel(
                  emoji: '🚂',
                  label: isMalay ? 'Latihan Susun' : 'Sort & Train',
                  color: const Color(0xFFFF9F43),
                ),
                const SizedBox(height: 10),
                _GameCard(
                  emoji: '🔢',
                  title: isMalay ? 'Tren Nombor' : 'Number Train',
                  subtitle: isMalay
                      ? 'Susun nombor mengikut turutan yang betul'
                      : 'Sort number cars in the correct order',
                  color: const Color(0xFFFF6B6B),
                  completedCount: progress.countFor(ChallengeMode.numberTrain),
                  learningObjective: isMalay
                      ? 'Urutan nombor, matematik asas'
                      : 'Number sequencing, basic numeracy',
                  onTap: () => Navigator.of(context).pushNamed(
                    TrainSortScreen.routeName,
                    arguments: const TrainSortArgs(mode: TrainMode.numbers),
                  ),
                ),
                const SizedBox(height: 12),
                _GameCard(
                  emoji: '🔤',
                  title: isMalay ? 'Tren Huruf' : 'Letter Train',
                  subtitle: isMalay
                      ? 'Susun huruf mengikut susunan A–Z'
                      : 'Sort letter cars in A–Z order',
                  color: const Color(0xFF1DD1A1),
                  completedCount: progress.countFor(ChallengeMode.letterTrain),
                  learningObjective: isMalay
                      ? 'Turutan abjad, literasi awal'
                      : 'Alphabet sequence, early literacy',
                  onTap: () => Navigator.of(context).pushNamed(
                    TrainSortScreen.routeName,
                    arguments: const TrainSortArgs(mode: TrainMode.letters),
                  ),
                ),

                const SizedBox(height: 22),

                _SectionLabel(
                  emoji: '🧠',
                  label: isMalay ? 'Daya Ingatan & Fokus' : 'Memory & Focus',
                  color: const Color(0xFF7C4DFF),
                ),
                const SizedBox(height: 10),
                _GameCard(
                  emoji: '🃏',
                  title: isMalay ? 'Permainan Memori' : 'Memory Game',
                  subtitle: isMalay
                      ? 'Balikkan dan padankan kad — bina ingatan kuat'
                      : 'Flip and match cards — build strong memory',
                  color: const Color(0xFF7E57C2),
                  completedCount: progress.countFor(ChallengeMode.memory),
                  learningObjective: isMalay
                      ? 'Daya ingatan, tumpuan, padanan gambar'
                      : 'Memory, concentration, picture matching',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(MemoryCategoryScreen.routeName),
                ),
                const SizedBox(height: 12),
                _GameCard(
                  emoji: '🧩',
                  title: isMalay ? 'Teka-Teki Gambar' : 'Picture Puzzle',
                  subtitle: isMalay
                      ? 'Susun jubin gambar — mudah 3×3 dan susah 4×4'
                      : 'Arrange picture tiles — easy 3×3 and hard 4×4',
                  color: const Color(0xFF00897B),
                  completedCount: progress.countFor(ChallengeMode.puzzle),
                  learningObjective: isMalay
                      ? 'Penyelesaian masalah, koordinasi, ruang'
                      : 'Problem-solving, coordination, spatial sense',
                  onTap: () =>
                      Navigator.of(context).pushNamed(PuzzleScreen.routeName),
                ),

                const SizedBox(height: 22),

                _SectionLabel(
                  emoji: '🔎',
                  label: isMalay ? 'Cari & Terokai' : 'Find & Explore',
                  color: const Color(0xFF00C9A7),
                ),
                const SizedBox(height: 10),
                _GameCard(
                  emoji: '🔍',
                  title: isMalay ? 'Penjelajah Cari' : 'Find Explorer',
                  subtitle: isMalay
                      ? 'Cari benda yang disebut — latih pendengaran & penglihatan'
                      : 'Find the object named — train listening & visual skills',
                  color: const Color(0xFF00C9A7),
                  completedCount: progress.countFor(ChallengeMode.findExplorer),
                  learningObjective: isMalay
                      ? 'Perbendaharaan kata, pendengaran, tumpuan'
                      : 'Vocabulary, listening, attention focus',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(FindExplorerScreen.routeName),
                ),

                const SizedBox(height: 22),

                _SectionLabel(
                  emoji: '💡',
                  label: isMalay
                      ? 'Tips Ibu Bapa & Guru'
                      : 'Parent & Teacher Tips',
                  color: const Color(0xFF1EA7FF),
                ),
                const SizedBox(height: 10),
                _TipCard(isMalay: isMalay),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────
class _GamesHeader extends ConsumerWidget {
  const _GamesHeader({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF1EA7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎮', style: TextStyle(fontSize: 52)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMalay ? 'Permainan Pendidikan' : 'Educational Games',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMalay
                      ? 'Belajar melalui bermain — cara terbaik untuk kanak-kanak!'
                      : 'Learning through play — the best way for children!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                _ApprovedBadge(
                  label: isMalay ? '✅ Diluluskan Guru' : '✅ Teacher Approved',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedBadge extends ConsumerWidget {
  const _ApprovedBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────
class _SectionLabel extends ConsumerWidget {
  const _SectionLabel({
    required this.emoji,
    required this.label,
    required this.color,
  });
  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Game card ──────────────────────────────────────────────────────────────────
class _GameCard extends ConsumerStatefulWidget {
  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.completedCount,
    required this.learningObjective,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final int completedCount;
  final String learningObjective;
  final VoidCallback onTap;

  @override
  ConsumerState<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<_GameCard>
    with TickerProviderStateMixin {
  // Press feedback — same tactile language as BigModeButton/BadgeCard.
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  // One-shot entrance: fades and slides the card up when it first appears,
  // giving the hub list a lively, staggered-feeling reveal.
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final curved = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _entryFade = curved;
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curved);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (context, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF123A7A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A7A9A),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.school_rounded, size: 12, color: color),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.learningObjective,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.completedCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⭐ ${widget.completedCount} selesai',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFAA00),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 28),
            ],
          ),
        ),
      ),
    ),
      ),
    ),
      ),
    );
  }
}

// ── Tip card ───────────────────────────────────────────────────────────────────
class _TipCard extends ConsumerWidget {
  const _TipCard({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = isMalay
        ? [
            '🎯 Main bersama anak 10–15 minit sehari',
            '🌟 Puji usaha, bukan hanya jawapan betul',
            '🔄 Ulangi permainan yang disukai anak',
            '📖 Hubungkan permainan dengan buku cerita',
            '💬 Tanya anak: "Apa yang kamu belajar hari ini?"',
          ]
        : [
            '🎯 Play with your child 10–15 minutes a day',
            '🌟 Praise effort, not just correct answers',
            '🔄 Repeat games your child enjoys most',
            '📖 Connect games to picture books',
            '💬 Ask your child: "What did you learn today?"',
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1EA7FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                t,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF123A7A),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
