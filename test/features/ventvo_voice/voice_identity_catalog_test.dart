import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/ventvo_voice/services/voice_identity_catalog.dart';

void main() {
  test('catalog contains multiple meaningful Voice marks', () {
    expect(VoiceIdentityCatalog.marks.length, greaterThan(1));
    expect(
      VoiceIdentityCatalog.marks.map((mark) => mark.id).toSet().length,
      VoiceIdentityCatalog.marks.length,
    );
  });

  test('catalog contains multiple Voice names', () {
    expect(VoiceIdentityCatalog.names.length, greaterThan(1));
    expect(
      VoiceIdentityCatalog.names.toSet().length,
      VoiceIdentityCatalog.names.length,
    );
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
}
