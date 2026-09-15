import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/ventvo_voice/models/ventvo_voice.dart';
import 'package:ventvo/features/ventvo_voice/services/voice_identity_catalog.dart';
import 'package:ventvo/features/ventvo_voice/services/voice_seed_discovery_service.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1);

  test('random discovery can select every catalog Seed', () {
    final selected = <String>{};
    final service = VoiceSeedDiscoveryService(random: Random(7));

    for (var i = 0; i < VoiceIdentityCatalog.seeds.length * 12; i++) {
      selected.add(service.discoverRandom().id);
    }

    expect(
      selected,
      containsAll(VoiceIdentityCatalog.seeds.map((seed) => seed.id)),
    );
  });

  test('random discovery never treats VAELOR as a fallback', () {
    final service = VoiceSeedDiscoveryService(random: Random(1));
    final seeds = List.generate(
      VoiceIdentityCatalog.seeds.length,
      (_) => service.discover(VentvoVoice(createdAt: DateTime(2026, 1, 1))),
    );

    expect(seeds.map((seed) => seed.id).toSet().length, greaterThan(1));
  });

  test('preserves an existing Ventvo Seed name', () {
    final voice = VentvoVoice(
      name: 'NYVEN',
      mark: '✦',
      resonance: 'Stillness',
      createdAt: DateTime(2026, 1, 1),
    );

    final service = VoiceSeedDiscoveryService(random: Random(4));
    final seed = service.discover(voice);

    expect(seed.id, 'nyven');
  });

  test('random selection is deterministic with an injected random source', () {
    final first = VoiceSeedDiscoveryService(random: Random(42));
    final second = VoiceSeedDiscoveryService(random: Random(42));

    final firstIds = List.generate(10, (_) => first.discoverRandom().id);
    final secondIds = List.generate(10, (_) => second.discoverRandom().id);

    expect(secondIds, firstIds);
  });

  test('discovery of an existing Seed remains stable', () {
    final voice = VentvoVoice(
      name: 'AUREN',
      createdAt: DateTime(2026, 1, 1),
    );

    final service = VoiceSeedDiscoveryService(random: Random(99));
    final first = service.discover(voice);
    final second = service.discover(voice);

    expect(first.id, 'auren');
    expect(second.id, first.id);
    expect(VoiceIdentityCatalog.seedById(second.id).word, second.word);
  });

  test('a Voice with no identity can receive any valid Seed', () {
    final voice = VentvoVoice(createdAt: DateTime(2026, 1, 1));
    final service = VoiceSeedDiscoveryService(random: Random(19));

    final seed = service.discover(voice);

    expect(
      VoiceIdentityCatalog.seeds.map((item) => item.id),
      contains(seed.id),
    );
  });

  test('existing Seed identity takes priority over random discovery', () {
    final voice = VentvoVoice(
      name: 'VEYRA',
      createdAt: DateTime(2026, 1, 1),
    );
    final service = VoiceSeedDiscoveryService(random: Random(1));

    expect(service.discover(voice).id, 'veyra');
  });

  test('the catalog contains one manifestation for every Seed', () {
    expect(
      VoiceIdentityCatalog.manifestations.map((item) => item.seedId).toSet(),
      containsAll(VoiceIdentityCatalog.seeds.map((seed) => seed.id)),
    );
  });

  test('random discovery uses the full Seed catalog', () {
    final service = VoiceSeedDiscoveryService(random: Random(123));
    final results = List.generate(100, (_) => service.discoverRandom());

    expect(
      results.every(
        (seed) => VoiceIdentityCatalog.seeds.any((item) => item.id == seed.id),
      ),
      isTrue,
    );
  });

  test('random discovery does not mutate the Voice', () {
    final voice = VentvoVoice(createdAt: DateTime(2026, 1, 1));

    final service = VoiceSeedDiscoveryService(random: Random(8));
    service.discover(voice);

    expect(voice.name, isNull);
    expect(voice.mark, isNull);
    expect(voice.createdAt, createdAt);
  });
}
