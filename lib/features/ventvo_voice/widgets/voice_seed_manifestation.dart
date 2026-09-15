import 'package:flutter/material.dart';

import '../models/voice_seed.dart';
import '../services/voice_identity_catalog.dart';

/// Renders the visual language of a Voice Seed.
///
/// The animation is intentionally driven by the Seed's manifestation profile
/// rather than by a generic animation shared by every identity. VAELOR keeps
/// its existing discovery treatment for now; this widget provides the common
/// surface that future Seed-specific motion can grow from.
class VoiceSeedManifestation extends StatefulWidget {
  const VoiceSeedManifestation({
    required this.seed,
    this.size = 130,
    this.reveal = false,
    super.key,
  });

  final VoiceSeed seed;
  final double size;
  final bool reveal;

  @override
  State<VoiceSeedManifestation> createState() => _VoiceSeedManifestationState();
}

class _VoiceSeedManifestationState extends State<VoiceSeedManifestation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    final manifestation = VoiceIdentityCatalog.manifestationBySeedId(
      widget.seed.id,
    );

    _controller = AnimationController(
      vsync: this,
      duration: manifestation.duration,
    )..forward();

    _scale = CurvedAnimation(
      parent: _controller,
      curve: manifestation.revealCurve,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
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
        final pulse = 1 + (0.025 * _controller.value);
        final revealScale = widget.reveal ? _scale.value : 1.0;

        return Opacity(
          opacity: widget.reveal ? _opacity.value : 1,
          child: Transform.scale(
            scale: revealScale * pulse,
            child: Container(
              height: widget.size,
              width: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white24,
                  width: 2,
                ),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: manifestation.rotation * _controller.value,
                  child: Text(
                    widget.seed.mark.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 55,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
