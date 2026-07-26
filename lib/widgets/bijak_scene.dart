import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BijakScene extends StatelessWidget {
  const BijakScene({
    super.key,
    required this.child,
    this.topColor = AppTheme.nightTop,
    this.bottomColor = AppTheme.nightBottom,
    this.showHills = true,
  });

  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final bool showHills;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topColor, AppTheme.nightMid, bottomColor],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _ScenePainter(showHills)),
          ),
          child,
        ],
      ),
    );
  }
}

/// Gradient backdrop for an [AppBar]'s `flexibleSpace`: the module colour
/// melting diagonally down into the night, so every top bar feels part of the
/// starry world instead of a flat colour block. Pair with a transparent
/// AppBar `backgroundColor` and white `foregroundColor`.
class NightBar extends StatelessWidget {
  const NightBar(this.color, {super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, AppTheme.nightDeep, 0.55)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

/// Paints the immersive starry-night backdrop shared across the app:
/// an aurora glow, a soft moon, a twinkling star field, and — when
/// [showHills] is set — distant hill silhouettes with drifting fireflies.
class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.showHills);

  final bool showHills;

  @override
  void paint(Canvas canvas, Size size) {
    // ── Aurora wash (violet → coral) top-left ──
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.10),
      size.width * 0.55,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                AppTheme.violet.withValues(alpha: 0.42),
                AppTheme.violet.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.22, size.height * 0.10),
                radius: size.width * 0.55,
              ),
            ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.30),
      size.width * 0.5,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                AppTheme.coral.withValues(alpha: 0.26),
                AppTheme.coral.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.92, size.height * 0.30),
                radius: size.width * 0.5,
              ),
            ),
    );

    // ── Moon with halo ──
    final moonCenter = Offset(size.width * 0.80, 92);
    canvas.drawCircle(
      moonCenter,
      54,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.gold.withValues(alpha: 0.30),
            AppTheme.gold.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: moonCenter, radius: 54)),
    );
    canvas.drawCircle(moonCenter, 24, Paint()..color = const Color(0xFFFFF3CF));
    canvas.drawCircle(
      moonCenter.translate(9, -4),
      22,
      Paint()..color = AppTheme.nightTop,
    );

    // ── Star field (twinkles + round stars) ──
    for (var i = 0; i < 34; i++) {
      final x = (size.width * ((i * 37) % 100) / 100) + (i.isEven ? 6 : -10);
      final y = 24 + ((i * 53) % 260).toDouble();
      final twinkle = i % 4 == 0;
      final paint = Paint()
        ..color = (i % 3 == 0 ? AppTheme.gold : Colors.white).withValues(
          alpha: twinkle ? 0.95 : 0.55,
        );
      if (twinkle) {
        _drawSparkle(canvas, Offset(x, y), paint);
      } else {
        canvas.drawCircle(Offset(x, y), i.isEven ? 1.5 : 1.1, paint);
      }
    }

    if (!showHills) return;

    // ── Distant hill silhouettes (deep indigo, receding) ──
    final hill1 = Paint()..color = const Color(0xFF221E45);
    final hill2 = Paint()..color = const Color(0xFF191634);

    final path1 = Path()
      ..moveTo(0, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.74,
        size.width * 0.52,
        size.height * 0.84,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.94,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, hill1);

    final path2 = Path()
      ..moveTo(0, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.80,
        size.width * 0.58,
        size.height * 0.93,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, hill2);

    // ── Fireflies over the hills ──
    for (var i = 0; i < 11; i++) {
      final x = size.width * (i + 0.5) / 11;
      final y = size.height - 30 - (i % 3) * 14;
      canvas.drawCircle(
        Offset(x, y),
        4.5,
        Paint()..color = AppTheme.gold.withValues(alpha: 0.18),
      );
      canvas.drawCircle(Offset(x, y), 1.6, Paint()..color = AppTheme.gold);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center, 1.8, paint);
    canvas.drawLine(center.translate(-5, 0), center.translate(5, 0), paint);
    canvas.drawLine(center.translate(0, -5), center.translate(0, 5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
