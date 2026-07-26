import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

import '../data/find_explorer_data.dart';
import '../models/challenge.dart';
import '../models/explorer_item.dart';
import '../theme/app_theme.dart';
import '../utils/app_text.dart';
import '../widgets/star_counter.dart';
import 'reward_screen.dart';

// ── Layout positions for the 4 floating objects ───────────────────────────────
// Each position is expressed as (alignX, alignY) in Alignment space (-1..1)
const _slotAlignments = [
  Alignment(-0.55, -0.55), // top-left
  Alignment(0.55, -0.55), // top-right
  Alignment(-0.55, 0.50), // bottom-left
  Alignment(0.55, 0.50), // bottom-right
];

class FindExplorerScreen extends ConsumerStatefulWidget {
  const FindExplorerScreen({super.key});
  static const routeName = '/find-explorer';

  @override
  ConsumerState<FindExplorerScreen> createState() => _FindExplorerScreenState();
}

class _FindExplorerScreenState extends ConsumerState<FindExplorerScreen>
    with TickerProviderStateMixin {
  final _rng = math.Random();

  /// The 4 items currently shown on screen (slot 0-3)
  List<ExplorerItem> _options = [];

  /// Which slot holds the correct target
  int _targetSlot = 0;

  /// Which slot the player tapped (-1 = none yet)
  int _tappedSlot = -1;

  bool _roundDone = false;

  // Per-slot float controllers (idle bob)
  late List<AnimationController> _floatCtrls;
  late List<Animation<double>> _floatAnims;

  // Per-slot shake controller (wrong tap)
  late List<AnimationController> _shakeCtrls;
  late List<Animation<double>> _shakeAnims;

  // Per-slot pop controller (correct tap)
  late List<AnimationController> _popCtrls;
  late List<Animation<double>> _popAnims;

  // Sparkles on correct tap
  late AnimationController _sparkCtrl;
  bool _showSpark = false;
  int _sparkSlot = 0;

  @override
  void initState() {
    super.initState();

    _floatCtrls = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1800 + i * 250),
      )..repeat(reverse: true),
    );
    _floatAnims = List.generate(
      4,
      (i) => Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatCtrls[i], curve: Curves.easeInOut),
      ),
    );

    _shakeCtrls = List.generate(
      4,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _shakeAnims = List.generate(
      4,
      (i) => TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 15),
        TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 12.0, end: -10.0), weight: 25),
        TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 30),
      ]).animate(CurvedAnimation(parent: _shakeCtrls[i], curve: Curves.linear)),
    );

    _popCtrls = List.generate(
      4,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );
    _popAnims = List.generate(
      4,
      (i) => TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 35),
        TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 35),
      ]).animate(CurvedAnimation(parent: _popCtrls[i], curve: Curves.easeOut)),
    );

    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _sparkCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _showSpark = false);
      }
    });

    _buildRound();
  }

  bool _spokeInitialTarget = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Speak only the first time — this callback also fires on MediaQuery
    // changes and would randomly repeat the prompt mid-round.
    if (!_spokeInitialTarget) {
      _spokeInitialTarget = true;
      _speakTarget();
    }
  }

  @override
  void dispose() {
    for (final c in _floatCtrls) {
      c.dispose();
    }
    for (final c in _shakeCtrls) {
      c.dispose();
    }
    for (final c in _popCtrls) {
      c.dispose();
    }
    _sparkCtrl.dispose();
    super.dispose();
  }

  // ── Build a new round ──────────────────────────────────────────────────────

  /// Targets are drawn from a shuffled bag without replacement, so the child
  /// is never asked to find the same object twice until every object has
  /// been used once. Refilled (reshuffled) when empty.
  final List<ExplorerItem> _targetBag = [];

  void _refillTargetBag() {
    _targetBag
      ..clear()
      ..addAll(explorerItems)
      ..shuffle(_rng);
  }

  void _buildRound() {
    if (_targetBag.isEmpty) _refillTargetBag();
    final target = _targetBag.removeLast();

    // 3 distractors from the remaining objects.
    final others = List<ExplorerItem>.from(explorerItems)
      ..remove(target)
      ..shuffle(_rng);
    _options = [target, ...others.take(3)]..shuffle(_rng);
    _targetSlot = _options.indexOf(target);
    _tappedSlot = -1;
    _roundDone = false;
    _showSpark = false;

    // Reset animations
    for (final c in _shakeCtrls) {
      c.reset();
    }
    for (final c in _popCtrls) {
      c.reset();
    }
    _sparkCtrl.reset();
  }

  ExplorerItem get _target => _options[_targetSlot];

  // ── Tap handler ────────────────────────────────────────────────────────────

  Future<void> _onTap(int slot) async {
    if (_roundDone || _tappedSlot == slot) return;

    setState(() => _tappedSlot = slot);

    if (slot == _targetSlot) {
      // ✅ CORRECT
      HapticFeedback.heavyImpact();
      setState(() {
        _roundDone = true;
        _showSpark = true;
        _sparkSlot = slot;
      });
      _popCtrls[slot].forward(from: 0);
      _sparkCtrl.forward(from: 0);

      final progressService = ref.read(progressServiceProvider);
      final audioService = ref.read(audioServiceProvider);
      final badge = await progressService.completeChallenge(
        ChallengeMode.findExplorer,
      );
      await audioService.playCelebration(enabled: progressService.soundEnabled);

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      Navigator.of(context).pushNamed(
        RewardScreen.routeName,
        arguments: RewardArgs(
          modeLabel: AppText.ui('findExplorer', progressService.language),
          nextRoute: FindExplorerScreen.routeName,
          badge: badge,
        ),
      );
    } else {
      // ❌ WRONG
      HapticFeedback.mediumImpact();
      _shakeCtrls[slot].forward(from: 0);
      // allow re-tap after shake
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted) setState(() => _tappedSlot = -1);
    }
  }

  void _nextRound() {
    setState(_buildRound);
    _speakTarget();
  }

  void _speakTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _options.isEmpty) return;
      final progressService = ref.read(progressServiceProvider);
      ref
          .read(audioServiceProvider)
          .speak(
            AppText.findExplorerPrompt(_target, progressService.language),
            enabled: progressService.voiceEnabled,
            language: progressService.language,
          );
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1638), Color(0xFF2A2065), Color(0xFF00B894)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────────
              _TopBar(onBack: () => Navigator.of(context).pop()),

              // ── Mission card (who to find) ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _MissionCard(
                  target: _target,
                  language: language,
                  onSpeak: _speakTarget,
                ),
              ),

              // ── Game arena ──────────────────────────────────────────────
              Expanded(
                child: _options.isEmpty
                    ? const SizedBox()
                    : _GameArena(
                        options: _options,
                        targetSlot: _targetSlot,
                        tappedSlot: _tappedSlot,
                        roundDone: _roundDone,
                        floatAnims: _floatAnims,
                        shakeAnims: _shakeAnims,
                        popAnims: _popAnims,
                        showSpark: _showSpark,
                        sparkSlot: _sparkSlot,
                        sparkCtrl: _sparkCtrl,
                        language: language,
                        onTap: _onTap,
                      ),
              ),

              // ── Bottom bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    const Expanded(child: StarCounter(large: true)),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _nextRound,
                      icon: const Text('🔄', style: TextStyle(fontSize: 18)),
                      label: const Text('New Round'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white60, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
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
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Material(
            color: Colors.white24,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔍 Find Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
                  ),
                ),
                Text(
                  'Tap the right object!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission card
// ─────────────────────────────────────────────────────────────────────────────
class _MissionCard extends ConsumerWidget {
  const _MissionCard({
    required this.target,
    required this.language,
    required this.onSpeak,
  });
  final ExplorerItem target;
  final dynamic language;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Target icon preview
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: target.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: target.color, width: 2.5),
            ),
            child: Center(
              child: target.emoji != null
                  ? Text(target.emoji!, style: const TextStyle(fontSize: 30))
                  : Icon(target.icon, color: target.color, size: 32),
            ),
          ),
          const SizedBox(width: 14),
          // Prompt
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎯  FIND THIS!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.turquoise,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppText.findExplorerPrompt(target, language),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Speak button
          GestureDetector(
            onTap: onSpeak,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: target.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: target.color.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game arena — 4 floating objects
// ─────────────────────────────────────────────────────────────────────────────
class _GameArena extends ConsumerWidget {
  const _GameArena({
    required this.options,
    required this.targetSlot,
    required this.tappedSlot,
    required this.roundDone,
    required this.floatAnims,
    required this.shakeAnims,
    required this.popAnims,
    required this.showSpark,
    required this.sparkSlot,
    required this.sparkCtrl,
    required this.language,
    required this.onTap,
  });

  final List<ExplorerItem> options;
  final int targetSlot;
  final int tappedSlot;
  final bool roundDone;
  final List<Animation<double>> floatAnims;
  final List<Animation<double>> shakeAnims;
  final List<Animation<double>> popAnims;
  final bool showSpark;
  final int sparkSlot;
  final AnimationController sparkCtrl;
  final dynamic language;
  final void Function(int slot) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Decorative stars in background
        const _BgStars(),

        // 4 object slots
        for (int i = 0; i < 4; i++)
          Align(
            alignment: _slotAlignments[i],
            child: _FloatingObject(
              item: options[i],
              slot: i,
              isTarget: i == targetSlot,
              isTapped: i == tappedSlot,
              isCorrect: roundDone && i == targetSlot,
              isWrong: !roundDone && i == tappedSlot,
              roundDone: roundDone,
              floatAnim: floatAnims[i],
              shakeAnim: shakeAnims[i],
              popAnim: popAnims[i],
              language: language,
              onTap: () => onTap(i),
            ),
          ),

        // Sparkle burst on the correct slot
        if (showSpark)
          Align(
            alignment: _slotAlignments[sparkSlot],
            child: _SparklesBurst(controller: sparkCtrl),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// One floating object card
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingObject extends ConsumerWidget {
  const _FloatingObject({
    required this.item,
    required this.slot,
    required this.isTarget,
    required this.isTapped,
    required this.isCorrect,
    required this.isWrong,
    required this.roundDone,
    required this.floatAnim,
    required this.shakeAnim,
    required this.popAnim,
    required this.language,
    required this.onTap,
  });

  final ExplorerItem item;
  final int slot;
  final bool isTarget;
  final bool isTapped;
  final bool isCorrect;
  final bool isWrong;
  final bool roundDone;
  final Animation<double> floatAnim;
  final Animation<double> shakeAnim;
  final Animation<double> popAnim;
  final dynamic language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: Listenable.merge([floatAnim, shakeAnim, popAnim]),
      builder: (ctx, _) {
        final floatY = isCorrect ? 0.0 : floatAnim.value;
        final shakeX = isWrong ? shakeAnim.value : 0.0;
        final scale = isCorrect ? popAnim.value : 1.0;

        // Border & bg colour based on state
        Color borderColor = item.color.withValues(alpha: 0.4);
        Color bgColor = Colors.white;
        if (isCorrect) {
          borderColor = AppTheme.leafGreen;
          bgColor = AppTheme.leafGreen.withValues(alpha: 0.08);
        } else if (isWrong) {
          borderColor = AppTheme.appleRed;
          bgColor = AppTheme.appleRed.withValues(alpha: 0.07);
        }

        return Transform.translate(
          offset: Offset(shakeX, floatY),
          child: Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: roundDone ? null : onTap,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(
                        alpha: isCorrect ? 0.5 : 0.25,
                      ),
                      blurRadius: isCorrect ? 36 : 18,
                      spreadRadius: isCorrect ? 4 : 0,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Emoji or icon
                    if (item.emoji != null)
                      Text(item.emoji!, style: const TextStyle(fontSize: 62))
                    else
                      Icon(
                        item.icon,
                        size: 64,
                        color: isWrong ? AppTheme.appleRed : item.color,
                      ),
                    // Label underneath icon
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCorrect ? AppTheme.leafGreen : item.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppText.explorerLabel(item, language),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    // ✅ overlay on correct
                    if (isCorrect)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.leafGreen,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    // ❌ overlay on wrong
                    if (isWrong)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.appleRed,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background decorative stars
// ─────────────────────────────────────────────────────────────────────────────
class _BgStars extends ConsumerWidget {
  const _BgStars();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: IgnorePointer(child: CustomPaint(painter: _StarsPainter())),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final _positions = const [
    Offset(0.15, 0.12),
    Offset(0.85, 0.08),
    Offset(0.05, 0.5),
    Offset(0.92, 0.45),
    Offset(0.5, 0.15),
    Offset(0.3, 0.88),
    Offset(0.72, 0.82),
    Offset(0.5, 0.92),
    Offset(0.18, 0.72),
    Offset(0.80, 0.65),
  ];
  final _sizes = [8.0, 6.0, 10.0, 7.0, 9.0, 6.0, 11.0, 7.0, 8.0, 6.0];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < _positions.length; i++) {
      canvas.drawCircle(
        Offset(_positions[i].dx * size.width, _positions[i].dy * size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkle burst (correct answer celebration)
// ─────────────────────────────────────────────────────────────────────────────
class _SparklesBurst extends ConsumerWidget {
  const _SparklesBurst({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _SparklesPainter(progress: controller.value),
        size: const Size(200, 200),
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  const _SparklesPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress).clamp(0.0, 1.0);

    // Colour burst dots
    final colors = [
      AppTheme.sunnyYellow,
      AppTheme.appleRed,
      AppTheme.leafGreen,
      AppTheme.skyBlue,
      AppTheme.purple,
    ];

    const count = 14;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final radius = 20 + progress * 90;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final r = (8 * fade).clamp(0.0, 12.0);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: fade * 0.95)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklesPainter old) => old.progress != progress;
}
