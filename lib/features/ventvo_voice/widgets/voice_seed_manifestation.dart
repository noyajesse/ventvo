import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/voice_seed.dart';
import '../models/voice_seed_manifestation.dart';
import '../services/voice_identity_catalog.dart';

/// The visual surface through which a Voice Seed manifests itself.
///
/// A Seed is not represented by a shared animation with a changed symbol.
/// Each Seed has its own visual formation language while sharing the same
/// lightweight rendering infrastructure.
class VoiceSeedManifestation extends StatefulWidget {
  const VoiceSeedManifestation({
    required this.seed,
    this.size = 130,
    this.reveal = true,
    super.key,
  });

  final VoiceSeed seed;
  final double size;
  final bool reveal;

  @override
  State<VoiceSeedManifestation> createState() =>
      _VoiceSeedManifestationState();
}

class _VoiceSeedManifestationState extends State<VoiceSeedManifestation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final manifestation = VoiceIdentityCatalog.manifestationBySeedId(
      widget.seed.id,
    );
    _controller = AnimationController(
      vsync: this,
      duration: manifestation.duration,
    );

    if (widget.reveal) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manifestation = VoiceIdentityCatalog.manifestationBySeedId(
      widget.seed.id,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.size,
          width: widget.size,
          child: CustomPaint(
            painter: _SeedManifestationPainter(
              seedId: widget.seed.id,
              symbol: widget.seed.mark.symbol,
              motion: manifestation.motion,
              reveal: manifestation.reveal,
              progress: Curves.easeInOut.transform(_controller.value),
              intensity: manifestation.intensity,
            ),
          ),
        );
      },
    );
  }
}

class _SeedManifestationPainter extends CustomPainter {
  const _SeedManifestationPainter({
    required this.seedId,
    required this.symbol,
    required this.motion,
    required this.reveal,
    required this.progress,
    required this.intensity,
  });

