import '../../../features/spaces/models/echo_note.dart';
import '../models/resonance_signal.dart';

/// Converts an Echo Note into explainable Resonance signals.
///
/// Echo Notes are reflections attached to an existing Echo. They enrich the
/// existing human connection; they do not become standalone Resonance
/// candidates or public profile data.
class EchoNoteResonanceSignalGenerator {
  const EchoNoteResonanceSignalGenerator();

  List<ResonanceSignal> generate({required EchoNote note}) {
    final signals = <ResonanceSignal>[
      const ResonanceSignal(
        type: ResonanceSignalType.relationship,
        key: 'echo_note',
        strength: 1,
      ),
    ];

    final normalized = note.content.toLowerCase();

    void add(String key, {double strength = 0.7}) {
      signals.add(
        ResonanceSignal(
          type: ResonanceSignalType.experiential,
          key: key,
          strength: strength.clamp(0, 1).toDouble(),
        ),
      );
    }

    if (_containsAny(normalized, [
      'me too',
      'same here',
      'i felt this',
      'i feel this',
      'i went through this',
      'been through this',
      'experienced this',
    ])) {
      add('shared_experience', strength: 0.9);
    }

    if (_containsAny(normalized, [
      'reminded me',
      'brought back',
      'this brought up',
      'made me remember',
    ])) {
      add('personal_reflection', strength: 0.85);
    }

    if (_containsAny(normalized, [
      'understand',
      'i get it',
      'i know how this feels',
      'know how you feel',
    ])) {
      add('understanding', strength: 0.85);
    }

    if (_containsAny(normalized, [
      'different for me',
      'my experience was different',
      'i saw it differently',
      'from my perspective',
    ])) {
      signals.add(
        const ResonanceSignal(
          type: ResonanceSignalType.experiential,
          key: 'different_perspective',
          strength: 0.75,
        ),
      );
    }

    return List.unmodifiable(signals);
  }

  bool _containsAny(String content, List<String> phrases) {
    return phrases.any((phrase) => content.contains(phrase));
  }
}
