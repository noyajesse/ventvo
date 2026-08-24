import 'dart:math' as math;

import 'package:flutter/material.dart';

class VoiceFormationPainter extends CustomPainter {
  const VoiceFormationPainter({
    required this.progress,
    required this.symbol,
    required this.color,
  });

  final double progress;
  final String symbol;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final p = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: 0.10 * (1 - p));

    final particlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.60 * (1 - p));

    canvas.drawCircle(center, 58 + (18 * p), orbitPaint);

    for (var i = 0; i < 10; i++) {
      final angle = (math.pi * 2 * i / 10) + (p * math.pi * 0.45);
      final startRadius = 44.0 + ((i % 3) * 8);
      final endRadius = 8.0 + ((i % 2) * 3);
      final radius = startRadius + ((endRadius - startRadius) * p);
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final particleSize = 2.0 + (1.8 * p);
      canvas.drawCircle(point, particleSize, particlePaint);
    }

    final markOpacity = Curves.easeOut.transform(((p - 0.30) / 0.70).clamp(0.0, 1.0));
    final markPaint = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: color.withValues(alpha: markOpacity),
          fontSize: 58,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    markPaint.paint(canvas, center - Offset(markPaint.width / 2, markPaint.height / 2));

    final ringOpacity = Curves.easeOut.transform(((p - 0.55) / 0.45).clamp(0.0, 1.0));
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: 0.32 * ringOpacity);

    canvas.drawCircle(center, 64 - (5 * ringOpacity), ringPaint);
  }

  @override
  bool shouldRepaint(covariant VoiceFormationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.symbol != symbol ||
        oldDelegate.color != color;
  }
}
