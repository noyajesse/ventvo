import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/ventvo_voice/services/voice_identity_catalog.dart';

void main() {
  test('catalog contains the core Ventvo Voice Seeds', () {
    expect(VoiceIdentityCatalog.seeds.length, 9);
    expect(
      VoiceIdentityCatalog.seeds.map((seed) => seed.word).toSet().length,
      VoiceIdentityCatalog.seeds.length,
    );
  });

  test('each Voice Seed has a unique mark and meaning', () {
    expect(
      VoiceIdentityCatalog.seeds.map((seed) => seed.mark.symbol).toSet().length,
      VoiceIdentityCatalog.seeds.length,
    );
    expect(
      VoiceIdentityCatalog.seeds.every((seed) => seed.meaning.isNotEmpty),
      isTrue,
    );
  });

  test('catalog exposes Seed words as Voice names', () {
    expect(VoiceIdentityCatalog.names, [
      'VAELOR',
      'NYVEN',
      'AUREN',
      'SENYA',
      'ORVAN',
      'ELVAE',
      'NARETH',
      'VEYRA',
      'KAVEN',
    ]);
  });

  test('mark lookup falls back safely', () {
    expect(
      VoiceIdentityCatalog.markById('missing').id,
      VoiceIdentityCatalog.marks.first.id,
    );
    expect(
      VoiceIdentityCatalog.markBySymbol('missing').id,
      VoiceIdentityCatalog.marks.first.id,
    );
  });

  test('Seed lookup falls back safely', () {
    expect(
      VoiceIdentityCatalog.seedById('missing').id,
      VoiceIdentityCatalog.seeds.first.id,
    );
    expect(
      VoiceIdentityCatalog.seedByWord('missing').id,
      VoiceIdentityCatalog.seeds.first.id,
    );
  });
}
