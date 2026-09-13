import '../models/resonance_connection.dart';
import '../models/resonance_thread.dart';

/// Business rules for allowing a new experience to join an existing Thread.
///
/// A Thread grows only through a meaningful, live Resonance Connection that
/// links the new experience to an experience already inside the Thread.
class ResonanceThreadEvolutionPolicy {
  static const double minimumConnectionStrength = 0.6;

  const ResonanceThreadEvolutionPolicy();

  ResonanceThreadEvolutionDecision evaluate({
    required ResonanceThread thread,
    required String experienceId,
    required ResonanceConnection connection,
  }) {
    if (experienceId.trim().isEmpty) {
      return const ResonanceThreadEvolutionDecision(
        allowed: false,
        reason: ResonanceThreadEvolutionReason.invalidExperience,
      );
    }

    if (thread.containsExperience(experienceId)) {
      return const ResonanceThreadEvolutionDecision(
        allowed: false,
        reason: ResonanceThreadEvolutionReason.alreadyInThread,
      );
    }

    final connectsToThread =
        (thread.containsExperience(connection.sourceId) &&
                connection.targetId == experienceId) ||
            (thread.containsExperience(connection.targetId) &&
                connection.sourceId == experienceId);

    if (!connectsToThread) {
      return const ResonanceThreadEvolutionDecision(
        allowed: false,
        reason: ResonanceThreadEvolutionReason.notConnectedToThread,
      );
    }

    if (connection.state != ResonanceConnectionState.accepted &&
        connection.state != ResonanceConnectionState.active) {
      return const ResonanceThreadEvolutionDecision(
        allowed: false,
        reason: ResonanceThreadEvolutionReason.connectionNotLive,
      );
    }

    if (connection.strength < minimumConnectionStrength) {
      return const ResonanceThreadEvolutionDecision(
        allowed: false,
        reason: ResonanceThreadEvolutionReason.insufficientResonance,
      );
    }

    return const ResonanceThreadEvolutionDecision(
      allowed: true,
      reason: ResonanceThreadEvolutionReason.allowed,
    );
  }
}

enum ResonanceThreadEvolutionReason {
  allowed,
  invalidExperience,
  alreadyInThread,
  notConnectedToThread,
  connectionNotLive,
  insufficientResonance,
}

class ResonanceThreadEvolutionDecision {
  final bool allowed;
  final ResonanceThreadEvolutionReason reason;

  const ResonanceThreadEvolutionDecision({
    required this.allowed,
    required this.reason,
  });
}
