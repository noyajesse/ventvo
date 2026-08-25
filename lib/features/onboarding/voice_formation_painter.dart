import 'dart:math' as math;

import 'package:flutter/material.dart';

class VoiceFormationPainter extends CustomPainter {
  const VoiceFormationPainter({
    required this.progress,
    required this.symbol,
    required this.color,
    required this.breath,
  });

  final double progress;
  final String symbol;
  final Color color;
  final double breath;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final raw = progress.clamp(0.0, 1.0);

    // Formation stages:
    // 0.00 - 0.18 : quiet beginning
    // 0.18 - 0.55 : particles gather
    // 0.55 - 0.78 : voice emerges
    // 0.78 - 0.92 : voice settles
    // 0.92 - 1.00 : final breathing moment

    final gathering = Curves.easeInOutCubic.transform(
      ((raw - 0.12) / 0.50).clamp(0.0, 1.0),
    );

    final emergence = Curves.easeOutCubic.transform(
      ((raw - 0.50) / 0.30).clamp(0.0, 1.0),
    );

    final settle = Curves.easeInOut.transform(
      ((raw - 0.76) / 0.24).clamp(0.0, 1.0),
    );

    // Very subtle breathing effect once the Voice has formed.
    final breathingScale =
        1.0 + ((breath - 0.5) * 0.035 * settle);

    // --------------------------------------------------
    // ORBIT
    // --------------------------------------------------

    final orbitRadius =
        82.0 - (46.0 * gathering);

    final orbitOpacity =
        (0.12 * (1.0 - gathering)) +
        (0.10 * settle);

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(
        alpha: orbitOpacity,
      );

    canvas.drawCircle(
      center,
      orbitRadius,
      orbitPaint,
    );

    // --------------------------------------------------
    // PARTICLES
    // --------------------------------------------------

    for (var i = 0; i < 14; i++) {
      final baseAngle =
          math.pi * 2 * i / 14;

      // Particles orbit while moving inward.
      final rotation =
          gathering * math.pi * 0.75;

      final angle =
          baseAngle + rotation;

      final startingRadius =
          70.0 + ((i % 4) * 7.0);

      final finalRadius =
          14.0 + ((i % 3) * 3.0);

      final radius =
          startingRadius +
          ((finalRadius - startingRadius) *
              gathering);

      final point =
          center +
          Offset(
            math.cos(angle),
            math.sin(angle),
          ) *
              radius;

      final opacity =
          0.65 * (1.0 - gathering);

      final particleSize =
          1.7 +
          (2.2 * emergence) +
          (breath * 0.5 * settle);

      final particlePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(
          alpha: opacity,
        );

      canvas.drawCircle(
        point,
        particleSize,
        particlePaint,
      );
    }

    // --------------------------------------------------
    // VOICE MARK EMERGENCE
    // --------------------------------------------------

    final markOpacity =
        Curves.easeOutCubic.transform(
      ((raw - 0.42) / 0.38).clamp(0.0, 1.0),
    );

    final markSize =
        (58.0 + (14.0 * emergence)) *
            breathingScale;

    final markPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: color.withValues(
            alpha: markOpacity,
          ),
          fontSize: markSize,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    markPainter.paint(
      canvas,
      center -
          Offset(
            markPainter.width / 2,
            markPainter.height / 2,
          ),
    );

    // --------------------------------------------------
    // FINAL RING
    // --------------------------------------------------

    final ringOpacity =
        Curves.easeOutCubic.transform(
      ((raw - 0.66) / 0.25).clamp(0.0, 1.0),
    );

    final ringRadius =
        (69.0 - (4.0 * ringOpacity)) *
            breathingScale;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(
        alpha: 0.32 * ringOpacity,
      );

    canvas.drawCircle(
      center,
      ringRadius,
      ringPaint,
    );

    // --------------------------------------------------
    // SUBTLE GLOW
    // --------------------------------------------------

    final glowOpacity =
        0.05 * settle;

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(
        alpha: glowOpacity,
      );

    canvas.drawCircle(
      center,
      62.0 * breathingScale,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant VoiceFormationPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.symbol != symbol ||
        oldDelegate.color != color ||
        oldDelegate.breath != breath;
  }
}