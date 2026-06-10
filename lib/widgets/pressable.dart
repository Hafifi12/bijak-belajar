import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Shared press-feedback primitive for every tappable card/tile/button that
/// isn't a Material button.
///
/// Replaces the copy-pasted `GestureDetector + AnimationController` pattern,
/// fixing the issues that pattern had:
///  * action fired from `onTap` (not `onTapUp`, which could double-fire and
///    triggers even when a drag ends on the widget),
///  * `Semantics(button: true, label: …)` so emoji-only tiles are readable
///    by screen readers,
///  * enforced minimum touch target ([AppTheme.kidTarget] by default —
///    children need larger targets than the adult 48dp minimum),
///  * light haptic tick on press for tactile feedback.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    this.pressedScale = 0.95,
    this.minSize = AppTheme.kidTarget,
    this.haptics = true,
  });

  final VoidCallback onTap;
  final Widget child;

  /// Spoken description for assistive tech. Strongly recommended for tiles
  /// whose visible content is emoji/iconography.
  final String? semanticLabel;

  /// Scale applied while pressed (1.0 = none).
  final double pressedScale;

  /// Minimum width/height enforced for the touch target.
  final double minSize;

  final bool haptics;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: widget.pressedScale,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.haptics) HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: _ctrl.reverse,
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scale,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minSize,
              minHeight: widget.minSize,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
