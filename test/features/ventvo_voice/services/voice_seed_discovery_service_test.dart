import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/ventvo_voice/models/ventvo_voice.dart';
import 'package:ventvo/features/ventvo_voice/services/voice_identity_catalog.dart';
import 'package:ventvo/features/ventvo_voice/services/voice_seed_discovery_service.dart';

void main() {
  group('VoiceSeedDiscoveryService', () {
    test('selects a Seed from the catalog when no identity exists', () {
      final service = VoiceSeedDiscoveryService(random: Random(7));
      final voice = VentvoVoice(
        voiceId: 'voice-1',
        expression: null,
        resonance: null,
        mark: null,
        name: null,
        createdAt: DateTime(2026, 1, 1),
      );

      final seed = service.discover(voice);

      expect(
        VoiceIdentityCatalog.seeds.any((candidate) => candidate.id == seed.id),
        isTrue,
      );
    });

    test('does not use VAELOR as a no-signal fallback', () {
      final voice = VentvoVoice(
        voiceId: 'voice-2',
        expression: null,
        resonance: null,
        mark: null,
        name: null,
        createdAt: DateTime(2026, 1, 1),
      );

      final service = VoiceSeedDiscoveryService(random: _AlwaysNonVaelorRandom());

      expect(service.discover(voice).id, isNot('vaelor'));
    });

    test('preserves an existing Seed instead of randomizing it', () {
      final voice = VentvoVoice(
        voiceId: 'voice-3',
        expression: null,
        resonance: null,
        mark: null,
        name: 'NYVEN',
        createdAt: DateTime(2026, 1, 1),
      );

      final service = VoiceSeedDiscoveryService(random: _AlwaysNonVaelorRandom());

      expect(service.discover(voice).id, 'nyven');
    });
  });
}

class _AlwaysNonVaelorRandom implements Random {
  @override
  bool nextBool() => true;

  @override
  double nextDouble() => 0.5;

  @override
  int nextInt(int max) => max > 1 ? 1 : 0;
}
