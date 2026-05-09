import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../models/train_mode.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/star_counter.dart';
import 'coloring_screen.dart';
import 'games_hub_screen.dart';
import 'jawi_asas_screen.dart';
import 'learn_body_parts_screen.dart';
import 'learn_letters_screen.dart';
import 'learn_numbers_screen.dart';
import 'learning_path_screen.dart';
import 'math_practice_screen.dart';
import 'memory_category_screen.dart';
import 'parent_gate_screen.dart';
import 'progress_screen.dart';
import 'puzzle_screen.dart';
import 'train_sort_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final isMalay = progress.language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      bottomNavigationBar: _BottomBar(isMalay: isMalay),
      body: BijakScene(
        topColor: AppTheme.skyBlue,
        bottomColor: AppTheme.lightBlue,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _HomeHeader(isMalay: isMalay, progress: progress)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ─── LEARN section ──────────────────────────────────────
                  _SectionChip(
                    emoji: '📖',
                    label: isMalay ? 'BELAJAR' : 'LEARN',
                    color: AppTheme.skyBlue,
                  ),
                  const SizedBox(height: 12),
                  _ModuleGrid(children: [
                    _ModuleTile(
                      emoji: '🔢',
                      symbol: '1\n2\n3',
                      title: isMalay ? 'Nombor' : 'Numbers',
                      sub: '1 – 100',
                      color: AppTheme.appleRed,
                      done: progress.getModuleLessons('numbers'),
                      total: 100,
                      onTap: () => Navigator.of(context)
                          .pushNamed(LearnNumbersScreen.routeName),
                    ),
                    _ModuleTile(
                      emoji: '🔤',
                      symbol: 'A\nB\nC',
                      title: isMalay ? 'Huruf' : 'Letters',
                      sub: 'A – Z',
                      color: AppTheme.turquoise,
                      done: progress.getModuleLessons('letters'),
                      total: 26,
                      onTap: () => Navigator.of(context)
                          .pushNamed(LearnLettersScreen.routeName),
                    ),
                    _ModuleTile(
                      emoji: '🌙',
                      symbol: 'ا\nب\nت',
                      title: isMalay ? 'Jawi' : 'Jawi',
                      sub: isMalay ? '28 Huruf' : '28 Letters',
                      color: AppTheme.leafGreen,
                      done: progress.getModuleLessons('jawi'),
                      total: 28,
                      onTap: () => Navigator.of(context)
                          .pushNamed(JawiAsasScreen.routeName),
                    ),
                    _ModuleTile(
                      emoji: '🧍',
                      symbol: '👦',
                      title: isMalay ? 'Anggota\nBadan' : 'Body\nParts',
                      sub: isMalay ? '14 Bahagian' : '14 Parts',
                      color: AppTheme.purple,
                      done: progress.getModuleLessons('bodyparts'),
                      total: 14,
                      onTap: () => Navigator.of(context)
                          .pushNamed(LearnBodyPartsScreen.routeName),
                    ),
                    _ModuleTile(
                      emoji: '🧮',
                      symbol: '+ −\n× ÷',
                      title: isMalay ? 'Matematik' : 'Math',
                      sub: isMalay ? 'Tambah & Tolak' : 'Add & Subtract',
                      color: const Color(0xFFFF9F1C),
                      done: progress.getModuleLessons('math'),
                      total: 50,
                      onTap: () => Navigator.of(context)
                          .pushNamed(MathPracticeScreen.routeName),
                    ),
                    _ModuleTile(
                      emoji: '🎨',
                      symbol: '🖌️',
                      title: isMalay ? 'Mewarna' : 'Colour',
                      sub: isMalay ? 'Lukis & Warna' : 'Draw & Paint',
                      color: const Color(0xFFFF9F43),
                      done: progress.coloringSessions,
                      total: 40,
                      onTap: () => Navigator.of(context)
                          .pushNamed(ColoringScreen.routeName),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ─── GAMES section ──────────────────────────────────────
                  _SectionChip(
                    emoji: '🎮',
                    label: isMalay ? 'PERMAINAN' : 'GAMES',
                    color: AppTheme.purple,
                  ),
                  const SizedBox(height: 12),
                  _GamesRow(isMalay: isMalay),

                  const SizedBox(height: 10),

                  // Train buttons
                  _TrainButton(
                    emoji: '🚂',
                    title: isMalay ? 'Tren Nombor' : 'Number Train',
                    sub: isMalay
                        ? 'Susun nombor dalam susunan betul'
                        : 'Sort numbers in the correct order',
                    color: TrainMode.numbers.color,
                    onTap: () => Navigator.of(context).pushNamed(
                      TrainSortScreen.routeName,
                      arguments: const TrainSortArgs(mode: TrainMode.numbers),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TrainButton(
                    emoji: '🚃',
                    title: isMalay ? 'Tren Huruf' : 'Letter Train',
                    sub: isMalay
                        ? 'Susun huruf A hingga Z dengan betul'
                        : 'Sort letters from A to Z',
                    color: TrainMode.letters.color,
                    onTap: () => Navigator.of(context).pushNamed(
                      TrainSortScreen.routeName,
                      arguments: const TrainSortArgs(mode: TrainMode.letters),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Games hub button
                  _BigNavButton(
                    emoji: '🎮',
                    title: isMalay ? 'Semua Permainan' : 'All Games & Activities',
                    sub: isMalay
                        ? 'Memori, Teka-Teki, Tren Nombor & Huruf'
                        : 'Memory, Puzzle, Number Train & Letter Train',
                    color: AppTheme.purple,
                    onTap: () =>
                        Navigator.of(context).pushNamed(GamesHubScreen.routeName),
                  ),

                  const SizedBox(height: 24),

                  // ─── SYLLABUS section ───────────────────────────────────
                  _SectionChip(
                    emoji: '📚',
                    label: isMalay ? 'LALUAN PEMBELAJARAN' : 'LEARNING PATH',
                    color: AppTheme.skyBlue,
                  ),
                  const SizedBox(height: 12),
                  _SyllabusCard(isMalay: isMalay, progress: progress),

                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isMalay, required this.progress});
  final bool isMalay;
  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          children: [
            // ── Top bar ──
            Row(
              children: [
                const BijakLogoText(compact: true),
                const Spacer(),
                _IconBtn(
                  icon: Icons.insights_rounded,
                  onTap: () =>
                      Navigator.of(context).pushNamed(ProgressScreen.routeName),
                ),
                const SizedBox(width: 8),
                _IconBtn(
                  icon: Icons.settings_rounded,
                  onTap: () => Navigator.of(context)
                      .pushNamed(ParentGateScreen.routeName),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Welcome card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.ink.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const BijakBookMascot(size: 78),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalay ? '👋 Hai, anak bijak!' : '👋 Hi, smart learner!',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMalay
                              ? 'Apa yang kita nak belajar hari ini? 🌟'
                              : 'What shall we learn today? 🌟',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A6A9A),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _LearningSteps(isMalay: isMalay),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const StarCounter(large: false),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ContinueLearningBanner(isMalay: isMalay, progress: progress),
          ],
        ),
      ),
    );
  }
}

class _ContinueLearningBanner extends StatelessWidget {
  const _ContinueLearningBanner({required this.isMalay, required this.progress});
  final bool isMalay;
  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    // Find the module with most progress that isn't complete
    final modules = [
      _ContinueModule('numbers', '🔢', isMalay ? 'Nombor' : 'Numbers',
          progress.getModuleLessons('numbers'), 100, AppTheme.appleRed,
          LearnNumbersScreen.routeName),
      _ContinueModule('letters', '🔤', isMalay ? 'Huruf' : 'Letters',
          progress.getModuleLessons('letters'), 26, AppTheme.turquoise,
          LearnLettersScreen.routeName),
      _ContinueModule('jawi', '🌙', 'Jawi',
          progress.getModuleLessons('jawi'), 28, AppTheme.leafGreen,
          JawiAsasScreen.routeName),
      _ContinueModule('bodyparts', '🧍', isMalay ? 'Anggota Badan' : 'Body Parts',
          progress.getModuleLessons('bodyparts'), 14, AppTheme.purple,
          LearnBodyPartsScreen.routeName),
    ];

    // Pick module with progress > 0 and not 100%
    final active = modules
        .where((m) => m.done > 0 && m.done < m.total)
        .toList()
      ..sort((a, b) => b.done.compareTo(a.done));

    if (active.isEmpty) return const SizedBox.shrink();

    final m = active.first;
    final pct = (m.done / m.total).clamp(0.0, 1.0);

    return Semantics(
      button: true,
      label: 'Continue learning ${m.name}. ${m.done} of ${m.total} complete.',
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(m.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [m.color, m.color.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: m.color.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              Text(m.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMalay ? '▶ Teruskan Belajar' : '▶ Continue Learning',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                    Text(
                      m.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text(
                    '${m.done}/${m.total}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueModule {
  const _ContinueModule(this.id, this.emoji, this.name, this.done, this.total, this.color, this.route);
  final String id, emoji, name, route;
  final int done, total;
  final Color color;
}

class _LearningSteps extends StatelessWidget {
  const _LearningSteps({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (emoji: '👁', label: isMalay ? 'Lihat' : 'See'),
      (emoji: '🔊', label: isMalay ? 'Dengar' : 'Hear'),
      (emoji: '✋', label: isMalay ? 'Buat' : 'Do'),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepDot(emoji: steps[i].emoji, label: steps[i].label),
          if (i < steps.length - 1)
            const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFFB0B8D8)),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.sunnyYellow,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section chip
// ─────────────────────────────────────────────────────────────────────────────
class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.emoji,
    required this.label,
    required this.color,
  });
  final String emoji;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module grid (3-column for learn modules)
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.82,
      children: children,
    );
  }
}

class _ModuleTile extends StatefulWidget {
  const _ModuleTile({
    required this.emoji,
    required this.symbol,
    required this.title,
    required this.sub,
    required this.color,
    required this.done,
    required this.total,
    required this.onTap,
  });
  final String emoji;
  final String symbol;
  final String title;
  final String sub;
  final Color color;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  State<_ModuleTile> createState() => _ModuleTileState();
}

class _ModuleTileState extends State<_ModuleTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.total > 0
        ? (widget.done / widget.total).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Coloured top ──
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -14, right: -14,
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      widget.symbol,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        shadows: [Shadow(color: Color(0x44000000), blurRadius: 4)],
                      ),
                    ),
                    Positioned(
                      bottom: 4, right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: widget.color,
                        ),
                      ),
                      const Spacer(),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor:
                              widget.color.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Games row (Memory + Puzzle side by side)
// ─────────────────────────────────────────────────────────────────────────────
class _GamesRow extends StatelessWidget {
  const _GamesRow({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GameCard(
            emoji: '🃏',
            label: isMalay ? 'Permainan\nMemori' : 'Memory\nGame',
            color: AppTheme.purple,
            onTap: () => Navigator.of(context)
                .pushNamed(MemoryCategoryScreen.routeName),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GameCard(
            emoji: '🧩',
            label: isMalay ? 'Teka-Teki\nGambar' : 'Picture\nPuzzle',
            color: const Color(0xFF00897B),
            onTap: () => Navigator.of(context).pushNamed(PuzzleScreen.routeName),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatefulWidget {
  const _GameCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: 115,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -12, right: -12,
                child: Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Train button (wide pill)
// ─────────────────────────────────────────────────────────────────────────────
class _TrainButton extends StatelessWidget {
  const _TrainButton({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.22),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ink,
                      ),
                    ),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8090B0),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Big nav button (full width highlight)
// ─────────────────────────────────────────────────────────────────────────────
class _BigNavButton extends StatelessWidget {
  const _BigNavButton({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      elevation: 5,
      shadowColor: color.withValues(alpha: 0.35),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      sub,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Syllabus summary card (Learning Path preview)
// ─────────────────────────────────────────────────────────────────────────────
class _SyllabusCard extends StatelessWidget {
  const _SyllabusCard({required this.isMalay, required this.progress});
  final bool isMalay;
  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    final totalStars = progress.stars;
    final totalDone = progress.completedChallenges;

    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed(LearningPathScreen.routeName),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.skyBlue, Color(0xFF7A5CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppTheme.skyBlue.withValues(alpha: 0.38),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('📚', style: TextStyle(fontSize: 52)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMalay ? 'Laluan Pembelajaran' : 'Learning Path',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isMalay
                        ? 'Sukatan berstruktur • Umur 3–7 tahun'
                        : 'Structured syllabus • Age 3–7',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatPill(label: '⭐ $totalStars ${isMalay ? "bintang" : "stars"}'),
                      const SizedBox(width: 8),
                      _StatPill(label: '✅ $totalDone ${isMalay ? "selesai" : "done"}'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final items = [
      _NavItem(icon: Icons.home_rounded, label: isMalay ? 'Utama' : 'Home',
          selected: true, onTap: () {}),
      _NavItem(icon: Icons.route_rounded, label: isMalay ? 'Sukatan' : 'Syllabus',
          selected: false,
          onTap: () => Navigator.of(context).pushNamed(LearningPathScreen.routeName)),
      _NavItem(icon: Icons.insights_rounded, label: isMalay ? 'Kemajuan' : 'Progress',
          selected: false,
          onTap: () => Navigator.of(context).pushNamed(ProgressScreen.routeName)),
      _NavItem(
        icon: progress.voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        label: isMalay ? 'Suara' : 'Voice',
        selected: progress.voiceEnabled,
        onTap: () => progress.setVoiceEnabled(!progress.voiceEnabled),
      ),
      _NavItem(icon: Icons.settings_rounded, label: isMalay ? 'Tetapan' : 'Settings',
          selected: false,
          onTap: () => Navigator.of(context).pushNamed(ParentGateScreen.routeName)),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: items.map((item) => Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: item.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: item.selected
                      ? AppTheme.sunnyYellow.withValues(alpha: 0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon,
                      color: item.selected ? AppTheme.ink : const Color(0xFF8898C8),
                      size: 22),
                    const SizedBox(height: 3),
                    Text(item.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: item.selected ? AppTheme.ink : const Color(0xFF8898C8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
