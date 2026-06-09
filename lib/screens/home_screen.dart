import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_language.dart';
import '../models/quest.dart';
import '../providers/app_state.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/badge_unlock_overlay.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/xp_popup.dart';
import 'coloring_screen.dart';
import 'daily_reward_screen.dart';
import 'games_hub_screen.dart';
import 'jawi_asas_screen.dart';
import 'learn_body_parts_screen.dart';
import 'learn_letters_screen.dart';
import 'learn_numbers_screen.dart';
import 'learning_path_screen.dart';
import 'level_up_screen.dart';
import 'math_practice_screen.dart';
import 'parent_gate_screen.dart';
import 'progress_screen.dart';

final RouteObserver<PageRoute> appRouteObserver = RouteObserver<PageRoute>();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  final _mascotKey = GlobalKey<MascotWidgetState>();
  int _lastXp = -1;

  /// Cached so [dispose] and [_onProgressChanged] never touch `ref` outside the
  /// mounted lifecycle (which throws after the widget is disposed).
  ProgressService? _progress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final progress = ref.read(progressServiceProvider);
      _progress = progress;
      _lastXp = progress.stars;
      _checkNotifications();
      // Listen for XP gains and badge unlocks
      progress.addListener(_onProgressChanged);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    // Safe to remove — ProgressService outlives this widget. Uses the cached
    // reference rather than `ref` (which is invalid during/after dispose).
    _progress?.removeListener(_onProgressChanged);
    super.dispose();
  }

  @override
  void didPopNext() {
    _checkNotifications();
  }

  void _onProgressChanged() {
    if (!mounted) return;
    final ps = _progress;
    if (ps == null) return;
    final newXp = ps.stars;
    if (_lastXp >= 0 && newXp > _lastXp) {
      final gained = newXp - _lastXp;
      XpPopup.show(context, amount: gained);
      _mascotKey.currentState?.celebrate();
    }
    _lastXp = newXp;
  }

  Future<void> _checkNotifications() async {
    if (!mounted) return;
    final progress = ref.read(progressServiceProvider);

    if (progress.consumeDailyRewardFlag()) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DailyRewardDialog(progress: progress),
      );
      if (!mounted) return;
    }

    final levelUp = progress.consumeLevelUp();
    if (levelUp != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelUpDialog(
          newLevel: levelUp,
          isMalay: progress.language == AppLanguage.malay,
        ),
      );
      if (!mounted) return;
    }

    // Show any badges unlocked since the last check, one after another.
    for (final badge in progress.consumePendingBadges()) {
      if (!mounted) return;
      await BadgeUnlockOverlay.show(context, badge: badge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressServiceProvider);
    final isMalay = progress.language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      bottomNavigationBar: _BottomBar(isMalay: isMalay),
      body: BijakScene(
        topColor: const Color(0xFFBCE2FF),
        bottomColor: AppTheme.lightBlue,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                isMalay: isMalay,
                progress: progress,
                mascotKey: _mascotKey,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ─── DAILY QUESTS section ──────────────────────────────
                  _SectionChip(
                    emoji: '🎯',
                    label: isMalay ? 'MISI HARI INI' : 'TODAY\'S QUESTS',
                    color: const Color(0xFFE84393),
                  ),
                  const SizedBox(height: 10),
                  _DailyQuestsCard(isMalay: isMalay, progress: progress),

                  const SizedBox(height: 22),

                  // ─── LEARN section ──────────────────────────────────────
                  _SectionChip(
                    emoji: '📖',
                    label: isMalay ? 'BELAJAR' : 'LEARN',
                    color: AppTheme.skyBlue,
                  ),
                  const SizedBox(height: 12),
                  _ModuleGrid(
                    children: [
                      _ModuleTile(
                        emoji: '🔢',
                        symbol: '1\n2\n3',
                        title: isMalay ? 'Nombor' : 'Numbers',
                        sub: '1 – 100',
                        color: AppTheme.appleRed,
                        done: progress.getModuleLessons('numbers'),
                        total: 100,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(LearnNumbersScreen.routeName),
                      ),
                      _ModuleTile(
                        emoji: '🔤',
                        symbol: 'A\nB\nC',
                        title: isMalay ? 'Huruf' : 'Letters',
                        sub: 'A – Z',
                        color: AppTheme.turquoise,
                        done: progress.getModuleLessons('letters'),
                        total: 26,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(LearnLettersScreen.routeName),
                      ),
                      _ModuleTile(
                        emoji: '🌙',
                        symbol: 'ا\nب\nت',
                        title: isMalay ? 'Jawi' : 'Jawi',
                        sub: isMalay ? '28 Huruf' : '28 Letters',
                        color: AppTheme.leafGreen,
                        done: progress.getModuleLessons('jawi'),
                        total: 28,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(JawiAsasScreen.routeName),
                      ),
                      _ModuleTile(
                        emoji: '🧍',
                        symbol: '👦',
                        title: isMalay ? 'Anggota\nBadan' : 'Body\nParts',
                        sub: isMalay ? '14 Bahagian' : '14 Parts',
                        color: AppTheme.purple,
                        done: progress.getModuleLessons('bodyparts'),
                        total: 14,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(LearnBodyPartsScreen.routeName),
                      ),
                      _ModuleTile(
                        emoji: '🧮',
                        symbol: '+ −\n× ÷',
                        title: isMalay ? 'Matematik' : 'Math',
                        sub: isMalay ? 'Tambah & Tolak' : 'Add & Subtract',
                        color: const Color(0xFFFF9F1C),
                        done: progress.getModuleLessons('math'),
                        total: 50,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(MathPracticeScreen.routeName),
                      ),
                      _ModuleTile(
                        emoji: '🎨',
                        symbol: '🖌️',
                        title: isMalay ? 'Mewarna' : 'Colour',
                        sub: isMalay ? 'Lukis & Warna' : 'Draw & Paint',
                        color: const Color(0xFFFF9F43),
                        done: progress.coloringSessions,
                        total: 40,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(ColoringScreen.routeName),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── GAMES section ──────────────────────────────────────
                  _SectionChip(
                    emoji: '🎮',
                    label: isMalay ? 'PERMAINAN' : 'GAMES',
                    color: AppTheme.purple,
                  ),
                  const SizedBox(height: 12),
                  _BigNavButton(
                    emoji: '🎮',
                    title: isMalay
                        ? 'Semua Permainan'
                        : 'All Games & Activities',
                    sub: isMalay
                        ? 'Memori, Teka-Teki, Tren Nombor & Huruf'
                        : 'Memory, Puzzle, Number Train & Letter Train',
                    color: AppTheme.purple,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(GamesHubScreen.routeName),
                  ),

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
  const _HomeHeader({
    required this.isMalay,
    required this.progress,
    this.mascotKey,
  });
  final bool isMalay;
  final ProgressService progress;
  final GlobalKey<MascotWidgetState>? mascotKey;

  @override
  Widget build(BuildContext context) {
    final level = progress.currentLevel;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          children: [
            // ── Top bar ──
            Row(
              children: [
                const BijakLogoText(compact: true),
                const Spacer(),
                _IconBtn(
                  icon: Icons.insights_rounded,
                  onTap: () => Navigator.of(context)
                      .pushNamed(ProgressScreen.routeName),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.ink.withValues(alpha: 0.09),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      MascotWidget(key: mascotKey, size: 72),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMalay
                                  ? '👋 Hai, anak bijak!'
                                  : '👋 Hi, smart learner!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Level display
                            Row(
                              children: [
                                Text(level.emoji,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  '${isMalay ? 'Tahap' : 'Level'} ${level.level} · ${isMalay ? level.titleMalay : level.title}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: level.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Level XP bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: level.progressFraction(progress.stars),
                                minHeight: 5,
                                backgroundColor:
                                    level.color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    level.color),
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (level.maxStars > 0)
                              Text(
                                isMalay
                                    ? '${level.starsToNext(progress.stars)} bintang ke Tahap ${level.level + 1}'
                                    : '${level.starsToNext(progress.stars)} stars to Level ${level.level + 1}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: level.color.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          // Star pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.sunnyYellow.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: AppTheme.sunnyYellow, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⭐',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  '${progress.stars}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Streak pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9F43)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: const Color(0xFFFF9F43), width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 3),
                                Text(
                                  '${progress.currentStreak}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
  const _ContinueLearningBanner({
    required this.isMalay,
    required this.progress,
  });
  final bool isMalay;
  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ContinueModule(
        'numbers',
        '🔢',
        isMalay ? 'Nombor' : 'Numbers',
        progress.getModuleLessons('numbers'),
        100,
        AppTheme.appleRed,
        LearnNumbersScreen.routeName,
      ),
      _ContinueModule(
        'letters',
        '🔤',
        isMalay ? 'Huruf' : 'Letters',
        progress.getModuleLessons('letters'),
        26,
        AppTheme.turquoise,
        LearnLettersScreen.routeName,
      ),
      _ContinueModule(
        'jawi',
        '🌙',
        'Jawi',
        progress.getModuleLessons('jawi'),
        28,
        AppTheme.leafGreen,
        JawiAsasScreen.routeName,
      ),
      _ContinueModule(
        'bodyparts',
        '🧍',
        isMalay ? 'Anggota Badan' : 'Body Parts',
        progress.getModuleLessons('bodyparts'),
        14,
        AppTheme.purple,
        LearnBodyPartsScreen.routeName,
      ),
    ];

    final active = modules.where((m) => m.done > 0 && m.done < m.total).toList()
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
            boxShadow: [
              BoxShadow(
                color: m.color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
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
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      m.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
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
  const _ContinueModule(
    this.id,
    this.emoji,
    this.name,
    this.done,
    this.total,
    this.color,
    this.route,
  );
  final String id, emoji, name, route;
  final int done, total;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Quests card
// ─────────────────────────────────────────────────────────────────────────────
class _DailyQuestsCard extends StatelessWidget {
  const _DailyQuestsCard({
    required this.isMalay,
    required this.progress,
  });
  final bool isMalay;
  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    final quests = todayQuests();
    final qProgress = progress.questProgress;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE84393).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: List.generate(quests.length, (i) {
          final q = quests[i];
          final prog = i < qProgress.length ? qProgress[i] : 0;
          final done = prog >= q.requiredCount;
          final pct =
              (prog / q.requiredCount).clamp(0.0, 1.0);
          final isLast = i == quests.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    // Emoji badge
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(0xFF34C759).withValues(alpha: 0.15)
                            : const Color(0xFFE84393).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          done ? '✅' : q.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isMalay ? q.titleMalay : q.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: done
                                        ? const Color(0xFF34C759)
                                        : AppTheme.ink,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: done
                                      ? const Color(0xFF34C759)
                                          .withValues(alpha: 0.15)
                                      : AppTheme.sunnyYellow
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '⭐ +${q.rewardStars}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: done
                                        ? const Color(0xFF34C759)
                                        : const Color(0xFFB8860B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isMalay ? q.descriptionMalay : q.description,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A7A9A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: done
                                        ? const Color(0xFF34C759)
                                            .withValues(alpha: 0.15)
                                        : const Color(0xFFE84393)
                                            .withValues(alpha: 0.12),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      done
                                          ? const Color(0xFF34C759)
                                          : const Color(0xFFE84393),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$prog/${q.requiredCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: done
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFFE84393),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: const Color(0xFFE84393).withValues(alpha: 0.08),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
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
            border: Border.all(
              color: color.withValues(alpha: 0.45),
              width: 1.4,
            ),
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
// Module grid
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
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
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                width: 72,
                color: widget.color,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(pct * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 7,
                          backgroundColor:
                              widget.color.withValues(alpha: 0.14),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              widget.color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.done}/${widget.total}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.color.withValues(alpha: 0.75),
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
// Big nav button
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      elevation: 5,
      shadowColor: color.withValues(alpha: 0.35),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
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
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.isMalay});
  final bool isMalay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: isMalay ? 'Utama' : 'Home',
        selected: true,
        onTap: () {},
      ),
      _NavItem(
        icon: Icons.route_rounded,
        label: isMalay ? 'Sukatan' : 'Syllabus',
        selected: false,
        onTap: () =>
            Navigator.of(context).pushNamed(LearningPathScreen.routeName),
      ),
      _NavItem(
        icon: Icons.insights_rounded,
        label: isMalay ? 'Kemajuan' : 'Progress',
        selected: false,
        onTap: () => Navigator.of(context).pushNamed(ProgressScreen.routeName),
      ),
      _NavItem(
        icon: progress.voiceEnabled
            ? Icons.volume_up_rounded
            : Icons.volume_off_rounded,
        label: isMalay ? 'Suara' : 'Voice',
        selected: progress.voiceEnabled,
        onTap: () => progress.setVoiceEnabled(!progress.voiceEnabled),
      ),
      _NavItem(
        icon: Icons.settings_rounded,
        label: isMalay ? 'Tetapan' : 'Settings',
        selected: false,
        onTap: () =>
            Navigator.of(context).pushNamed(ParentGateScreen.routeName),
      ),
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
          children: items
              .map(
                (item) => Expanded(
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
                          Icon(
                            item.icon,
                            color: item.selected
                                ? AppTheme.ink
                                : const Color(0xFF8898C8),
                            size: 22,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: item.selected
                                  ? AppTheme.ink
                                  : const Color(0xFF8898C8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.ink, size: 22),
      ),
    );
  }
}
