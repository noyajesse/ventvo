import '../models/resonance_candidate.dart';
import '../models/resonance_signal.dart';

/// Small, explainable scoring rule set for the first local Resonance engine.
///
/// Matching remains signal-based and deterministic. AI/embeddings can later
/// provide richer signals without changing the engine boundary.
class DeterministicResonanceScorer {
  const DeterministicResonanceScorer();

  double score({
    required List<ResonanceSignal> sourceSignals,
    required ResonanceCandidate candidate,
  }) {
    final source = <String, double>{
      for (final signal in sourceSignals) signal.key: signal.strength,
    };

    var score = 0.0;
    for (final signal in candidate.signals) {
      final sourceStrength = source[signal.key];
      if (sourceStrength == null) continue;

      final contribution = sourceStrength * signal.strength;
      score += switch (signal.type) {
        ResonanceSignalType.semantic => contribution * 1.0,
        ResonanceSignalType.experiential => contribution * 1.2,
        ResonanceSignalType.intent => contribution * 1.1,
        ResonanceSignalType.context => contribution * 0.9,
        ResonanceSignalType.relationship => contribution * 0.7,
        ResonanceSignalType.diversity => contribution * 0.4,
        ResonanceSignalType.privacy => -contribution,
        ResonanceSignalType.safety => -contribution * 2.0,
        ResonanceSignalType.repetition => -contribution * 0.8,
      };
    }

    return score.clamp(0.0, 1.0).toDouble();
  }
}
