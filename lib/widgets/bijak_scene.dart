import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BijakScene extends StatelessWidget {
  const BijakScene({
    super.key,
    required this.child,
    this.topColor = AppTheme.skyBlue,
    this.bottomColor = AppTheme.lightBlue,
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
          colors: [topColor, bottomColor],
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

class BijakLogoText extends StatelessWidget {
  const BijakLogoText({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 36.0 : 50.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _OutlinedText(
          'Bijak',
          fontSize: fontSize,
          fillColor: AppTheme.sunnyYellow,
          strokeColor: AppTheme.deepBlue,
        ),
        Transform.translate(
          offset: Offset(0, compact ? -10 : -14),
          child: _OutlinedText(
            'Belajar',
            fontSize: fontSize,
            fillColor: Colors.white,
            strokeColor: AppTheme.deepBlue,
          ),
        ),
      ],
    );
  }
}

class BijakBookMascot extends StatelessWidget {
  const BijakBookMascot({super.key, this.size = 118});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.86,
      child: CustomPaint(painter: _BookMascotPainter()),
    );
  }
}

class YellowActionButton extends StatelessWidget {
  const YellowActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(160, 58),
        backgroundColor: AppTheme.sunnyYellow,
        foregroundColor: AppTheme.ink,
        disabledBackgroundColor: Colors.grey.shade200,
        disabledForegroundColor: Colors.grey.shade500,
        elevation: 7,
        shadowColor: AppTheme.appleRed.withValues(alpha: 0.3),
        side: const BorderSide(color: Colors.white, width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          if (icon != null) ...[
            const SizedBox(width: 10),
            Icon(icon, size: 23),
          ],
        ],
      ),
    );
  }
}

class BluePillButton extends StatelessWidget {
  const BluePillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 25),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(130, 54),
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        elevation: 6,
        shadowColor: AppTheme.deepBlue.withValues(alpha: 0.28),
        side: const BorderSide(color: Colors.white, width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText(
    this.text, {
    required this.fontSize,
    required this.fillColor,
    required this.strokeColor,
  });

  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 0.88,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: base.copyWith(
            color: fillColor,
            shadows: const [
              Shadow(
                color: Color(0x66000000),
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.showHills);

  final bool showHills;

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.82);
    final yellowStar = Paint()..color = AppTheme.sunnyYellow;

    for (var i = 0; i < 24; i++) {
      final x = (size.width * ((i * 37) % 100) / 100) + (i.isEven ? 6 : -10);
      final y = 28 + ((i * 31) % 170).toDouble();
      _drawSparkle(canvas, Offset(x, y), i.isEven ? yellowStar : starPaint);
    }

    _drawCloud(canvas, Offset(size.width * 0.12, 92), 0.82);
    _drawCloud(canvas, Offset(size.width * 0.82, 132), 0.68);

    if (!showHills) return;

    final hill1 = Paint()..color = const Color(0xFF72D970);
    final hill2 = Paint()..color = const Color(0xFF35C759);
    final flower = Paint()..color = AppTheme.appleRed;
    final flowerCenter = Paint()..color = AppTheme.sunnyYellow;

    final path1 = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.72,
        size.width * 0.52,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.92,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, hill1);

    final path2 = Path()
      ..moveTo(0, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.78,
        size.width * 0.58,
        size.height * 0.91,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height,
        size.width,
        size.height * 0.86,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, hill2);

    for (var i = 0; i < 13; i++) {
      final x = size.width * (i + 0.5) / 13;
      final y = size.height - 24 - (i % 3) * 9;
      for (var petal = 0; petal < 5; petal++) {
        final angle = petal * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(x + math.cos(angle) * 5, y + math.sin(angle) * 5),
          3,
          flower,
        );
      }
      canvas.drawCircle(Offset(x, y), 3, flowerCenter);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center, 2.3, paint);
    canvas.drawLine(center.translate(-5, 0), center.translate(5, 0), paint);
    canvas.drawLine(center.translate(0, -5), center.translate(0, 5), paint);
  }

  void _drawCloud(Canvas canvas, Offset center, double scale) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.82);
    canvas.drawCircle(
      center.translate(-28 * scale, 5 * scale),
      19 * scale,
      paint,
    );
    canvas.drawCircle(
      center.translate(-8 * scale, -7 * scale),
      25 * scale,
      paint,
    );
    canvas.drawCircle(
      center.translate(18 * scale, 1 * scale),
      18 * scale,
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(-2 * scale, 15 * scale),
          width: 76 * scale,
          height: 24 * scale,
        ),
        Radius.circular(18 * scale),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BookMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pagePaint = Paint()..color = Colors.white;
    final edgePaint = Paint()..color = AppTheme.deepBlue;
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.12);
    final bookmarkPaint = Paint()..color = AppTheme.sunnyYellow;

    final leftPage = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.18, w * 0.44, h * 0.62),
      Radius.circular(w * 0.12),
    );
    final rightPage = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.48, h * 0.18, w * 0.44, h * 0.62),
      Radius.circular(w * 0.12),
    );

    canvas.drawRRect(leftPage.shift(Offset(0, h * 0.05)), shadowPaint);
    canvas.drawRRect(rightPage.shift(Offset(0, h * 0.05)), shadowPaint);
    canvas.drawRRect(leftPage, edgePaint);
    canvas.drawRRect(rightPage, edgePaint);
    canvas.drawRRect(leftPage.deflate(w * 0.035), pagePaint);
    canvas.drawRRect(rightPage.deflate(w * 0.035), pagePaint);

    final bookmark = Path()
      ..moveTo(w * 0.45, h * 0.76)
      ..lineTo(w * 0.55, h * 0.76)
      ..lineTo(w * 0.55, h * 0.98)
      ..lineTo(w * 0.5, h * 0.9)
      ..lineTo(w * 0.45, h * 0.98)
      ..close();
    canvas.drawPath(bookmark, bookmarkPaint);

    final eye = Paint()..color = const Color(0xFF04246B);
    canvas.drawCircle(Offset(w * 0.37, h * 0.48), w * 0.04, eye);
    canvas.drawCircle(Offset(w * 0.63, h * 0.48), w * 0.04, eye);
    canvas.drawCircle(
      Offset(w * 0.355, h * 0.46),
      w * 0.012,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.615, h * 0.46),
      w * 0.012,
      Paint()..color = Colors.white,
    );

    final smile = Paint()
      ..color = AppTheme.appleRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.56),
        width: w * 0.24,
        height: h * 0.16,
      ),
      0.15,
      math.pi - 0.3,
      false,
      smile,
    );
    canvas.drawCircle(
      Offset(w * 0.24, h * 0.56),
      w * 0.035,
      Paint()..color = const Color(0xFFFFA6B2),
    );
    canvas.drawCircle(
      Offset(w * 0.76, h * 0.56),
      w * 0.035,
      Paint()..color = const Color(0xFFFFA6B2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
