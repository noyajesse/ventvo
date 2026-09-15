enum VoiceManifestationMotion {
  unfold,
  ripple,
  emerge,
  open,
  settle,
  converge,
  breathe,
  trace,
  meet,
}

enum VoiceManifestationReveal {
  center,
  wave,
  spark,
  ring,
  grounded,
  overlap,
  pause,
  trail,
  intersection,
}

class VoiceSeedManifestation {
  final String seedId;
  final VoiceManifestationMotion motion;
  final VoiceManifestationReveal reveal;
  final Duration duration;
  final double intensity;

  const VoiceSeedManifestation({
    required this.seedId,
    required this.motion,
    required this.reveal,
    required this.duration,
    required this.intensity,
  });
}
