import '../models/resonance_profile.dart';
import '../models/resonance_signal.dart';

/// Groups raw Resonance signals into an explainable experience profile.
///
/// This layer does not interpret language itself. It composes signals already
/// extracted by a signal generator so matching logic can reason about
/// experience + context + intent together.
class ResonanceSignalComposer {
  const ResonanceSignalComposer();

  ResonanceProfile compose(List<ResonanceSignal> signals) {
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
    final relationships = _byType(
      immutableSignals,
      ResonanceSignalType.relationship,
    );
    final constraints = immutableSignals
        .where(
          (signal) =>
              signal.type == ResonanceSignalType.privacy ||
              signal.type == ResonanceSignalType.safety,
        )
        .toList(growable: false);

    return ResonanceProfile(
      signals: immutableSignals,
      experiences: experiences,
      contexts: contexts,
      intents: intents,
      relationships: relationships,
      constraints: constraints,
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
}
