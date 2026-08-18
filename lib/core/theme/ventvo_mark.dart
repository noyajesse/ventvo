import 'package:flutter/material.dart';

import 'ventvo_colors.dart';

class VentvoMark extends StatelessWidget {
  const VentvoMark({
    super.key,
    this.size = 72,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _VentvoMarkPainter(),
      ),
    );
  }
}

class _VentvoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final scale = size.width / 72;

    final outerPaint = Paint()
      ..color = VentvoColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round;

    final innerPaint = Paint()
      ..color = VentvoColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round;

    // Central voice shape.
    final voicePath = Path()
      ..moveTo(
        center.dx - 13 * scale,
        center.dy - 17 * scale,
      )
      ..quadraticBezierTo(
        center.dx - 21 * scale,
        center.dy,
        center.dx - 13 * scale,
        center.dy + 17 * scale,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + 25 * scale,
        center.dx + 13 * scale,
        center.dy + 17 * scale,
      )
      ..quadraticBezierTo(
        center.dx + 21 * scale,
        center.dy,
        center.dx + 13 * scale,
        center.dy - 17 * scale,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy - 25 * scale,
        center.dx - 13 * scale,
        center.dy - 17 * scale,
      );

    canvas.drawPath(voicePath, outerPaint);

    // Inner resonance waves.
    final wavePath = Path()
      ..moveTo(
        center.dx - 7 * scale,
        center.dy - 9 * scale,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy,
        center.dx - 7 * scale,
        center.dy + 9 * scale,
      );

    canvas.drawPath(wavePath, innerPaint);

    final secondWavePath = Path()
      ..moveTo(
        center.dx + 1 * scale,
        center.dy - 13 * scale,
      )
      ..quadraticBezierTo(
        center.dx + 11 * scale,
        center.dy,
        center.dx + 1 * scale,
        center.dy + 13 * scale,
      );

    canvas.drawPath(secondWavePath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}