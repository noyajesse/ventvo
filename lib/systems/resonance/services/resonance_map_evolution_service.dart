import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import 'resonance_engine.dart';
import 'resonance_map_evolution_policy.dart';
import 'resonance_map_integrity_policy.dart';
import 'resonance_map_reconciliation_service.dart';

/// Governs controlled growth of an existing Resonance Map.
///
/// Product features should use this service instead of mutating Map experience
/// or connection lists directly. Reconciliation runs first so evolution always
/// operates on the Map's latest known state.
class ResonanceMapEvolutionService {
  final ResonanceMapEngine engine;
  final ResonanceMapReconciliationService reconciliationService;
  final ResonanceMapEvolutionPolicy evolutionPolicy;
  final ResonanceMapIntegrityPolicy integrityPolicy;

  const ResonanceMapEvolutionService({
    required this.engine,
    required this.reconciliationService,
    this.evolutionPolicy = const ResonanceMapEvolutionPolicy(),
    this.integrityPolicy = const ResonanceMapIntegrityPolicy(),
  });

  Future<ResonanceMap?> evolveWithExperience({
    required String mapId,
    required String experienceId,
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
  }) async {
    if (mapId.trim().isEmpty) {
      throw ArgumentError.value(
        mapId,
        'mapId',
        'Map id cannot be empty.',
      );
    }

    if (experienceId.trim().isEmpty) {
      throw ArgumentError.value(
        experienceId,
        'experienceId',
        'Experience id cannot be empty.',
      );
    }

    final reconciliation = await reconciliationService.reconcile(mapId);
    if (reconciliation == null) {
      return null;
    }

    final map = reconciliation.map;
    final connections = await engine.getConnectionsInvolving(experienceId);
    final decision = evolutionPolicy.evaluate(
      map: map,
      experienceId: experienceId,
      connections: connections,
      isPrivacyRestricted: isPrivacyRestricted,
      isSafetyRestricted: isSafetyRestricted,
    );

    if (!decision.allowed) {
      if (decision.reason == ResonanceMapEvolutionReason.alreadyInMap) {
        return map;
      }
      return null;
    }

    final experienceIds = [
      ...map.experienceIds,
      experienceId,
    ];

    final mergedConnections = _mergeConnections(
      historical: map.connections,
      additions: decision.connections,
    );

    final updated = map.copyWith(
      experienceIds: experienceIds,
      connections: mergedConnections,
    );

    final integrity = integrityPolicy.evaluate(updated);
    if (integrity.isInvalid) {
      return null;
    }

    await engine.saveMap(updated);
    return updated;
  }

  List<ResonanceConnection> _mergeConnections({
    required List<ResonanceConnection> historical,
    required List<ResonanceConnection> additions,
  }) {
    final merged = <ResonanceConnection>[...historical];
    final seenIds = historical.map((connection) => connection.id).toSet();

    for (final connection in additions) {
      if (seenIds.add(connection.id)) {
        merged.add(connection);
      }
    }

    return List.unmodifiable(merged);
  }
}
