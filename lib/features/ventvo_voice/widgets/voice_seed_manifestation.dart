import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/voice_seed.dart';
import '../models/voice_seed_manifestation.dart';
import '../services/voice_identity_catalog.dart';

/// The visual surface through which a Voice Seed manifests itself.
///
/// Each Seed has its own motion/reveal vocabulary. The widget owns the
/// animation mechanics while the catalog owns the identity definition.
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
    _controller = AnimationController(
      vsync: this,
      duration: VoiceIdentityCatalog.manifestationBySeedId(widget.seed.id)
          .duration,
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
    required this.symbol,
    required this.motion,
    required this.reveal,
    required this.progress,
    required this.intensity,
  });

  final String symbol;
  final VoiceManifestationMotion motion;
  final VoiceManifestationReveal reveal;
  final double progress;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.5;
    final borderProgress = Curves.easeOut.transform(progress);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.24 + (0.12 * intensity));

    canvas.drawCircle(center, radius - 1, borderPaint);

    final symbolProgress = Curves.easeOutBack.transform(progress);
    var scale = 0.65 + (0.35 * symbolProgress);
    var rotation = 0.0;
    var offset = Offset.zero;

    switch (motion) {
      case VoiceManifestationMotion.unfold:
        scale *= 0.94 + (0.06 * progress);
      case VoiceManifestationMotion.ripple:
        scale *= 0.92 + (0.08 * progress);
        offset = Offset(0, math.sin(progress * math.pi) * 2.5);
      case VoiceManifestationMotion.emerge:
        scale *= 0.72 + (0.28 * symbolProgress);
        rotation = (1 - progress) * 0.12;
      case VoiceManifestationMotion.open:
        scale *= 0.8 + (0.2 * progress);
      case VoiceManifestationMotion.settle:
        offset = Offset(0, (1 - progress) * -8);
        scale *= 0.9 + (0.1 * progress);
      case VoiceManifestationMotion.converge:
        scale *= 0.78 + (0.22 * symbolProgress);
        rotation = (1 - progress) * -0.08;
      case VoiceManifestationMotion.breathe:
        scale *= 0.94 + (math.sin(progress * math.pi) * 0.06);
      case VoiceManifestationMotion.trace:
        scale *= 0.78 + (0.22 * symbolProgress);
        rotation = (1 - progress) * 0.1;
      case VoiceManifestationMotion.meet:
        scale *= 0.8 + (0.2 * symbolProgress);
    }

    final revealOpacity = Curves.easeOut.transform(progress);
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: Colors.white.withOpacity(revealOpacity),
          fontSize: size.shortestSide * 0.42,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();

    _paintReveal(canvas, center, radius, borderProgress);
  }

  void _paintReveal(Canvas canvas, Offset center, double radius, double progress) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity((1 - progress) * 0.16 * intensity);

    switch (reveal) {
      case VoiceManifestationReveal.center:
        canvas.drawCircle(center, radius * (0.25 + (0.55 * progress)), paint);
      case VoiceManifestationReveal.wave:
        canvas.drawCircle(center, radius * (0.2 + (0.7 * progress)), paint);
        canvas.drawCircle(center, radius * (0.1 + (0.45 * progress)), paint);
      case VoiceManifestationReveal.spark:
        _paintRays(canvas, center, radius * (0.35 + (0.3 * progress)), paint);
      case VoiceManifestationReveal.ring:
        canvas.drawCircle(center, radius * (0.25 + (0.6 * progress)), paint);
      case VoiceManifestationReveal.grounded:
        canvas.drawLine(
          Offset(center.dx - radius * 0.35, center.dy + radius * 0.3),
          Offset(center.dx + radius * 0.35, center.dy + radius * 0.3),
          paint,
        );
      case VoiceManifestationReveal.overlap:
        canvas.drawCircle(
          Offset(center.dx - radius * 0.12, center.dy),
          radius * 0.42,
          paint,
        );
        canvas.drawCircle(
          Offset(center.dx + radius * 0.12, center.dy),
          radius * 0.42,
          paint,
        );
      case VoiceManifestationReveal.pause:
        canvas.drawCircle(center, radius * 0.45, paint);
      case VoiceManifestationReveal.trail:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.48),
          -math.pi * 0.8,
          math.pi * 1.2 * progress,
          false,
          paint,
        );
      case VoiceManifestationReveal.intersection:
        canvas.drawLine(
          Offset(center.dx - radius * 0.32, center.dy - radius * 0.32),
          Offset(center.dx + radius * 0.32, center.dy + radius * 0.32),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx + radius * 0.32, center.dy - radius * 0.32),
          Offset(center.dx - radius * 0.32, center.dy + radius * 0.32),
          paint,
        );
    }
  }

  void _paintRays(Canvas canvas, Offset center, double length, Paint paint) {
    for (var i = 0; i < 4; i++) {
      final angle = (math.pi / 2) * i;
      final start = Offset(
        center.dx + math.cos(angle) * length * 0.45,
        center.dy + math.sin(angle) * length * 0.45,
      );
      final end = Offset(
        center.dx + math.cos(angle) * length,
        center.dy + math.sin(angle) * length,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SeedManifestationPainter oldDelegate) {
    return oldDelegate.symbol != symbol ||
        oldDelegate.motion != motion ||
        oldDelegate.reveal != reveal ||
        oldDelegate.progress != progress ||
        oldDelegate.intensity != intensity;
  }
}
