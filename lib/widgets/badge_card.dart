import 'package:flutter/material.dart';

import '../models/badge.dart';

class BadgeCard extends StatefulWidget {
  const BadgeCard({super.key, required this.badge, required this.earned});

  final FinderBadge badge;
  final bool earned;

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard>
    with TickerProviderStateMixin {
  // Press feedback — mirrors the scale pattern used by BigModeButton so the
  // whole app shares one consistent "tactile" feel.
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  // Unlock "pop" — plays once when a locked badge becomes earned, drawing the
  // child's eye to their new achievement instead of it silently appearing.
  late final AnimationController _popCtrl;
  late final Animation<double> _popScale;

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

    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 0.96), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeInOut));

    if (widget.earned) _popCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant BadgeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.earned && !oldWidget.earned) {
      _popCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final color = widget.earned ? widget.badge.color : const Color(0xFF8C96AA);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (context, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _popScale,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: widget.earned ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.earned ? widget.badge.icon : Icons.lock_rounded,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.badge.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          color: widget.earned
                              ? const Color(0xFF24304F)
                              : color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.badge.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
