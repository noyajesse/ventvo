import 'resonance_signal.dart';

/// Structured interpretation of a human experience for Resonance discovery.
///
/// The profile keeps raw signals while exposing their roles in the experience.
/// This gives the Resonance Engine a stable domain object without requiring
/// natural-language generation or AI.
class ResonanceProfile {
  final List<ResonanceSignal> signals;
  final List<ResonanceSignal> experiences;
  final List<ResonanceSignal> contexts;
  final List<ResonanceSignal> intents;
  final List<ResonanceSignal> relationships;
  final List<ResonanceSignal> constraints;
  final List<ResonanceComposition> compositions;

  const ResonanceProfile({
    required this.signals,
    required this.experiences,
    required this.contexts,
    required this.intents,
    required this.relationships,
    required this.constraints,
    required this.compositions,
  });

  bool get isPrivate => constraints.any(
        (signal) => signal.type == ResonanceSignalType.privacy,
      );

  bool get isSafetyRestricted => constraints.any(
        (signal) => signal.type == ResonanceSignalType.safety,
      );
}

/// A deterministic relationship between two or more signal dimensions.
class ResonanceComposition {
  final String key;
  final List<String> signalKeys;
  final double strength;

  const ResonanceComposition({
    required this.key,
    required this.signalKeys,
    required this.strength,
  });
}
