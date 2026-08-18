import 'ventvo_voice.dart';
import 'ventvo_voice_seed.dart';

class VentvoVoiceSystem {
  const VentvoVoiceSystem();

  static const List<VentvoVoice> foundationalVoices = [
    VentvoVoice.vaelor,
    VentvoVoice.nyven,
    VentvoVoice.auren,
  ];

  /// Creates the first Voice Seed for a new user.
  ///
  /// A new user begins with a neutral internal profile.
  /// Ventvo does not pretend to know who they are yet.
  VentvoVoiceSeed createInitialSeed() {
    const profile = VentvoVoiceProfile.neutral();

    final foundation = profile.strongestVoice();

    return VentvoVoiceSeed(
      profile: profile,
      mark: foundation.mark,
      growth: 0,
    );
  }

  /// Applies a small expression-based influence to the Voice.
  ///
  /// This is intentionally simple for now.
  /// Later, real Ventvo expression signals can feed this method.
  VentvoVoiceSeed evolve(
    VentvoVoiceSeed seed, {
    double vaelorInfluence = 0,
    double nyvenInfluence = 0,
    double aurenInfluence = 0,
  }) {
    final updatedProfile = seed.profile.copyWith(
      vaelorWeight:
          seed.profile.vaelorWeight + vaelorInfluence,
      nyvenWeight:
          seed.profile.nyvenWeight + nyvenInfluence,
      aurenWeight:
          seed.profile.aurenWeight + aurenInfluence,
    );

    final foundation = updatedProfile.strongestVoice();

    return seed.copyWith(
      profile: updatedProfile,
      mark: foundation.mark,
      growth: (seed.growth + 0.01).clamp(0, 1),
    );
  }
}