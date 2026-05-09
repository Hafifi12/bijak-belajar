import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/badge_data.dart';
import '../models/app_language.dart';
import '../models/challenge.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import '../widgets/badge_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  static const routeName = '/progress';

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
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
    final progress = context.watch<ProgressService>();
    final language = progress.language;
    final isMalay = language == AppLanguage.malay;

    final modules = _buildModules(isMalay, progress);
    final bestModule = _bestModule(modules);
    final suggestedNext = _suggestedNext(modules, isMalay);

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
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
                child: _InsightRow(
                  bestModule: bestModule,
                  suggestedNext: suggestedNext,
                  isMalay: isMalay,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  emoji: '📊',
                  title: isMalay
                      ? 'Kemajuan Mengikut Modul'
                      : 'Progress by Module',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _ModuleProgressGrid(modules: modules),
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

  List<_ModuleData> _buildModules(bool isMalay, ProgressService progress) {
    return [
      _ModuleData(
        emoji: '🔢',
        name: isMalay ? 'Nombor' : 'Numbers',
        done: progress.getModuleLessons('numbers'),
        total: 100,
        lastLesson: progress.getLastLesson('numbers'),
        color: AppTheme.appleRed,
      ),
      _ModuleData(
        emoji: '🔤',
        name: isMalay ? 'Huruf' : 'Letters',
        done: progress.getModuleLessons('letters'),
        total: 26,
        lastLesson: progress.getLastLesson('letters'),
        color: AppTheme.turquoise,
      ),
      _ModuleData(
        emoji: '🌙',
        name: 'Jawi',
        done: progress.getModuleLessons('jawi'),
        total: 28,
        lastLesson: progress.getLastLesson('jawi'),
        color: AppTheme.leafGreen,
      ),
      _ModuleData(
        emoji: '🧍',
        name: isMalay ? 'Anggota\nBadan' : 'Body\nParts',
        done: progress.getModuleLessons('bodyparts'),
        total: 14,
        lastLesson: progress.getLastLesson('bodyparts'),
        color: AppTheme.purple,
      ),
      _ModuleData(
        emoji: '🧮',
        name: isMalay ? 'Matematik' : 'Math',
        done: progress.getModuleLessons('math'),
        total: 50,
        lastLesson: progress.getLastLesson('math'),
        color: const Color(0xFFFF9F1C),
      ),
      _ModuleData(
        emoji: '🎨',
        name: isMalay ? 'Mewarna' : 'Colour',
        done: progress.coloringSessions,
        total: 40,
        lastLesson: '',
        color: const Color(0xFFFF9F43),
      ),
    ];
  }

  _ModuleData? _bestModule(List<_ModuleData> modules) {
    return modules.where((m) => m.done > 0).fold<_ModuleData?>(null, (best, m) {
      if (best == null) {
        return m;
      }
      return m.pct > best.pct ? m : best;
    });
  }

  String _suggestedNext(List<_ModuleData> modules, bool isMalay) {
    final incomplete = modules.where((m) => m.done < m.total).toList()
      ..sort((a, b) => b.done.compareTo(a.done));
    if (incomplete.isEmpty) {
      return isMalay ? 'Semua modul selesai! 🎉' : 'All modules complete! 🎉';
    }
    final next = incomplete.first;
    return '${next.emoji} ${next.name.replaceAll('\n', ' ')} — ${next.done + 1}/${next.total}';
  }
}

class _ModuleData {
  const _ModuleData({
    required this.emoji,
    required this.name,
    required this.done,
    required this.total,
    required this.lastLesson,
    required this.color,
  });
  final String emoji, name, lastLesson;
  final int done, total;
  final Color color;
  double get pct => total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
}

// ── Star Hero Banner ──────────────────────────────────────────────────────────
class _StarHeroBanner extends StatefulWidget {
  const _StarHeroBanner({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  State<_StarHeroBanner> createState() => _StarHeroBannerState();
}

class _StarHeroBannerState extends State<_StarHeroBanner>
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

class _HeroBubble extends StatelessWidget {
  const _HeroBubble({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value, label, icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
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

// ── Insight Row ────────────────────────────────────────────────────────────────
class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.bestModule,
    required this.suggestedNext,
    required this.isMalay,
  });
  final _ModuleData? bestModule;
  final String suggestedNext;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (bestModule != null) ...[
          Expanded(
            child: _InsightCard(
              icon: '🏅',
              title: isMalay ? 'Terbaik' : 'Best At',
              body:
                  '${bestModule!.emoji} ${bestModule!.name.replaceAll('\n', ' ')} (${(bestModule!.pct * 100).round()}%)',
              color: bestModule!.color,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: _InsightCard(
            icon: '💡',
            title: isMalay ? 'Cadangan Seterusnya' : 'Suggested Next',
            body: suggestedNext,
            color: AppTheme.skyBlue,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
  final String icon, title, body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.emoji, required this.title});
  final String emoji, title;

  @override
  Widget build(BuildContext context) {
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

// ── Module Progress Grid with ring indicators ──────────────────────────────────
class _ModuleProgressGrid extends StatelessWidget {
  const _ModuleProgressGrid({required this.modules});
  final List<_ModuleData> modules;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: modules.map((m) => _ModuleRingTile(module: m)).toList(),
    );
  }
}

class _ModuleRingTile extends StatelessWidget {
  const _ModuleRingTile({required this.module});
  final _ModuleData module;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${module.name.replaceAll('\n', ' ')}: ${module.done} of ${module.total} complete.',
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: module.color.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: module.pct,
                      strokeWidth: 5,
                      backgroundColor: module.color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(module.color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(module.emoji, style: const TextStyle(fontSize: 26)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              module.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.ink,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${module.done}/${module.total}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: module.color,
              ),
            ),
            if (module.pct >= 1.0)
              const Text('✅', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ── Activity Stats ─────────────────────────────────────────────────────────────
class _ActivityStatsRow extends StatelessWidget {
  const _ActivityStatsRow({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _ActivityStat(
        '🚂',
        isMalay ? 'Tren\nNombor' : 'Number\nTrain',
        progress.countFor(ChallengeMode.numberTrain),
        AppTheme.appleRed,
      ),
      _ActivityStat(
        '🚃',
        isMalay ? 'Tren\nHuruf' : 'Letter\nTrain',
        progress.countFor(ChallengeMode.letterTrain),
        AppTheme.turquoise,
      ),
      _ActivityStat(
        '🃏',
        isMalay ? 'Permainan\nMemori' : 'Memory\nGame',
        progress.countFor(ChallengeMode.memory),
        AppTheme.purple,
      ),
      _ActivityStat(
        '🧩',
        isMalay ? 'Teka-Teki\nGambar' : 'Puzzle\nGame',
        progress.countFor(ChallengeMode.puzzle),
        AppTheme.leafGreen,
      ),
    ];
    return Row(
      children: stats
          .map(
            (s) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: s.color.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(s.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      '${s.count}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: s.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.label,
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
          )
          .toList(),
    );
  }
}

class _ActivityStat {
  const _ActivityStat(this.emoji, this.label, this.count, this.color);
  final String emoji, label;
  final int count;
  final Color color;
}
