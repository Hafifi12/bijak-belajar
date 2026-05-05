import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../utils/app_text.dart';
import '../models/train_mode.dart';
import '../models/app_language.dart';
import '../theme/app_theme.dart';
import '../widgets/big_mode_button.dart';
import '../widgets/star_counter.dart';
import 'jawi_asas_screen.dart';
import 'learn_body_parts_screen.dart';
import 'learn_letters_screen.dart';
import 'learn_numbers_screen.dart';
import 'math_practice_screen.dart';
import 'memory_category_screen.dart';
import 'puzzle_screen.dart';
import 'parent_settings_screen.dart';
import 'progress_screen.dart';
import 'train_sort_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final language = context.watch<ProgressService>().language;
    final isMalay = language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // ── Curved header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: _HomeHeader(isMalay: isMalay),
          ),

          // ── Content ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ─── LEARN ───
                _SectionLabel(
                  emoji: '📖',
                  label: isMalay ? 'Belajar' : 'Learn',
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 10),
                BigModeButton(
                  emoji: '🔢',
                  title: isMalay ? 'Nombor 1–100' : 'Numbers 1–100',
                  subtitle: isMalay
                      ? 'Kenal nombor dengan titik & perkataan'
                      : 'Learn numbers with dots & words',
                  icon: Icons.looks_one_rounded,
                  color: const Color(0xFFFF6B6B),
                  onTap: () => Navigator.of(context).pushNamed(LearnNumbersScreen.routeName),
                ),
                const SizedBox(height: 10),
                BigModeButton(
                  emoji: '🔤',
                  title: isMalay ? 'Huruf A–Z' : 'Letters A–Z',
                  subtitle: isMalay
                      ? 'Kenal semua 26 huruf dengan contoh'
                      : 'All 26 letters with examples',
                  icon: Icons.abc_rounded,
                  color: const Color(0xFF1DD1A1),
                  onTap: () => Navigator.of(context).pushNamed(LearnLettersScreen.routeName),
                ),
                const SizedBox(height: 10),
                BigModeButton(
                  emoji: '🌙',
                  title: isMalay ? 'Jawi Asas حروف' : 'Jawi Letters حروف',
                  subtitle: isMalay
                      ? 'Kenal 28 huruf Jawi — khas anak Muslim'
                      : '28 Jawi letters for Muslim children',
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFF00B894),
                  onTap: () => Navigator.of(context).pushNamed(JawiAsasScreen.routeName),
                ),
                const SizedBox(height: 10),
                BigModeButton(
                  emoji: '🧍',
                  title: isMalay ? 'Anggota Badan' : 'Body Parts',
                  subtitle: isMalay
                      ? 'Kenal kepala, tangan, kaki dan lain-lain'
                      : 'Learn head, hands, legs and more',
                  icon: Icons.accessibility_new_rounded,
                  color: const Color(0xFFE84393),
                  onTap: () => Navigator.of(context).pushNamed(LearnBodyPartsScreen.routeName),
                ),

                const SizedBox(height: 22),

                // ─── TRAIN ───
                _SectionLabel(
                  emoji: '🚂',
                  label: isMalay ? 'Latihan Susun' : 'Sort & Train',
                  color: const Color(0xFFFF9F43),
                ),
                const SizedBox(height: 10),
                BigModeButton(
                  emoji: '🔢',
                  title: AppText.trainTitle(TrainMode.numbers, language),
                  subtitle: isMalay
                      ? 'Susun nombor mengikut turutan betul'
                      : 'Sort number cars in the right order',
                  icon: Icons.filter_1_rounded,
                  color: TrainMode.numbers.color,
                  onTap: () => Navigator.of(context).pushNamed(
                    TrainSortScreen.routeName,
                    arguments: const TrainSortArgs(mode: TrainMode.numbers),
                  ),
                ),
                const SizedBox(height: 10),
                BigModeButton(
                  emoji: '🔤',
                  title: AppText.trainTitle(TrainMode.letters, language),
                  subtitle: isMalay
                      ? 'Susun huruf mengikut susunan A–Z'
                      : 'Sort letter cars in A–Z order',
                  icon: Icons.sort_by_alpha_rounded,
                  color: TrainMode.letters.color,
                  onTap: () => Navigator.of(context).pushNamed(
                    TrainSortScreen.routeName,
                    arguments: const TrainSortArgs(mode: TrainMode.letters),
                  ),
                ),
                const SizedBox(height: 10),
                BigModeButton(
                  emoji: '🧮',
                  title: isMalay ? 'Latihan Matematik' : 'Math Practice',
                  subtitle: isMalay
                      ? 'Tambah, tolak, darab & bahagi'
                      : 'Addition, subtraction, multiply & divide',
                  icon: Icons.calculate_rounded,
                  color: const Color(0xFF6C5CE7),
                  onTap: () => Navigator.of(context).pushNamed(MathPracticeScreen.routeName),
                ),

                const SizedBox(height: 22),

                // ─── GAMES ───
                _SectionLabel(
                  emoji: '🎮',
                  label: isMalay ? 'Permainan' : 'Games',
                  color: const Color(0xFF7C4DFF),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _GameCard(
                        emoji: '🃏',
                        label: isMalay ? 'Memori' : 'Memory',
                        color: const Color(0xFF7E57C2),
                        onTap: () => Navigator.of(context)
                            .pushNamed(MemoryCategoryScreen.routeName),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GameCard(
                        emoji: '🧩',
                        label: isMalay ? 'Teka-Teki' : 'Puzzle',
                        color: const Color(0xFF00897B),
                        onTap: () => Navigator.of(context)
                            .pushNamed(PuzzleScreen.routeName),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Curved header with mascot ──────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background wave
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: 230,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF5B2FCC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Decorative blobs
        Positioned(
          top: -30, right: -30,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 40, right: 60,
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: title + settings icons
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '✨ Bijak Belajar',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          _HeaderIcon(
                            icon: Icons.insights_rounded,
                            onTap: () => Navigator.of(context)
                                .pushNamed(ProgressScreen.routeName),
                          ),
                          const SizedBox(width: 8),
                          _HeaderIcon(
                            icon: Icons.settings_rounded,
                            onTap: () => Navigator.of(context)
                                .pushNamed(ParentSettingsScreen.routeName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isMalay
                            ? 'Apa yang boleh kamu\nbelajar hari ini? 🌟'
                            : 'What can you learn\ntoday? 🌟',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const StarCounter(large: true),
                    ],
                  ),
                ),
                // Mascot
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text('🦉', style: TextStyle(fontSize: 72)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5, size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 60,
      size.width, size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Game card (2-column grid) ─────────────────────────────────────────────
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
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c, c.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: c.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -15, right: -15,
                child: Container(
                  width: 70, height: 70,
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
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 44)),
                    const SizedBox(height: 6),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
