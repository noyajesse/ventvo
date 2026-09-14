import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import 'resonance_engine.dart';
import 'resonance_map_formation_policy.dart';
import 'resonance_map_integrity_policy.dart';

/// Creates or extends Resonance Maps from meaningful relationship evidence.
///
/// Formation is intentionally separate from discovery and reconciliation:
/// discovery asks what can be surfaced, reconciliation asks what is current,
/// and formation asks whether a new Map should exist at all.
class ResonanceMapFormationService {
  final ResonanceMapEngine engine;
  final ResonanceMapFormationPolicy formationPolicy;
  final ResonanceMapIntegrityPolicy integrityPolicy;

  const ResonanceMapFormationService({
    required this.engine,
    this.formationPolicy = const ResonanceMapFormationPolicy(),
    this.integrityPolicy = const ResonanceMapIntegrityPolicy(),
  });

  /// Forms a Map around an experience when enough meaningful connections
  /// exist. If a Map already contains all selected experiences, it is reused
  /// and its connections are merged rather than creating a duplicate.
  Future<ResonanceMap?> formForExperience(
    String experienceId, {
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
    DateTime? createdAt,
  }) async {
    if (experienceId.trim().isEmpty) {
      throw ArgumentError.value(
        experienceId,
        'experienceId',
        'Experience id cannot be empty.',
      );
    }

    final connections = await engine.getConnectionsInvolving(experienceId);
    final decision = formationPolicy.evaluate(
      experienceId: experienceId,
      connections: connections,
      isPrivacyRestricted: isPrivacyRestricted,
      isSafetyRestricted: isSafetyRestricted,
    );

    if (!decision.isEligible) return null;

    final existing = await engine.getMapsForExperience(experienceId);
    for (final map in existing) {
      if (_containsAllExperiences(map, decision.experienceIds)) {
        final mergedConnections = _mergeConnections(
          map.connections,
          decision.connections,
        );
        final updated = map.copyWith(connections: mergedConnections);
        await engine.saveMap(updated);
        return updated;
      }
    }

    final map = ResonanceMap.create(
      id: _buildMapId(decision.experienceIds),
      experienceIds: decision.experienceIds,
      connections: decision.connections,
      createdAt: createdAt ?? DateTime.now(),
    );

    final integrity = integrityPolicy.evaluate(map);
    if (integrity.isInvalid) return null;

    await engine.saveMap(map);
    return map;
  }

  bool _containsAllExperiences(
    ResonanceMap map,
    List<String> experienceIds,
  ) {
    return experienceIds.every(map.containsExperience);
  }

  List<ResonanceConnection> _mergeConnections(
    List<ResonanceConnection> existing,
    List<ResonanceConnection> incoming,
  ) {
    final byId = <String, ResonanceConnection>{
      for (final connection in existing) connection.id: connection,
    };

    for (final connection in incoming) {
      byId[connection.id] = connection;
    }

    return byId.values.toList(growable: false);
  }

  String _buildMapId(List<String> experienceIds) {
    final sortedIds = [...experienceIds]..sort();
    return 'map-${sortedIds.join('-')}';
  }
}
