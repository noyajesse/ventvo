import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../models/voice_seed.dart';
import '../models/voice_seed_manifestation.dart';
import '../services/voice_identity_catalog.dart';

/// Shared cinematic Voice Formation experience for every Seed.
///
/// VAELOR's original painter remains untouched in onboarding and is the visual
/// reference. Every other Seed now carries the same atmospheric foundation,
/// then expresses its identity through a distinct transformation layer.
class VoiceSeedManifestation extends StatefulWidget {
  const VoiceSeedManifestation({
    required this.seed,
    this.size = 130,
    this.reveal = true,
    super.key,
  });

  static const Duration formationDuration = Duration(milliseconds: 4800);

  final VoiceSeed seed;
  final double size;
  final bool reveal;

  @override
  State<VoiceSeedManifestation> createState() => _VoiceSeedManifestationState();
}

class _VoiceSeedManifestationState extends State<VoiceSeedManifestation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: VoiceSeedManifestation.formationDuration,
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
    final manifestation =
        VoiceIdentityCatalog.manifestationBySeedId(widget.seed.id);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => SizedBox(
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
      ),
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
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * .5;

    // The atmosphere is the shared VAELOR DNA: blue energy, orbit, gathering,
    // emergence, and a quiet living field around the forming Voice.
    _atmosphere(canvas, c, r);

    switch (seedId) {
      case 'nyven':
        _nyven(canvas, c, r);
      case 'auren':
        _auren(canvas, c, r);
      case 'senya':
        _senya(canvas, c, r);
      case 'orvan':
        _orvan(canvas, c, r);
      case 'elvae':
        _elvae(canvas, c, r);
      case 'nareth':
        _nareth(canvas, c, r);
      case 'veyra':
        _veyra(canvas, c, r);
      case 'kaven':
        _kaven(canvas, c, r);
      default:
        _neutral(canvas, c, r);
    }

    _presence(canvas, c, r);
    _voiceMark(canvas, c);
    _breathingField(canvas, c, r);
  }

  double _stage(
    double start,
    double end, [
    Curve curve = Curves.easeOutCubic,
  ]) {
    if (progress <= start) return 0;
    if (progress >= end) return 1;
    return curve.transform((progress - start) / (end - start));
  }

  /// Shared VAELOR-like blue energy field.
  ///
  /// It starts as a quiet orbit, gathers toward the Voice, and leaves a faint
  /// living field behind it. Seed-specific choreography is layered on top.
  void _atmosphere(Canvas canvas, Offset c, double r) {
    final gather = _stage(.08, .58, Curves.easeInOutCubic);
    final emerge = _stage(.50, .78, Curves.easeOutCubic);
    final settle = _stage(.78, 1, Curves.easeInOut);

    final orbitRadius = r * (.68 - .38 * gather);
    final orbitOpacity = .12 * (1 - gather) + .10 * settle;

    canvas.drawCircle(c, orbitRadius, _blueLine(orbitOpacity));

    // The particles use the same orbital gathering language as VAELOR, with
    // a slightly richer field so the other Seeds do not feel empty between
    // their identity-specific events.
    for (var i = 0; i < 18; i++) {
      final baseAngle = math.pi * 2 * i / 18 + .35;
      final rotation = gather * math.pi * .75;
      final angle = baseAngle + rotation;
      final startingRadius = r * (.68 + .06 * math.sin(i * 1.7));
      final finalRadius = r * (.13 + (i % 3) * .025);
      final radius = startingRadius +
          ((finalRadius - startingRadius) * gather);
      final point = c + _v(angle, radius);

      final opacity =
          (.46 * (1 - gather) + .11 * settle) * intensity;
      final particleSize =
          1.1 + (.65 * (1 - gather)) + (.9 * emerge) +
              (.35 * math.sin((i * 1.8) + progress * math.pi * 2).abs());

      _blueDot(canvas, point, particleSize, opacity);
    }

    // A soft central energy bloom appears as the Voice starts to emerge.
    final glow = Paint()
      ..style = PaintingStyle.fill
      ..color = VentvoColors.primary.withValues(
        alpha: (.025 + .055 * emerge) * intensity,
      );
    canvas.drawCircle(c, r * (.18 + .26 * emerge), glow);
  }

  /// Shared presence field: every Voice gets the same sense of arrival.
  void _presence(Canvas canvas, Offset c, double r) {
    final appear = _stage(.66, .90, Curves.easeOutCubic);
    final settle = _stage(.90, 1);
    final radius = r * (.18 + .38 * appear);
    final opacity = .10 + .16 * appear;

    canvas.drawCircle(c, radius, _blueLine(opacity * (1 - settle * .35)));
    canvas.drawCircle(c, radius * .74, _blueLine(opacity * .38));
  }

  /// Shared final breathing state: the Seed stops feeling like an animation
  /// and starts feeling like a presence.
  void _breathingField(Canvas canvas, Offset c, double r) {
    final breathe = _stage(.88, 1, Curves.easeInOut);
    final pulse = math.sin(breathe * math.pi);
    final radius = r * (.40 + .035 * pulse);
    canvas.drawCircle(c, radius, _blueLine(.08 + .08 * pulse));
  }

  /// Shared Voice Mark emergence. The mark is the destination of every
  /// formation, while the transformation leading to it remains Seed-specific.
  void _voiceMark(Canvas canvas, Offset c) {
    final emerge = _stage(.48, .78, Curves.easeOutBack);
    final settle = _stage(.78, .94, Curves.easeOutCubic);
    final opacity = emerge * (.82 + .18 * settle);
    final scale = .10 + .90 * emerge;
    final breath = _stage(.92, 1, Curves.easeInOut);
    final breathingScale = 1 + .025 * math.sin(breath * math.pi);

    _symbol(canvas, c, scale * breathingScale, opacity);
  }

  // NYVEN: streams converge, then resonance ripples back out.
  void _nyven(Canvas canvas, Offset c, double r) {
    final gather = _stage(.08, .58, Curves.easeInOutCubic);
    final ripple = _stage(.50, .88);

    for (var i = 0; i < 20; i++) {
      final side = i.isEven ? -1.0 : 1.0;
      final row = i ~/ 2;
      final start = Offset(
        c.dx + side * r * .72,
        c.dy + (row - 5) * r * .075,
      );
      final point = Offset.lerp(start, c, gather)!;
      _dot(canvas, point, 1.4 + 1.3 * math.sin(ripple * math.pi),
          .60 * (1 - gather) * intensity);
    }

    for (var i = 0; i < 3; i++) {
      final t = (ripple - i * .08).clamp(0.0, 1.0);
      if (t == 0) continue;
      final path = Path()
        ..moveTo(c.dx - r * .12 * t, c.dy + (i - 1) * r * .12)
        ..cubicTo(
          c.dx - r * .05 * t,
          c.dy - r * .15 * t,
          c.dx + r * .05 * t,
          c.dy + r * .15 * t,
          c.dx + r * .42 * t,
          c.dy + (i - 1) * r * .12,
        );
      canvas.drawPath(path, _line(.24 * intensity * (1 - ripple)));
    }
  }

  // AUREN: ignition at the centre becomes a controlled burst of rays.
  void _auren(Canvas canvas, Offset c, double r) {
    final ignite = _stage(.08, .40);
    final burst = _stage(.32, .72, Curves.easeOutBack);
    final settle = _stage(.72, .90);
    final glow = Paint()
      ..color = VentvoColors.primary.withValues(alpha: .07 * ignite * intensity);
    canvas.drawCircle(c, r * (.06 + .30 * burst), glow);

    for (var i = 0; i < 12; i++) {
      final a = math.pi * 2 * i / 12;
      canvas.drawLine(
        c + _v(a, r * (.08 + .10 * burst)),
        c + _v(a, r * (.18 + .30 * burst)),
        _line(.32 * intensity * (1 - settle)),
      );
    }
  }

  // SENYA: the space opens around the listener instead of closing in.
  void _senya(Canvas canvas, Offset c, double r) {
    final open = _stage(.08, .62);
    final settle = _stage(.62, .90);
    final gap = math.pi * (.28 - .08 * open);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * (.30 + .27 * open)),
      -math.pi / 2 + gap,
      math.pi * 2 - gap * 2,
      false,
      _line(.34 * intensity * (1 - settle)),
    );

    for (var i = 0; i < 14; i++) {
      final a = math.pi * 2 * i / 14;
      _dot(
        canvas,
        c + _v(a, r * (.55 - .15 * open)),
        1.1,
        .30 * (1 - open) * intensity,
      );
    }
  }

  // ORVAN: the experience carries weight and settles onto a ground line.
  void _orvan(Canvas canvas, Offset c, double r) {
    final fall = _stage(.08, .58, Curves.easeInCubic);
    final form = _stage(.34, .76, Curves.easeOutBack);
    final base = c.dy + r * .30;

    for (var i = 0; i < 16; i++) {
      final x = c.dx + (i - 7.5) * r * .065;
      final y = c.dy - r * .72 + (base - (c.dy - r * .72)) * fall;
      _dot(canvas, Offset(x, y), 1.4, .55 * (1 - fall) * intensity);
    }

    canvas.drawLine(
      Offset(c.dx - r * .48, base),
      Offset(c.dx + r * .48, base),
      _line(.34 * intensity * form),
    );

    final w = r * (.12 + .24 * form);
    final path = Path()
      ..moveTo(c.dx, c.dy - r * .22 * form)
      ..lineTo(c.dx + w, base)
      ..lineTo(c.dx - w, base)
      ..close();
    canvas.drawPath(path, _line(.25 * intensity * form));
  }

  // ELVAE: two experiences approach one another and become one recognition.
  void _elvae(Canvas canvas, Offset c, double r) {
    final meet = _stage(.08, .68, Curves.easeInOutCubic);
    final reveal = _stage(.52, .90, Curves.easeOutBack);
    final d = r * .42 * (1 - meet);
    final rr = r * .27;

    canvas.drawCircle(c.translate(-d, 0), rr, _line(.22 * (1 - reveal)));
    canvas.drawCircle(c.translate(d, 0), rr, _line(.22 * (1 - reveal)));

    for (var i = 0; i < 18; i++) {
      final a = math.pi * 2 * i / 18;
      final source = i.isEven ? c.translate(-d, 0) : c.translate(d, 0);
      _dot(
        canvas,
        Offset.lerp(source + _v(a, rr), c, meet)!,
        1.3,
        .42 * (1 - reveal) * intensity,
      );
    }

    canvas.drawCircle(c, rr * (.5 + .4 * reveal), _line(.20 * reveal));
  }

  // NARETH: almost nothing happens; the silence itself breathes.
  void _nareth(Canvas canvas, Offset c, double r) {
    final fade = _stage(.10, .62);
    final breath = math.sin(_stage(.10, 1, Curves.easeInOut) * math.pi);

    canvas.drawCircle(
      c,
      r * (.24 + .18 * breath),
      _line(.18 * (1 - fade) * intensity),
    );
    canvas.drawCircle(
      c,
      r * (.10 + .08 * breath),
      _line(.12 * (1 - fade) * intensity),
    );

    for (var i = 0; i < 8; i++) {
      final a = math.pi * 2 * i / 8;
      _dot(canvas, c + _v(a, r * .42), 1, .22 * (1 - fade) * intensity);
    }
  }

  // VEYRA: a moving trace leaves an imprint before the mark appears.
  void _veyra(Canvas canvas, Offset c, double r) {
    final trace = _stage(.08, .72);
    final settle = _stage(.64, .90);
    final rect = Rect.fromCircle(center: c, radius: r * .52);

    canvas.drawArc(
      rect,
      -math.pi * .86,
      math.pi * 1.55 * trace,
      false,
      _line(.34 * intensity * (1 - settle)),
    );
    canvas.drawArc(
      rect.shift(Offset(0, r * .06)),
      -math.pi * .62,
      math.pi * .82 * trace,
      false,
      _line(.18 * intensity * (1 - settle)),
    );

    final a = -math.pi * .86 + math.pi * 1.55 * trace;
    _dot(canvas, c + _v(a, r * .52), 2.2, .55 * (1 - settle) * intensity);
  }

  // KAVEN: independent paths meet at one point, then resolve into the mark.
  void _kaven(Canvas canvas, Offset c, double r) {
    final meet = _stage(.08, .68, Curves.easeInOutCubic);
    final settle = _stage(.62, .90);
    final starts = <Offset>[
      c + Offset(-r * .68, -r * .68),
      c + Offset(r * .68, r * .68),
      c + Offset(r * .68, -r * .68),
      c + Offset(-r * .68, r * .68),
    ];

    for (final start in starts) {
      final p = Offset.lerp(start, c, meet)!;
      canvas.drawLine(start, p, _line(.32 * intensity * (1 - settle)));
      _dot(canvas, p, 1.6, .50 * (1 - meet) * intensity);
    }

    canvas.drawCircle(c, r * (.08 + .15 * meet), _line(.22 * meet));
  }

  void _neutral(Canvas canvas, Offset c, double r) {
    final form = _stage(.12, .72, Curves.easeOutBack);
    canvas.drawCircle(c, r * (.12 + .18 * form), _line(.22 * form));
  }

  Offset _v(double angle, double distance) =>
      Offset(math.cos(angle) * distance, math.sin(angle) * distance);

  void _blueDot(Canvas canvas, Offset p, double radius, double opacity) {
    canvas.drawCircle(
      p,
      radius,
      Paint()
        ..color = VentvoColors.primary.withValues(
          alpha: opacity.clamp(0.0, 1.0).toDouble(),
        ),
    );
  }

  void _dot(Canvas canvas, Offset p, double radius, double opacity) {
    _blueDot(canvas, p, radius, opacity);
  }

  Paint _blueLine(double opacity) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..strokeCap = StrokeCap.round
    ..color = VentvoColors.primary.withValues(
      alpha: opacity.clamp(0.0, 1.0).toDouble(),
    );

  Paint _line(double opacity) => _blueLine(opacity);

  void _symbol(
    Canvas canvas,
    Offset c,
    double scale,
    double opacity, [
    double rotation = 0,
  ]) {
    final painter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: VentvoColors.primary.withValues(
            alpha: opacity.clamp(0.0, 1.0).toDouble(),
          ),
          fontSize: 55,
          height: 1,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation);
    canvas.scale(scale.clamp(0.0, 1.2).toDouble());
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeedManifestationPainter oldDelegate) =>
      oldDelegate.seedId != seedId ||
      oldDelegate.symbol != symbol ||
      oldDelegate.motion != motion ||
      oldDelegate.reveal != reveal ||
      oldDelegate.progress != progress ||
      oldDelegate.intensity != intensity;
}
