import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/badge.dart';
import '../theme/app_theme.dart';

/// Full-screen dialog that plays when a badge is first unlocked.
///
/// Show via:
/// ```dart
/// BadgeUnlockOverlay.show(context, badge: badge);
/// ```
class BadgeUnlockOverlay extends StatefulWidget {
  const BadgeUnlockOverlay({super.key, required this.badge});

  final FinderBadge badge;

  static Future<void> show(BuildContext context, {required FinderBadge badge}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => BadgeUnlockOverlay(badge: badge),
    );
  }

  @override
  State<BadgeUnlockOverlay> createState() => _BadgeUnlockOverlayState();
}

class _BadgeUnlockOverlayState extends State<BadgeUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3))
      ..play();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // ── Dialog ──────────────────────────────────────────────────
        FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              content: AnimatedBuilder(
                animation: _glow,
                builder: (_, child) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0A1F6B),
                        badge.color,
                        const Color(0xFF0A1F6B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: AppTheme.sunnyYellow,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badge.color
                            .withValues(alpha: 0.6 * _glow.value),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                  child: child,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── "NEW BADGE" chip ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.sunnyYellow,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        '🏅 NEW BADGE!',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Badge icon ───────────────────────────────
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: badge.color.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.sunnyYellow,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: badge.color.withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        badge.icon,
                        color: badge.color,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Title ────────────────────────────────────
                    Text(
                      badge.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // ── Description ──────────────────────────────
                    Text(
                      badge.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // ── Dismiss button ───────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              badge.color,
                              badge.color.withValues(alpha: 0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: badge.color.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '🎉 Awesome!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Confetti ─────────────────────────────────────────────────
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 28,
          gravity: 0.18,
          colors: [
            AppTheme.sunnyYellow,
            Colors.white,
            badge.color,
            AppTheme.appleRed,
            AppTheme.turquoise,
          ],
        ),
      ],
    );
  }
}
