import 'resonance_connection.dart';

/// A small cluster of experiences that may be offered a temporary Gathering.
///
/// This is deliberately a candidate, not a chat room. A candidate only exists
/// when existing Resonance relationships form a meaningful connected cluster.
/// Participation is a separate, opt-in step.
class ResonanceGatheringCandidate {
  final String id;
  final String mapId;
  final List<String> experienceIds;
  final List<ResonanceConnection> connections;

  const ResonanceGatheringCandidate({
    required this.id,
    required this.mapId,
    required this.experienceIds,
    required this.connections,
  });

  bool containsExperience(String experienceId) {
    return experienceIds.contains(experienceId);
  }
}
