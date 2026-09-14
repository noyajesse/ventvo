import '../models/resonance_connection.dart';
import 'resonance_engine.dart';
import 'resonance_map_evolution_service.dart';

/// Orchestrates Map reactions to meaningful Resonance connection events.
///
/// This service is deliberately narrow: it reacts to lifecycle states that can
/// change Map membership. It does not create Maps, merge Maps, or decide
/// connection lifecycle state.
class ResonanceMapEventService {
  final ResonanceMapEngine mapEngine;
  final ResonanceMapEvolutionService evolutionService;

  const ResonanceMapEventService({
    required this.mapEngine,
    required this.evolutionService,
  });

  /// Reacts to a persisted connection state transition.
  ///
  /// Only accepted and active connections can evolve a Map. If both endpoints
  /// already belong to Maps, the event is ignored because connecting two
  /// established Maps is a future Map-merge concern rather than evolution.
  /// Reconciliation is delegated to the evolution service so there is one
  /// canonical Map-growth path.
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

    if (sourceMaps.isNotEmpty && targetMaps.isNotEmpty) return;

    if (sourceMaps.isNotEmpty) {
      for (final map in sourceMaps) {
        await evolutionService.evolveWithExperience(
          mapId: map.id,
          experienceId: connection.targetId,
        );
      }
      return;
    }

    if (targetMaps.isNotEmpty) {
      for (final map in targetMaps) {
        await evolutionService.evolveWithExperience(
          mapId: map.id,
          experienceId: connection.sourceId,
        );
      }
    }
  }

  bool _canEvolve(ResonanceConnection connection) {
    return connection.state == ResonanceConnectionState.accepted ||
        connection.state == ResonanceConnectionState.active;
  }
}
