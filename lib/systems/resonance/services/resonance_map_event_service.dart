import '../models/resonance_connection.dart';
import 'resonance_engine.dart';
import 'resonance_map_evolution_service.dart';
import 'resonance_map_reconciliation_service.dart';

/// Orchestrates Map reactions to meaningful Resonance connection events.
///
/// This service is deliberately narrow: it reacts to lifecycle states that can
/// change Map membership. It does not create Maps, merge Maps, or decide
/// connection lifecycle state.
class ResonanceMapEventService {
  final ResonanceMapEngine mapEngine;
  final ResonanceMapEvolutionService evolutionService;
  final ResonanceMapReconciliationService reconciliationService;

  const ResonanceMapEventService({
    required this.mapEngine,
    required this.evolutionService,
    required this.reconciliationService,
  });

  /// Reacts to a persisted connection state transition.
  ///
  /// Only accepted and active connections can evolve a Map. If both endpoints
  /// already belong to the same Map, no evolution is attempted because there is
  /// no new experience to add. Maps are reconciled before evolution through
  /// [ResonanceMapEvolutionService].
  Future<void> handleConnectionStateChange(
    ResonanceConnection connection,
  ) async {
    if (!_canEvolve(connection)) return;

    final sourceMaps = await mapEngine.getMapsForExperience(
      connection.sourceId,
    );
    final targetMaps = await mapEngine.getMapsForExperience(
      connection.targetId,
    );

    final handledMapIds = <String>{};

    for (final map in sourceMaps) {
      if (map.containsExperience(connection.targetId)) continue;
      if (!handledMapIds.add(map.id)) continue;

      await evolutionService.evolveWithExperience(
        mapId: map.id,
        experienceId: connection.targetId,
      );
    }

    for (final map in targetMaps) {
      if (map.containsExperience(connection.sourceId)) continue;
      if (!handledMapIds.add(map.id)) continue;

      await evolutionService.evolveWithExperience(
        mapId: map.id,
        experienceId: connection.sourceId,
      );
    }
  }

  bool _canEvolve(ResonanceConnection connection) {
    return connection.state == ResonanceConnectionState.accepted ||
        connection.state == ResonanceConnectionState.active;
  }
}
