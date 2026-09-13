import '../models/resonance_candidate.dart';
import '../models/resonance_profile.dart';
import '../models/resonance_signal.dart';

/// Explainable scoring rules for the first local Resonance engine.
///
/// The scorer rewards shared signals only when their meaning/type also agrees.
/// It also rewards shared composed dimensions such as an experience occurring
/// in the same context or with the same intent. Safety and privacy signals
/// remain protective constraints rather than requiring a matching keyword.
/// AI/embeddings can later provide richer signals without changing the engine
/// boundary.
class DeterministicResonanceScorer {
  const DeterministicResonanceScorer();

  double score({
    required List<ResonanceSignal> sourceSignals,
    required ResonanceCandidate candidate,
  }) {
    return scoreProfiles(
      source: _profileFrom(sourceSignals),
      candidate: _profileFrom(candidate.signals),
      candidate: candidate,
    );
  }

  double scoreProfiles({
    required ResonanceProfile source,
    required ResonanceProfile candidate,
    required ResonanceCandidate candidate,
  }) {
    final sourceSignals = <String, double>{
      for (final signal in source.signals) _signalKey(signal): signal.strength,
    };

    var score = 0.0;
    final matchedTypes = <ResonanceSignalType>{};

    for (final signal in candidate.signals) {
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

    for (final composition in candidate.compositions) {
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

  ResonanceProfile _profileFrom(List<ResonanceSignal> signals) {
    final immutableSignals = List<ResonanceSignal>.unmodifiable(signals);
    final experiences = _byType(
      immutableSignals,
      ResonanceSignalType.experiential,
    );
    final contexts = _byType(
      immutableSignals,
      ResonanceSignalType.semantic,
    );
    final intents = _byType(
      immutableSignals,
      ResonanceSignalType.intent,
    );

    return ResonanceProfile(
      signals: immutableSignals,
      experiences: experiences,
      contexts: contexts,
      intents: intents,
      relationships: _byType(
        immutableSignals,
        ResonanceSignalType.relationship,
      ),
      constraints: immutableSignals
          .where(
            (signal) =>
                signal.type == ResonanceSignalType.privacy ||
                signal.type == ResonanceSignalType.safety,
          )
          .toList(growable: false),
      compositions: _composeDimensions(
        experiences: experiences,
        contexts: contexts,
        intents: intents,
      ),
    );
  }

  List<ResonanceSignal> _byType(
    List<ResonanceSignal> signals,
    ResonanceSignalType type,
  ) {
    return List.unmodifiable(
      signals.where((signal) => signal.type == type),
    );
  }

  List<ResonanceComposition> _composeDimensions({
    required List<ResonanceSignal> experiences,
    required List<ResonanceSignal> contexts,
    required List<ResonanceSignal> intents,
  }) {
    final compositions = <ResonanceComposition>[];

    for (final experience in experiences) {
      for (final context in contexts) {
        compositions.add(
          ResonanceComposition(
            key: '${experience.key}_in_${context.key}',
            signalKeys: [experience.key, context.key],
            strength: _combinedStrength(experience, context),
          ),
        );
      }
    }

    for (final experience in experiences) {
      for (final intent in intents) {
        compositions.add(
          ResonanceComposition(
            key: '${experience.key}_with_${intent.key}',
            signalKeys: [experience.key, intent.key],
            strength: _combinedStrength(experience, intent),
          ),
        );
      }
    }

    return List.unmodifiable(compositions);
  }

  double _combinedStrength(
    ResonanceSignal first,
    ResonanceSignal second,
  ) {
    return ((first.strength + second.strength) / 2).clamp(0, 1).toDouble();
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