  final String seedId;
  final String symbol;
  final VoiceManifestationMotion motion;
  final VoiceManifestationReveal reveal;
  final double progress;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.5;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.24 + (0.12 * intensity));
    canvas.drawCircle(center, radius - 1, borderPaint);

    if (seedId == 'vaelor') {
      _paintVaelor(canvas, center);
      return;
    }

    switch (seedId) {
      case 'nyven':
        _paintNyven(canvas, center, radius);
      case 'auren':
        _paintAuren(canvas, center, radius);
      case 'senya':
        _paintSenya(canvas, center, radius);
      case 'orvan':
        _paintOrvan(canvas, center, radius);
      case 'elvae':
        _paintElvae(canvas, center, radius);
      case 'nareth':
        _paintNareth(canvas, center, radius);
      case 'veyra':
        _paintVeyra(canvas, center, radius);
      case 'kaven':
        _paintKaven(canvas, center, radius);
      default:
        _paintNeutral(canvas, center, radius);
    }
  }

  // VAELOR remains the reference manifestation: the quiet symbol reveal is
  // intentionally kept simple rather than being replaced by the new system.
  void _paintVaelor(Canvas canvas, Offset center) {
    final revealProgress = Curves.easeOutBack.transform(progress);
    final pulse = 1 + (0.025 * progress);
    final opacity = Curves.easeOut.transform(progress);

    _paintSymbol(
      canvas,
      center,
      scale: revealProgress * pulse,
      opacity: opacity,
    );
  }

  // NYVEN: resonance travels outward as layered waves before settling on the
  // mark. The movement is horizontal rather than a generic scale animation.
  void _paintNyven(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.30 * intensity);
    final waveProgress = Curves.easeOut.transform(progress);

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final y = center.dy + ((i - 1) * radius * 0.16);
      final amplitude = radius * 0.18 * (1 - waveProgress);
      path.moveTo(center.dx - radius * 0.55, y);
      path.cubicTo(
        center.dx - radius * 0.28,
        y - amplitude,
        center.dx + radius * 0.28,
        y + amplitude,
        center.dx + radius * 0.55,
        y,
      );
      canvas.drawPath(path, paint);
    }

    _paintSymbol(
      canvas,
      center.translate(0, math.sin(waveProgress * math.pi) * 3),
      scale: 0.70 + (0.30 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
    );
  }

  // AUREN: a point of light grows from the centre, sending out short rays.
  void _paintAuren(Canvas canvas, Offset center, double radius) {
    final rayPaint = _linePaint((1 - progress) * 0.34 * intensity);
    final spark = Curves.easeOut.transform(progress);
    final rayRadius = radius * (0.18 + (0.38 * spark));

    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i;
      final inner = Offset(
        center.dx + math.cos(angle) * rayRadius * 0.55,
        center.dy + math.sin(angle) * rayRadius * 0.55,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * rayRadius,
        center.dy + math.sin(angle) * rayRadius,
      );
      canvas.drawLine(inner, outer, rayPaint);
    }

    _paintSymbol(
      canvas,
      center,
      scale: 0.50 + (0.50 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
      rotation: (1 - progress) * 0.18,
    );
  }

  // SENYA: an incomplete ring opens gently around the mark, leaving room.
  void _paintSenya(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.28 * intensity);
    final openProgress = Curves.easeOut.transform(progress);
    final sweep = math.pi * (0.55 + (1.15 * openProgress));
    final rect = Rect.fromCircle(center: center, radius: radius * 0.58);

    canvas.drawArc(rect, math.pi + ((math.pi - sweep) / 2), sweep, false, paint);

    _paintSymbol(
      canvas,
      center,
      scale: 0.62 + (0.38 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
    );
  }

  // ORVAN: the form descends and settles onto a grounded line.
  void _paintOrvan(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.28 * intensity);
    final settle = Curves.easeOut.transform(progress);
    final baseY = center.dy + radius * 0.34;
    final width = radius * (0.22 + (0.22 * settle));
    final top = center.dy - radius * (0.28 * settle);

    final triangle = Path()
      ..moveTo(center.dx, top)
      ..lineTo(center.dx + width, baseY)
      ..lineTo(center.dx - width, baseY)
      ..close();
    canvas.drawPath(triangle, paint);
    canvas.drawLine(
      Offset(center.dx - radius * 0.45, baseY),
      Offset(center.dx + radius * 0.45, baseY),
      paint,
    );

    _paintSymbol(
      canvas,
      center.translate(0, (1 - settle) * -8),
      scale: 0.72 + (0.28 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
    );
  }

  // ELVAE: two separate experiences draw toward one another and overlap.
  void _paintElvae(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.32 * intensity);
    final converge = Curves.easeOut.transform(progress);
    final separation = radius * (0.34 * (1 - converge));
    final circleRadius = radius * 0.36;

    canvas.drawCircle(
      Offset(center.dx - separation, center.dy),
      circleRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + separation, center.dy),
      circleRadius,
      paint,
    );

    _paintSymbol(
      canvas,
      center,
      scale: 0.58 + (0.42 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
    );
  }

  // NARETH: almost nothing happens. The form breathes instead of arriving.
  void _paintNareth(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.22 * intensity);
    final breathe = math.sin(progress * math.pi);
    final outer = radius * (0.25 + (0.22 * breathe));
    final inner = radius * (0.12 + (0.10 * breathe));

    canvas.drawCircle(center, outer, paint);
    canvas.drawCircle(center, inner, paint);

    _paintSymbol(
      canvas,
      center,
      scale: 0.64 + (0.36 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
    );
  }

  // VEYRA: a trace is left behind as the mark arrives.
  void _paintVeyra(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.30 * intensity);
    final trailProgress = Curves.easeOut.transform(progress);
    final rect = Rect.fromCircle(center: center, radius: radius * 0.52);

    canvas.drawArc(
      rect,
      -math.pi * 0.82,
      math.pi * 1.55 * trailProgress,
      false,
      paint,
    );
    canvas.drawArc(
      rect.shift(const Offset(0, 4)),
      -math.pi * 0.65,
      math.pi * 0.85 * trailProgress,
      false,
      paint..strokeWidth = 1,
    );

    _paintSymbol(
      canvas,
      center,
      scale: 0.52 + (0.48 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
      rotation: (1 - progress) * 0.1,
    );
  }

  // KAVEN: different directions meet at one shared point.
  void _paintKaven(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.32 * intensity);
    final meet = Curves.easeOut.transform(progress);
    final reach = radius * (0.28 + (0.28 * meet));

    final points = <Offset>[
      Offset(center.dx - reach, center.dy - reach),
      Offset(center.dx + reach, center.dy + reach),
      Offset(center.dx + reach, center.dy - reach),
      Offset(center.dx - reach, center.dy + reach),
    ];

    for (final point in points) {
      canvas.drawLine(point, center, paint);
    }

    _paintSymbol(
      canvas,
      center,
      scale: 0.58 + (0.42 * Curves.easeOutBack.transform(progress)),
      opacity: Curves.easeOut.transform(progress),
    );
  }

  void _paintNeutral(Canvas canvas, Offset center, double radius) {
    final paint = _linePaint((1 - progress) * 0.18 * intensity);
    canvas.drawCircle(center, radius * (0.2 + (0.45 * progress)), paint);
    _paintSymbol(canvas, center, scale: progress, opacity: progress);
  }

  Paint _linePaint(double opacity) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(
        alpha: opacity.clamp(0.0, 1.0).toDouble(),
      );
  }

  void _paintSymbol(
    Canvas canvas,
    Offset center, {
    required double scale,
    required double opacity,
    double rotation = 0,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: Colors.white.withValues(
            alpha: opacity.clamp(0.0, 1.0).toDouble(),
          ),
          fontSize: 55,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(scale.clamp(0.0, 1.2).toDouble());
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeedManifestationPainter oldDelegate) {
    return oldDelegate.seedId != seedId ||
        oldDelegate.symbol != symbol ||
        oldDelegate.motion != motion ||
        oldDelegate.reveal != reveal ||
        oldDelegate.progress != progress ||
        oldDelegate.intensity != intensity;
  }
}
