import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/ventvo_voice/models/ventvo_voice.dart';
import 'package:ventvo/features/ventvo_voice/services/voice_identity_catalog.dart';
import 'package:ventvo/features/ventvo_voice/services/voice_seed_discovery_service.dart';

void main() {
  const service = VoiceSeedDiscoveryService();
  final createdAt = DateTime(2026, 1, 1);

  test('defaults to VAELOR when no discovery signals exist', () {
    const voice = VentvoVoice(createdAt: DateTime(2026, 1, 1));

    final seed = service.discover(voice);

    expect(seed.id, 'vaelor');
    expect(seed.word, 'VAELOR');
    expect(seed.mark.symbol, '◇');
  });

  test('preserves an existing Ventvo Seed name', () {
    const voice = VentvoVoice(
      name: 'NYVEN',
      mark: '✦',
      resonance: 'Stillness',
      createdAt: DateTime(2026, 1, 1),
    );

    final seed = service.discover(voice);

    expect(seed.id, 'nyven');
  });

  test('uses mark as a deterministic discovery signal', () {
    const voice = VentvoVoice(
      mark: '△',
      createdAt: DateTime(2026, 1, 1),
    );

    final seed = service.discover(voice);

    expect(seed.id, 'orvan');
  });

  test('combines resonance and expression signals', () {
    const voice = VentvoVoice(
      resonance: 'Spark',
      expression: 'I am changing and growing through this.',
      createdAt: DateTime(2026, 1, 1),
    );

    final seed = service.discover(voice);

    expect(seed.id, 'auren');
  });

  test('discovery remains stable for the same Voice', () {
    final voice = VentvoVoice(
      resonance: 'Flow',
      expression: 'I keep finding people who understand.',
      createdAt: createdAt,
    );

    final first = service.discover(voice);
    final second = service.discover(voice);

    expect(second.id, first.id);
    expect(VoiceIdentityCatalog.seedById(second.id).word, second.word);
  });
}
