import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers/app_state.dart';

import '../models/app_language.dart';
import '../models/challenge.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'jawi_asas_screen.dart';
import 'learn_body_parts_screen.dart';
import 'learn_letters_screen.dart';
import 'learn_numbers_screen.dart';
import 'math_practice_screen.dart';
import 'coloring_screen.dart';
import 'games_hub_screen.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  static const routeName = '/learning-path';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final isMalay = progress.language == AppLanguage.malay;

    final modules = _buildModules(isMalay, progress);

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        title: Text(
          isMalay ? 'Laluan Pembelajaran' : 'Learning Path',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: AnimationLimiter(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _SyllabusHeader(isMalay: isMalay, progress: progress),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 420),
                    child: SlideAnimation(
                      verticalOffset: 36,
                      curve: Curves.easeOutCubic,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ModuleCard(
                            module: modules[i],
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(modules[i].route),
                          ),
                        ),
                      ),
                    ),
                  ),
                  childCount: modules.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ModuleInfo> _buildModules(bool isMalay, ProgressService progress) {
    return [
      _ModuleInfo(
        emoji: '🔢',
        title: isMalay ? 'Nombor 1–100' : 'Numbers 1–100',
        objective: isMalay
            ? 'Kenal, kira dan sebut nombor 1 hingga 100'
            : 'Recognize, count and pronounce numbers 1–100',
        recommendedAge: '3–7',
        color: const Color(0xFFFF6B6B),
        levels: isMalay
            ? ['Nombor 1–10', 'Nombor 11–20', 'Nombor 21–50', 'Nombor 51–100']
            : [
                'Numbers 1–10',
                'Numbers 11–20',
                'Numbers 21–50',
                'Numbers 51–100',
              ],
        completed: progress.getModuleLessons('numbers'),
        total: 100,
        lastLesson: progress.getLastLesson('numbers'),
        route: LearnNumbersScreen.routeName,
        moduleId: 'numbers',
      ),
      _ModuleInfo(
        emoji: '🔤',
        title: isMalay ? 'Huruf A–Z' : 'Letters A–Z',
        objective: isMalay
            ? 'Kenal huruf, bunyi fonik dan contoh perkataan'
            : 'Recognize letters, phonics, and example words',
        recommendedAge: '3–7',
        color: const Color(0xFF1DD1A1),
        levels: isMalay
            ? ['Huruf A–F', 'Huruf G–L', 'Huruf M–R', 'Huruf S–Z']
            : ['Letters A–F', 'Letters G–L', 'Letters M–R', 'Letters S–Z'],
        completed: progress.getModuleLessons('letters'),
        total: 26,
        lastLesson: progress.getLastLesson('letters'),
        route: LearnLettersScreen.routeName,
        moduleId: 'letters',
      ),
      _ModuleInfo(
        emoji: '🌙',
        title: isMalay ? 'Jawi Asas حروف' : 'Basic Jawi حروف',
        objective: isMalay
            ? 'Kenal 28 huruf Jawi — khas anak Muslim'
            : 'Recognize the 28 Jawi alphabet letters',
        recommendedAge: '4–7',
        color: const Color(0xFF00B894),
        levels: isMalay
            ? ['Huruf 1–7', 'Huruf 8–14', 'Huruf 15–21', 'Huruf 22–28']
            : ['Letters 1–7', 'Letters 8–14', 'Letters 15–21', 'Letters 22–28'],
        completed: progress.getModuleLessons('jawi'),
        total: 28,
        lastLesson: progress.getLastLesson('jawi'),
        route: JawiAsasScreen.routeName,
        moduleId: 'jawi',
      ),
      _ModuleInfo(
        emoji: '🧍',
        title: isMalay ? 'Anggota Badan' : 'Body Parts',
        objective: isMalay
            ? 'Kenal 14 anggota badan dalam 5 bahasa'
            : 'Learn 14 body parts in 5 languages',
        recommendedAge: '3–6',
        color: const Color(0xFFE84393),
        levels: isMalay
            ? ['Kepala & Muka', 'Tangan & Kaki', 'Badan']
            : ['Head & Face', 'Hands & Feet', 'Body'],
        completed: progress.getModuleLessons('bodyparts'),
        total: 14,
        lastLesson: progress.getLastLesson('bodyparts'),
        route: LearnBodyPartsScreen.routeName,
        moduleId: 'bodyparts',
      ),
      _ModuleInfo(
        emoji: '🧮',
        title: isMalay ? 'Matematik Asas' : 'Basic Math',
        objective: isMalay
            ? 'Tambah, tolak, darab dan bahagi dengan soalan pelbagai pilihan'
            : 'Addition, subtraction, multiplication & division with MCQ',
        recommendedAge: '4–7',
        color: const Color(0xFF6C5CE7),
        levels: isMalay
            ? ['Mudah (1–10)', 'Sederhana (1–20)', 'Susah (1–50)']
            : ['Easy (1–10)', 'Medium (1–20)', 'Hard (1–50)'],
        completed: progress.getModuleLessons('math'),
        total: 50,
        lastLesson: progress.getLastLesson('math'),
        route: MathPracticeScreen.routeName,
        moduleId: 'math',
      ),
      _ModuleInfo(
        emoji: '🎨',
        title: isMalay ? 'Jom Mewarna!' : 'Let\'s Colour!',
        objective: isMalay
            ? 'Warnakan gambar haiwan, buah dan bentuk — kreativiti bebas'
            : 'Colour animals, fruits, and shapes — free creativity',
        recommendedAge: '3–7',
        color: const Color(0xFFFF9F43),
        levels: isMalay
            ? ['Haiwan', 'Buah-buahan', 'Bentuk', 'Pengangkutan']
            : ['Animals', 'Fruits', 'Shapes', 'Transport'],
        completed: progress.coloringSessions,
        total: 40,
        lastLesson: '',
        route: ColoringScreen.routeName,
        moduleId: 'coloring',
      ),
      _ModuleInfo(
        emoji: '🎮',
        title: isMalay ? 'Permainan & Aktiviti' : 'Games & Activities',
        objective: isMalay
            ? 'Memori, Tren Nombor, Tren Huruf & Teka-Teki'
            : 'Memory, Number Train, Letter Train & Puzzle',
        recommendedAge: '3–7',
        color: const Color(0xFF7C4DFF),
        levels: isMalay
            ? ['Tren Nombor', 'Tren Huruf', 'Permainan Memori', 'Teka-Teki']
            : ['Number Train', 'Letter Train', 'Memory Game', 'Puzzle'],
        completed:
            progress.countFor(ChallengeMode.memory) +
            progress.countFor(ChallengeMode.numberTrain) +
            progress.countFor(ChallengeMode.letterTrain) +
            progress.countFor(ChallengeMode.puzzle),
        total: 60,
        lastLesson: '',
        route: GamesHubScreen.routeName,
        moduleId: 'games',
      ),
    ];
  }
}

