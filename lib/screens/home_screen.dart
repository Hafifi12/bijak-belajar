import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_language.dart';
import '../models/quest.dart';
import '../providers/app_state.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import '../utils/route_observer.dart';
import '../widgets/badge_unlock_overlay.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/pressable.dart';
import '../widgets/xp_popup.dart';
import 'coloring_screen.dart';
import 'daily_reward_screen.dart';
import 'games_hub_screen.dart';
import 'jawi_asas_screen.dart';
import 'learn_body_parts_screen.dart';
import 'learn_letters_screen.dart';
import 'learn_numbers_screen.dart';
import 'level_up_screen.dart';
import 'math_practice_screen.dart';
import 'parent_gate_screen.dart';
import 'progress_screen.dart';

/// The child's home world — a starry **Adventure Map**. Every learning module
/// is a themed Malaysian "zone" on a winding trail, Zara the owl floats and
/// cheers the child on, and an XP/streak bar sits up top. Tapping a zone opens
/// that module; the daily quests live in a pull-up card.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  int _lastXp = -1;
  final _mapScroll = ScrollController();

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
    _progress?.removeListener(_onProgressChanged);
    _mapScroll.dispose();
    super.dispose();
  }

  /// Re-tapping the "Peta" tab glides the adventure map back to the top.
  void _scrollMapToTop() {
    if (!_mapScroll.hasClients) return;
    _mapScroll.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
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

    for (final badge in progress.consumePendingBadges()) {
      if (!mounted) return;
      await BadgeUnlockOverlay.show(context, badge: badge);
    }
  }

  void _openQuests(ProgressService progress, bool isMalay) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QuestsSheet(progress: progress, isMalay: isMalay),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressServiceProvider);
    final isMalay = progress.language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      bottomNavigationBar: _BottomBar(
        isMalay: isMalay,
        onHome: _scrollMapToTop,
      ),
      body: BijakScene(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AdventureTopBar(progress: progress, isMalay: isMalay),
              Expanded(
                child: SingleChildScrollView(
                  controller: _mapScroll,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 120),
                    child: _AdventureMap(progress: progress, isMalay: isMalay),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                child: _DailyStrip(
                  progress: progress,
                  isMalay: isMalay,
                  onTap: () => _openQuests(progress, isMalay),
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
// Top bar — avatar + level XP + streak
// ─────────────────────────────────────────────────────────────────────────────
class _AdventureTopBar extends StatelessWidget {
  const _AdventureTopBar({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    final level = progress.currentLevel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: [
          // Hero avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.coral, AppTheme.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.violet.withValues(alpha: 0.45),
                  blurRadius: 12,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(level.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 11),
          // Name + XP bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppText.levelTitle(level, progress.language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.onNight,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: level.progressFraction(progress.stars),
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${AppText.ui('levelWord', progress.language)} ${level.level} · ${progress.stars} ⭐',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.onNightMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StreakChip(streak: progress.currentStreak),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.coral.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppTheme.coral.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              color: AppTheme.onNight,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Adventure map — themed zones on a winding trail + Zara
// ─────────────────────────────────────────────────────────────────────────────
class _AdventureMap extends StatelessWidget {
  const _AdventureMap({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    final zones = <_ZoneData>[
      _ZoneData(
        emoji: '🔢',
        title: AppText.ui('numbers', progress.language),
        color: AppTheme.moduleNumbers,
        route: LearnNumbersScreen.routeName,
        done: progress.getModuleLessons('numbers'),
        total: 100,
        dx: 0.20,
        dy: 0.02,
      ),
      _ZoneData(
        emoji: '🔤',
        title: AppText.ui('letters', progress.language),
        color: AppTheme.moduleLetters,
        route: LearnLettersScreen.routeName,
        done: progress.getModuleLessons('letters'),
        total: 26,
        dx: 0.72,
        dy: 0.10,
      ),
      _ZoneData(
        emoji: '🌙',
        title: AppText.ui('jawi', progress.language),
        color: AppTheme.moduleJawi,
        route: JawiAsasScreen.routeName,
        done: progress.getModuleLessons('jawi'),
        total: 28,
        dx: 0.30,
        dy: 0.27,
      ),
      _ZoneData(
        emoji: '🧮',
        title: AppText.ui('math', progress.language),
        color: AppTheme.moduleMath,
        route: MathPracticeScreen.routeName,
        done: progress.getModuleLessons('math'),
        total: 50,
        dx: 0.74,
        dy: 0.40,
      ),
      _ZoneData(
        emoji: '🧍',
        title: AppText.ui('bodyParts', progress.language),
        color: AppTheme.moduleBodyParts,
        route: LearnBodyPartsScreen.routeName,
        done: progress.getModuleLessons('bodyparts'),
        total: 14,
        dx: 0.24,
        dy: 0.53,
      ),
      _ZoneData(
        emoji: '🎨',
        title: AppText.ui('colour', progress.language),
        color: AppTheme.moduleColoring,
        route: ColoringScreen.routeName,
        done: progress.coloringSessions,
        total: 40,
        dx: 0.66,
        dy: 0.67,
      ),
      _ZoneData(
        emoji: '🎮',
        title: AppText.ui('games', progress.language),
        color: AppTheme.moduleGames,
        route: GamesHubScreen.routeName,
        done: 0,
        total: 0,
        dx: 0.36,
        dy: 0.80,
      ),
    ];

    // The "current" zone glows: the in-progress module with the most progress,
    // otherwise the first untouched learning zone.
    String? current;
    final active =
        zones
            .where((z) => z.total > 0 && z.done > 0 && z.done < z.total)
            .toList()
          ..sort((a, b) => b.done.compareTo(a.done));
    if (active.isNotEmpty) {
      current = active.first.route;
    } else {
      final untouched = zones.firstWhere(
        (z) => z.total > 0 && z.done == 0,
        orElse: () => zones.first,
      );
      current = untouched.route;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Tall enough for the serpentine trail + labels + Zara, with room
        // below the last zone so its label clears the daily card.
        final h = math.max(740.0, w * 1.95);
        final centers = [
          for (final z in zones) Offset(z.dx * w, z.dy * h + 34),
        ];

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dashed trail behind the zones.
              Positioned.fill(
                child: CustomPaint(painter: _TrailPainter(centers)),
              ),
              // Zone nodes.
              for (var i = 0; i < zones.length; i++)
                Positioned(
                  left: zones[i].dx * w - 52,
                  top: zones[i].dy * h,
                  child: _ZoneNode(
                    zone: zones[i],
                    index: i + 1,
                    isCurrent: zones[i].route == current,
                    onTap: () =>
                        Navigator.of(context).pushNamed(zones[i].route),
                  ),
                ),
              // Zara companion floats near the trail's tail.
              Positioned(
                right: 4,
                top: 0.34 * h,
                child: _ZaraCompanion(
                  message: active.isNotEmpty
                      ? (isMalay
                            ? 'Mari sambung\npengembaraan kita!'
                            : "Let's continue\nour adventure!")
                      : (isMalay
                            ? 'Jom mula\npengembaraan!'
                            : "Let's start\nthe adventure!"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ZoneData {
  const _ZoneData({
    required this.emoji,
    required this.title,
    required this.color,
    required this.route,
    required this.done,
    required this.total,
    required this.dx,
    required this.dy,
  });
  final String emoji, title, route;
  final Color color;
  final int done, total;
  final double dx, dy;

  int get stars {
    if (total <= 0 || done <= 0) return 0;
    final f = done / total;
    if (f >= 0.66) return 3;
    if (f >= 0.33) return 2;
    return 1;
  }
}

class _ZoneNode extends StatefulWidget {
  const _ZoneNode({
    required this.zone,
    required this.index,
    required this.isCurrent,
    required this.onTap,
  });
  final _ZoneData zone;
  final int index;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  State<_ZoneNode> createState() => _ZoneNodeState();
}

class _ZoneNodeState extends State<_ZoneNode>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = widget.zone;
    final started = z.done > 0;
    final ringColor = widget.isCurrent ? AppTheme.gold : Colors.white;

    Widget bubble = Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [z.color, z.color.withValues(alpha: 0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: z.color.withValues(alpha: 0.55),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(z.emoji, style: const TextStyle(fontSize: 28)),
    );

    if (widget.isCurrent && _pulse != null) {
      bubble = AnimatedBuilder(
        animation: _pulse!,
        builder: (context, child) {
          final t = _pulse!.value;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.35 * (1 - t)),
                  blurRadius: 10,
                  spreadRadius: 6 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: bubble,
      );
    }

    return Pressable(
      onTap: widget.onTap,
      pressedScale: 0.92,
      semanticLabel: z.title.replaceAll('\n', ' '),
      child: SizedBox(
        width: 104,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isCurrent)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '▶ MULA',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.nightDeep,
                  ),
                ),
              ),
            bubble,
            const SizedBox(height: 5),
            Text(
              z.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: AppTheme.onNight,
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            if (z.total > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    Text(
                      i < z.stars ? '⭐' : '☆',
                      style: TextStyle(
                        fontSize: 10,
                        color: i < z.stars
                            ? null
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              )
            else
              Text(
                started ? '⭐' : '▶',
                style: const TextStyle(fontSize: 10, color: AppTheme.gold),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dashed trail connecting the zone bubbles in order.
class _TrailPainter extends CustomPainter {
  const _TrailPainter(this.centers);
  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < centers.length - 1; i++) {
      _dashedLine(canvas, centers[i], centers[i + 1], paint);
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final total = (b - a).distance;
    const dash = 9.0, gap = 8.0;
    double d = 0;
    while (d < total) {
      final f1 = d / total;
      final f2 = math.min(d + dash, total) / total;
      canvas.drawLine(Offset.lerp(a, b, f1)!, Offset.lerp(a, b, f2)!, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) =>
      oldDelegate.centers != centers;
}

// ─────────────────────────────────────────────────────────────────────────────
// Zara the owl companion
// ─────────────────────────────────────────────────────────────────────────────
class _ZaraCompanion extends StatefulWidget {
  const _ZaraCompanion({required this.message});
  final String message;

  @override
  State<_ZaraCompanion> createState() => _ZaraCompanionState();
}

class _ZaraCompanionState extends State<_ZaraCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -8 + _bob.value * 16),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 128),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.violet.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                color: AppTheme.nightDeep,
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [AppTheme.lilac, AppTheme.violet],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.violet.withValues(alpha: 0.5),
                    blurRadius: 18,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('🦉', style: TextStyle(fontSize: 34)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily strip — opens the quests sheet
// ─────────────────────────────────────────────────────────────────────────────
class _DailyStrip extends StatelessWidget {
  const _DailyStrip({
    required this.progress,
    required this.isMalay,
    required this.onTap,
  });
  final ProgressService progress;
  final bool isMalay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final quests = todayQuests();
    final qp = progress.questProgress;
    final done = List.generate(quests.length, (i) {
      final prog = i < qp.length ? qp[i] : 0;
      return prog >= quests[i].requiredCount;
    }).where((d) => d).length;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      semanticLabel: isMalay ? 'Misi hari ini' : "Today's quests",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.violet, AppTheme.lilac],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.violet.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.ui('todaysQuests', progress.language),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    isMalay
                        ? '$done / ${quests.length} selesai · ketuk untuk lihat'
                        : '$done / ${quests.length} done · tap to view',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.expand_less_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestsSheet extends StatelessWidget {
  const _QuestsSheet({required this.progress, required this.isMalay});
  final ProgressService progress;
  final bool isMalay;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.nightSurfaceHi, AppTheme.nightDeep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    AppText.ui('todaysQuests', progress.language),
                    style: const TextStyle(
                      color: AppTheme.onNight,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DailyQuestsCard(language: progress.language, progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Quests card (shown inside the pull-up sheet)
// ─────────────────────────────────────────────────────────────────────────────
class _DailyQuestsCard extends StatelessWidget {
  const _DailyQuestsCard({required this.language, required this.progress});
  final AppLanguage language;
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
            color: AppTheme.pink.withValues(alpha: 0.12),
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
          final pct = (prog / q.requiredCount).clamp(0.0, 1.0);
          final isLast = i == quests.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: done
                            ? AppTheme.leafGreen.withValues(alpha: 0.15)
                            : AppTheme.pink.withValues(alpha: 0.12),
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
                                  q.localizedTitle(language),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: done
                                        ? AppTheme.leafGreen
                                        : AppTheme.ink,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: done
                                      ? AppTheme.leafGreen.withValues(
                                          alpha: 0.15,
                                        )
                                      : AppTheme.sunnyYellow.withValues(
                                          alpha: 0.2,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '⭐ +${q.rewardStars}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: done
                                        ? AppTheme.leafGreen
                                        : const Color(0xFFB8860B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            q.localizedDescription(language),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.inkFaint,
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
                                        ? AppTheme.leafGreen.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppTheme.pink.withValues(alpha: 0.12),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      done ? AppTheme.leafGreen : AppTheme.pink,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$prog/${q.requiredCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: done
                                      ? AppTheme.leafGreen
                                      : AppTheme.pink,
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
                  color: AppTheme.pink.withValues(alpha: 0.08),
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
// Bottom navigation bar (dark glass)
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.isMalay, required this.onHome});
  final bool isMalay;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceEnabled = ref.watch(voiceEnabledProvider);
    final progress = ref.read(progressServiceProvider);
    final items = [
      _NavItem(
        icon: Icons.map_rounded,
        label: AppText.ui('navHome', progress.language),
        selected: true,
        onTap: onHome,
      ),
      _NavItem(
        icon: Icons.insights_rounded,
        label: AppText.ui('navProgress', progress.language),
        selected: false,
        onTap: () => Navigator.of(context).pushNamed(ProgressScreen.routeName),
      ),
      _NavItem(
        icon: voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        label: AppText.ui('navVoice', progress.language),
        selected: voiceEnabled,
        isToggle: true,
        onTap: () => progress.setVoiceEnabled(!voiceEnabled),
      ),
      _NavItem(
        icon: Icons.settings_rounded,
        label: AppText.ui('navSettings', progress.language),
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
          gradient: const LinearGradient(
            colors: [AppTheme.nightSurfaceHi, AppTheme.nightSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.lilac.withValues(alpha: 0.28),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.violet.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: items.map((item) {
            final Color tint = item.isToggle
                ? (item.selected ? AppTheme.leafGreen : AppTheme.onNightFaint)
                : (item.selected ? AppTheme.gold : AppTheme.onNightFaint);
            final Color bg = item.isToggle
                ? (item.selected
                      ? AppTheme.leafGreen.withValues(alpha: 0.18)
                      : Colors.transparent)
                : (item.selected
                      ? AppTheme.gold.withValues(alpha: 0.20)
                      : Colors.transparent);

            return Expanded(
              child: Semantics(
                button: !item.isToggle,
                toggled: item.isToggle ? item.selected : null,
                label: item.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  onTap: item.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(
                      minHeight: AppTheme.kidTarget,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: tint, size: 24),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: tint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
    this.isToggle = false,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool isToggle;
  final VoidCallback onTap;
}
