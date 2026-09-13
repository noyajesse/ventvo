import '../models/resonance_candidate.dart';
import '../models/resonance_profile.dart';
import '../models/resonance_signal.dart';
import '../services/resonance_signal_composer.dart';

/// Explainable scoring rules for the first local Resonance engine.
///
/// The scorer rewards shared signals only when their meaning/type also agrees.
/// It also rewards shared composed dimensions such as an experience occurring
/// in the same context or with the same intent. Safety and privacy signals
/// remain protective constraints rather than requiring a matching keyword.
/// AI/embeddings can later provide richer signals without changing the engine
/// boundary.
class DeterministicResonanceScorer {
  const DeterministicResonanceScorer({
    this.composer = const ResonanceSignalComposer(),
  });

  final ResonanceSignalComposer composer;

  double score({
    required List<ResonanceSignal> sourceSignals,
    required ResonanceCandidate candidate,
  }) {
    return scoreProfiles(
      source: composer.compose(sourceSignals),
      candidateProfile: composer.compose(candidate.signals),
      candidate: candidate,
    );
  }

  double scoreProfiles({
    required ResonanceProfile source,
    required ResonanceProfile candidateProfile,
    required ResonanceCandidate candidate,
  }) {
    final sourceSignals = <String, double>{
      for (final signal in source.signals) _signalKey(signal): signal.strength,
    };

    var score = 0.0;
    final matchedTypes = <ResonanceSignalType>{};

    for (final signal in candidateProfile.signals) {
      final weight = _weightFor(signal.type);

      if (signal.type == ResonanceSignalType.privacy ||
          signal.type == ResonanceSignalType.safety) {
        score += weight * signal.strength;
        continue;
      }

      final sourceStrength = sourceSignals[_signalKey(signal)];
      if (sourceStrength == null) continue;

      score += sourceStrength * signal.strength * weight;
      matchedTypes.add(signal.type);
    }

    final sourceCompositions = <String, double>{
      for (final composition in source.compositions)
        composition.key: composition.strength,
    };

    for (final composition in candidateProfile.compositions) {
      final sourceStrength = sourceCompositions[composition.key];
      if (sourceStrength == null) continue;

      // Composed dimensions are supporting evidence, not a replacement for
      // the underlying signals. This keeps the first engine conservative.
      score += sourceStrength * composition.strength * 0.25;
    }

    // Experiences that resonate across more than one dimension are stronger
    // than experiences sharing only a single surface-level keyword.
    if (matchedTypes.length > 1) {
      score += 0.1 * (matchedTypes.length - 1);
    }

    return score.clamp(0.0, 1.0).toDouble();
  }

  String _signalKey(ResonanceSignal signal) => '${signal.type}:${signal.key}';

  double _weightFor(ResonanceSignalType type) => switch (type) {
        ResonanceSignalType.semantic => 1.0,
        ResonanceSignalType.experiential => 1.2,
        ResonanceSignalType.intent => 1.1,
        ResonanceSignalType.context => 0.9,
        ResonanceSignalType.relationship => 0.7,
        ResonanceSignalType.diversity => 0.4,
        ResonanceSignalType.privacy => -1.0,
        ResonanceSignalType.safety => -2.0,
        ResonanceSignalType.repetition => -0.8,
      };
}
