import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Displays an animated "+N ⭐" popup that floats upward and fades out.
///
/// Show it via the static [XpPopup.show] helper:
/// ```dart
/// XpPopup.show(context, amount: 1);
/// ```
class XpPopup extends StatefulWidget {
  const XpPopup({super.key, required this.amount});

  final int amount;

  /// Insert a floating XP popup into [context]'s overlay.
  static OverlayEntry show(BuildContext context, {int amount = 1}) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _XpPopupPositioned(
        amount: amount,
        onDone: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<XpPopup> createState() => _XpPopupState();
}

class _XpPopupState extends State<XpPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _slide = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.sunnyYellow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sunnyYellow.withValues(alpha: 0.6),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '+${widget.amount} ⭐',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
          ),
        ),
      ),
    );
  }
}

// ── Overlay-positioned wrapper ────────────────────────────────────────────

class _XpPopupPositioned extends StatefulWidget {
  const _XpPopupPositioned({required this.amount, required this.onDone});
  final int amount;
  final VoidCallback onDone;

  @override
  State<_XpPopupPositioned> createState() => _XpPopupPositionedState();
}

class _XpPopupPositionedState extends State<_XpPopupPositioned>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _slideY;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 58),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _slideY = Tween<double>(begin: 0, end: -80).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: size.width / 2 - 52,
      top: size.height * 0.42,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _slideY.value),
              child: Transform.scale(scale: _scale.value, child: child),
            ),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.sunnyYellow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.sunnyYellow.withValues(alpha: 0.65),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '+${widget.amount} ⭐',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
