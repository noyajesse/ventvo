import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';

/// Business rules for growing an existing Resonance Map with a new experience.
///
/// Map evolution is intentionally narrower than reconciliation: reconciliation
/// refreshes links already inside a Map, while evolution expands the Map's
/// experience set through a meaningful live connection.
class ResonanceMapEvolutionPolicy {
  static const double minimumConnectionStrength = 0.6;

  const ResonanceMapEvolutionPolicy();

  ResonanceMapEvolutionDecision evaluate({
    required ResonanceMap map,
    required String experienceId,
    required List<ResonanceConnection> connections,
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
  }) {
    if (experienceId.trim().isEmpty) {
      return const ResonanceMapEvolutionDecision.ineligible(
        ResonanceMapEvolutionReason.invalidExperience,
      );
    }

    if (map.id.trim().isEmpty || map.experienceIds.length < 3) {
      return const ResonanceMapEvolutionDecision.ineligible(
        ResonanceMapEvolutionReason.invalidMap,
      );
    }

    if (isPrivacyRestricted) {
      return const ResonanceMapEvolutionDecision.ineligible(
        ResonanceMapEvolutionReason.privacyRestricted,
      );
    }

    if (isSafetyRestricted) {
      return const ResonanceMapEvolutionDecision.ineligible(
        ResonanceMapEvolutionReason.safetyRestricted,
      );
    }

    if (map.containsExperience(experienceId)) {
      return const ResonanceMapEvolutionDecision.ineligible(
        ResonanceMapEvolutionReason.alreadyInMap,
      );
    }

    final qualifyingConnections = connections.where((connection) {
      final connectsNewExperience =
          connection.sourceId == experienceId ||
          connection.targetId == experienceId;

      final connectsToMap =
          map.containsExperience(connection.sourceId) ||
          map.containsExperience(connection.targetId);

      final isLive = connection.state == ResonanceConnectionState.accepted ||
          connection.state == ResonanceConnectionState.active;

      final isMeaningful =
          connection.type == ResonanceConnectionType.sharedExperience ||
          connection.type == ResonanceConnectionType.response ||
          connection.type == ResonanceConnectionType.perspective;

      return connectsNewExperience &&
          connectsToMap &&
          isLive &&
          isMeaningful &&
          connection.strength >= minimumConnectionStrength;
    }).toList(growable: false);

    if (qualifyingConnections.isEmpty) {
      return const ResonanceMapEvolutionDecision.ineligible(
        ResonanceMapEvolutionReason.insufficientResonance,
      );
    }

    return ResonanceMapEvolutionDecision.eligible(
      connections: qualifyingConnections,
    );
  }
}

enum ResonanceMapEvolutionReason {
  allowed,
  invalidMap,
  invalidExperience,
  alreadyInMap,
  notConnectedToMap,
  connectionNotLive,
  insufficientResonance,
  privacyRestricted,
  safetyRestricted,
}

class ResonanceMapEvolutionDecision {
  final bool allowed;
  final ResonanceMapEvolutionReason reason;
  final List<ResonanceConnection> connections;

  const ResonanceMapEvolutionDecision._({
    required this.allowed,
    required this.reason,
    required this.connections,
  });

  const ResonanceMapEvolutionDecision.ineligible(
    ResonanceMapEvolutionReason reason,
  ) : this._(
          allowed: false,
          reason: reason,
          connections: const [],
        );

  ResonanceMapEvolutionDecision.eligible({
    required List<ResonanceConnection> connections,
  }) : this._(
          allowed: true,
          reason: ResonanceMapEvolutionReason.allowed,
          connections: List.unmodifiable(connections),
        );
}
