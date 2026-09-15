import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/ventvo_voice/providers/voice_lifecycle_provider.dart';

void main() {
  group('voiceLifecycleStageFor', () {
    test('starts at Seed', () {
      expect(
        voiceLifecycleStageFor(
          hasExpression: false,
          hasResonance: false,
          arcCount: 0,
        ),
        VoiceLifecycleStage.seed,
      );
    });

    test('moves to Expression when the Voice has something to carry', () {
      expect(
        voiceLifecycleStageFor(
          hasExpression: true,
          hasResonance: false,
          arcCount: 0,
        ),
        VoiceLifecycleStage.expression,
      );
    });

    test('moves to Resonance when recognition begins', () {
      expect(
        voiceLifecycleStageFor(
          hasExpression: true,
          hasResonance: true,
          arcCount: 0,
        ),
        VoiceLifecycleStage.resonance,
      );
    });

    test('moves to Becoming when an Arc exists', () {
      expect(
        voiceLifecycleStageFor(
          hasExpression: true,
          hasResonance: true,
          arcCount: 1,
        ),
        VoiceLifecycleStage.becoming,
      );
    });
  });
}
