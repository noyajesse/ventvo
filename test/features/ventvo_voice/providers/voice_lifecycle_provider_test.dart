import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/ventvo_voice/providers/voice_lifecycle_provider.dart';

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

    test('moves to Resonance only when resonance exists', () {
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

    test('Arc takes precedence over earlier stages', () {
      expect(
        voiceLifecycleStageFor(
          hasExpression: false,
          hasResonance: false,
          arcCount: 2,
        ),
        VoiceLifecycleStage.becoming,
      );
    });
  });

  group('VoiceLifecycleSnapshot', () {
    test('reports every earlier stage as reached', () {
      const snapshot = VoiceLifecycleSnapshot(
        stage: VoiceLifecycleStage.resonance,
        ventCount: 2,
        resonanceCount: 1,
        arcCount: 0,
        hasExpression: true,
        hasResonance: true,
      );

      expect(snapshot.hasReached(VoiceLifecycleStage.seed), isTrue);
      expect(snapshot.hasReached(VoiceLifecycleStage.expression), isTrue);
      expect(snapshot.hasReached(VoiceLifecycleStage.resonance), isTrue);
      expect(snapshot.hasReached(VoiceLifecycleStage.becoming), isFalse);
    });
  });
}
