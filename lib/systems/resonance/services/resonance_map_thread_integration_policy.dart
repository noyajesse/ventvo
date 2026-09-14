import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import '../models/resonance_thread.dart';
import 'resonance_thread_integrity_policy.dart';

enum ResonanceMapThreadIntegrationReason {
  invalidMap,
  invalidThread,
  privacyRestricted,
  safetyRestricted,
  noOverlap,
  threadNotActive,
}

class ResonanceMapThreadIntegrationDecision {
  final bool isEligible;
  final ResonanceMapThreadIntegrationReason? reason;
  final List<String> experienceIds;
  final List<ResonanceConnection> connections;

  const ResonanceMapThreadIntegrationDecision._({
    required this.isEligible,
    required this.reason,
    required this.experienceIds,
    required this.connections,
  });

  const ResonanceMapThreadIntegrationDecision.eligible({
    required List<String> experienceIds,
    required List<ResonanceConnection> connections,
  }) : this._(
          isEligible: true,
          reason: null,
          experienceIds: experienceIds,
          connections: connections,
        );

  const ResonanceMapThreadIntegrationDecision.ineligible(
    ResonanceMapThreadIntegrationReason reason,
  ) : this._(
          isEligible: false,
          reason: reason,
          experienceIds: const [],
          connections: const [],
        );
}

/// Decides whether an existing Thread can become part of a Map.
///
/// A Thread represents a continuing path through experiences. A Map is a
/// larger structure that can contain several such paths. Integration therefore
/// expands the Map with the Thread's experiences and meaningful connections,
/// but never creates or modifies the Thread itself.
class ResonanceMapThreadIntegrationPolicy {
  final ResonanceThreadIntegrityPolicy threadIntegrityPolicy;

  const ResonanceMapThreadIntegrationPolicy({
    this.threadIntegrityPolicy = const ResonanceThreadIntegrityPolicy(),
  });

  ResonanceMapThreadIntegrationDecision evaluate({
    required ResonanceMap map,
    required ResonanceThread thread,
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
  }) {
    if (map.id.trim().isEmpty || map.experienceIds.length < 3) {
      return const ResonanceMapThreadIntegrationDecision.ineligible(
        ResonanceMapThreadIntegrationReason.invalidMap,
      );
    }

    if (thread.id.trim().isEmpty || thread.experienceIds.length < 3) {
      return const ResonanceMapThreadIntegrationDecision.ineligible(
        ResonanceMapThreadIntegrationReason.invalidThread,
      );
    }

    if (isPrivacyRestricted) {
      return const ResonanceMapThreadIntegrationDecision.ineligible(
        ResonanceMapThreadIntegrationReason.privacyRestricted,
      );
    }

    if (isSafetyRestricted) {
      return const ResonanceMapThreadIntegrationDecision.ineligible(
        ResonanceMapThreadIntegrationReason.safetyRestricted,
      );
    }

    final integrity = threadIntegrityPolicy.evaluate(thread);
    if (!integrity.isDiscoverable) {
      return const ResonanceMapThreadIntegrationDecision.ineligible(
        ResonanceMapThreadIntegrationReason.threadNotActive,
      );
    }

    final overlaps = thread.experienceIds
        .where(map.containsExperience)
        .toList(growable: false);

    if (overlaps.isEmpty) {
      return const ResonanceMapThreadIntegrationDecision.ineligible(
        ResonanceMapThreadIntegrationReason.noOverlap,
      );
    }

    final experienceIds = <String>{
      ...map.experienceIds,
      ...thread.experienceIds,
    }.toList(growable: false);

    return ResonanceMapThreadIntegrationDecision.eligible(
      experienceIds: experienceIds,
      connections: integrity.liveConnections,
    );
  }
}
