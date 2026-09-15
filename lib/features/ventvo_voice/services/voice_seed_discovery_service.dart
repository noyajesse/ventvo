import 'dart:math';

import '../models/ventvo_voice.dart';
import '../models/voice_seed.dart';
import 'voice_identity_catalog.dart';

/// Determines the Voice Seed Ventvo should reveal.
///
/// A first-time Voice is not configured through questions or assigned a
/// personality. Ventvo gives the Voice a starting point, then lets real
/// experience shape it over time.
class VoiceSeedDiscoveryService {
  VoiceSeedDiscoveryService({Random? random}) : _random = random;

  final Random? _random;

  /// Returns an existing Seed when the Voice already has one.
  ///
  /// If the Voice has no Seed yet, a random Seed is selected. No Seed is a
  /// fallback, and VAELOR has no special priority.
  VoiceSeed discover(VentvoVoice voice) {
    final existingSeed = _seedFromName(voice.name);
    if (existingSeed != null) return existingSeed;

    return discoverRandom();
  }

  /// Selects a starting Seed without asking the user to configure anything.
  ///
  /// The random source is injectable so the selection remains deterministic
  /// in tests while production uses a secure random source.
  VoiceSeed discoverRandom() {
    final seeds = VoiceIdentityCatalog.seeds;
    if (seeds.isEmpty) {
      throw StateError('Ventvo must define at least one Voice Seed.');
    }

    final random = _random ?? Random.secure();
    return seeds[random.nextInt(seeds.length)];
  }

  VoiceSeed? _seedFromName(String? name) {
    if (name == null || name.trim().isEmpty) return null;

    for (final seed in VoiceIdentityCatalog.seeds) {
      if (seed.word.toLowerCase() == name.trim().toLowerCase()) {
        return seed;
      }
    }
    return null;
  }
}
