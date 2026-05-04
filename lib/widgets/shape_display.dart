import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/challenge.dart';

class ShapeDisplay extends StatelessWidget {
  const ShapeDisplay({
    super.key,
    required this.shape,
    this.size = 180,
    this.color,
  });

  final ShapeKind shape;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapePainter(
        shape: shape,
        color: color ?? Theme.of(context).colorScheme.secondary,
      ),
      size: Size.square(size),
    );
  }
}

class _ShapePainter extends CustomPainter {
  const _ShapePainter({required this.shape, required this.color});

  final ShapeKind shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF24304F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide * 0.028).clamp(2, 5).toDouble()
      ..strokeJoin = StrokeJoin.round;

    final rect = Offset.zero & size;
    final inset = rect.deflate(size.shortestSide * 0.1);
    final path = switch (shape) {
      ShapeKind.circle => Path()..addOval(inset),
      ShapeKind.square => Path()..addRRect(_rounded(inset)),
      ShapeKind.triangle => _triangle(inset),
      ShapeKind.rectangle =>
        Path()..addRRect(
          _rounded(
            Rect.fromCenter(
              center: rect.center,
              width: size.width * 0.82,
              height: size.height * 0.52,
            ),
          ),
        ),
      ShapeKind.star => _star(rect.center, size.shortestSide * 0.42),
      ShapeKind.heart => _heart(inset),
      ShapeKind.oval =>
        Path()..addOval(
          Rect.fromCenter(
            center: rect.center,
            width: size.width * 0.78,
            height: size.height * 0.52,
          ),
        ),
      ShapeKind.diamond => _diamond(inset),
    };

    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }

  RRect _rounded(Rect rect) =>
      RRect.fromRectAndRadius(rect, const Radius.circular(12));

  Path _triangle(Rect rect) => Path()
    ..moveTo(rect.center.dx, rect.top)
    ..lineTo(rect.right, rect.bottom)
    ..lineTo(rect.left, rect.bottom)
    ..close();

  Path _diamond(Rect rect) => Path()
    ..moveTo(rect.center.dx, rect.top)
    ..lineTo(rect.right, rect.center.dy)
    ..lineTo(rect.center.dx, rect.bottom)
    ..lineTo(rect.left, rect.center.dy)
    ..close();

  Path _star(Offset center, double radius) {
    final path = Path();
    const points = 10;
    for (var i = 0; i < points; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final currentRadius = i.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Path _heart(Rect rect) {
    final path = Path();
    path.moveTo(rect.center.dx, rect.bottom - rect.height * 0.12);
    path.cubicTo(
      rect.left - rect.width * 0.08,
      rect.top + rect.height * 0.48,
      rect.left + rect.width * 0.12,
      rect.top,
      rect.center.dx,
      rect.top + rect.height * 0.25,
    );
    path.cubicTo(
      rect.right - rect.width * 0.12,
      rect.top,
      rect.right + rect.width * 0.08,
      rect.top + rect.height * 0.48,
      rect.center.dx,
      rect.bottom - rect.height * 0.12,
    );
    return path..close();
  }
}