// ── Header banner ──────────────────────────────────────────────────────────────
class _SyllabusHeader extends ConsumerWidget {
  const _SyllabusHeader({required this.isMalay, required this.progress});
  final bool isMalay;
  final ProgressService progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.skyBlue, Color(0xFF7A5CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('📚', style: TextStyle(fontSize: 52)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMalay ? 'Sukatan Pembelajaran' : 'Learning Syllabus',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMalay
                      ? 'Umur 3–7 tahun • Program berstruktur'
                      : 'Age 3–7 • Structured preschool program',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _HeaderStat(
                      label: isMalay ? 'Bintang' : 'Stars',
                      value: '⭐ ${progress.stars}',
                    ),
                    const SizedBox(width: 16),
                    _HeaderStat(
                      label: isMalay ? 'Selesai' : 'Done',
                      value: '✅ ${progress.completedChallenges}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends ConsumerWidget {
  const _HeaderStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Module card ────────────────────────────────────────────────────────────────
class _ModuleCard extends ConsumerStatefulWidget {
  const _ModuleCard({required this.module, required this.onTap});
  final _ModuleInfo module;
  final VoidCallback onTap;

  @override
  ConsumerState<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends ConsumerState<_ModuleCard>
    with SingleTickerProviderStateMixin {
  // Press feedback shared with the rest of the app's tactile language
  // (see BigModeButton / BadgeCard) — a gentle scale-down on press.
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

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
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final pct = module.total > 0
        ? (module.completed / module.total).clamp(0.0, 1.0)
        : 0.0;
    final pctLabel = '${(pct * 100).round()}%';

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (context, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: module.color.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ──
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: module.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'module-emoji-${module.route}',
                        // Module → screen continuity: this emoji visually
                        // "flies" into the destination screen's app bar.
                        flightShuttleBuilder:
                            (context, animation, direction, fromCtx, toCtx) {
                          final fromHero =
                              direction == HeroFlightDirection.push
                                  ? fromCtx.widget
                                  : toCtx.widget;
                          return ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 0.85).animate(
                              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                            ),
                            child: fromHero is Hero ? fromHero.child : const SizedBox.shrink(),
                          );
                        },
                        child: Text(
                          module.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.child_care_rounded,
                              size: 13,
                              color: module.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Age ${module.recommendedAge}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: module.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: module.color,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      pctLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Objective ──
              Text(
                module.objective,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5A5A7A),
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // ── Progress bar ──
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: module.color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(module.color),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${module.completed} / ${module.total}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: module.color,
                    ),
                  ),
                  Text(
                    module.lastLesson.isNotEmpty
                        ? '📌 ${module.lastLesson}'
                        : '▶ Tap to start',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9090A8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Levels ──
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: module.levels
                    .map(
                      (l) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: module.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: module.color,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}

class _ModuleInfo {
  const _ModuleInfo({
    required this.emoji,
    required this.title,
    required this.objective,
    required this.recommendedAge,
    required this.color,
    required this.levels,
    required this.completed,
    required this.total,
    required this.lastLesson,
    required this.route,
    required this.moduleId,
  });

  final String emoji;
  final String title;
  final String objective;
  final String recommendedAge;
  final Color color;
  final List<String> levels;
  final int completed;
  final int total;
  final String lastLesson;
  final String route;
  final String moduleId;
}
