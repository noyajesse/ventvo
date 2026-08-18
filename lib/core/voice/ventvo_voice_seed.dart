import 'ventvo_voice.dart';

class VentvoVoiceProfile {
  const VentvoVoiceProfile({
    required this.vaelorWeight,
    required this.nyvenWeight,
    required this.aurenWeight,
  });

  final double vaelorWeight;
  final double nyvenWeight;
  final double aurenWeight;

  const VentvoVoiceProfile.neutral()
      : vaelorWeight = 1 / 3,
        nyvenWeight = 1 / 3,
        aurenWeight = 1 / 3;

  VentvoVoice strongestVoice() {
    if (vaelorWeight >= nyvenWeight &&
        vaelorWeight >= aurenWeight) {
      return VentvoVoice.vaelor;
    }

    if (nyvenWeight >= vaelorWeight &&
        nyvenWeight >= aurenWeight) {
      return VentvoVoice.nyven;
    }

    return VentvoVoice.auren;
  }

  VentvoVoiceProfile copyWith({
    double? vaelorWeight,
    double? nyvenWeight,
    double? aurenWeight,
  }) {
    return VentvoVoiceProfile(
      vaelorWeight: vaelorWeight ?? this.vaelorWeight,
      nyvenWeight: nyvenWeight ?? this.nyvenWeight,
      aurenWeight: aurenWeight ?? this.aurenWeight,
    );
  }
}

/// The initial state of a user's public Ventvo Voice.
///
/// A Voice Seed is deliberately incomplete. It represents
/// the beginning of an evolving Voice rather than a final identity.
class VentvoVoiceSeed {
  const VentvoVoiceSeed({
    required this.profile,
    required this.mark,
    this.growth = 0,
  });

  final VentvoVoiceProfile profile;

  final String mark;

  final double growth;

  VentvoVoice get currentFoundation {
    return profile.strongestVoice();
  }

  String get name {
    return currentFoundation.name;
  }

  VentvoVoiceSeed copyWith({
    VentvoVoiceProfile? profile,
    String? mark,
    double? growth,
  }) {
    return VentvoVoiceSeed(
      profile: profile ?? this.profile,
      mark: mark ?? this.mark,
      growth: growth ?? this.growth,
    );
  }
}