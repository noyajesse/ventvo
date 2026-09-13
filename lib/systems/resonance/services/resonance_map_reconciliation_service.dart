import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import 'resonance_engine.dart';
import 'resonance_map_integrity_policy.dart';

class ResonanceMapReconciliationResult {
  final ResonanceMap map;
  final ResonanceMapIntegrityDecision decision;

  const ResonanceMapReconciliationResult({
    required this.map,
    required this.decision,
  });
}

/// Reconciles a persisted Map with the latest Resonance connection state.
///
/// A Map preserves historical connections. Reconciliation refreshes links
/// returned by Resonance, keeps historical links that are no longer active,
/// and derives the Map's current integrity through the Map integrity policy.
class ResonanceMapReconciliationService {
  final ResonanceEngine engine;
  final ResonanceMapIntegrityPolicy integrityPolicy;

  const ResonanceMapReconciliationService({
    required this.engine,
    this.integrityPolicy = const ResonanceMapIntegrityPolicy(),
  });

  Future<ResonanceMapReconciliationResult?> reconcile(String mapId) async {
    if (mapId.trim().isEmpty) {
      throw ArgumentError.value(
        mapId,
        'mapId',
        'Map id cannot be empty.',
      );
    }

    final existingMap = await engine.getMap(mapId);
    if (existingMap == null) {
      return null;
    }

    final latestConnections = await _getLatestConnections(existingMap);
    final reconciledMap = existingMap.copyWith(
      connections: _mergeConnections(
        historical: existingMap.connections,
        latest: latestConnections,
      ),
    );

    final decision = integrityPolicy.evaluate(reconciledMap);
    await engine.saveMap(reconciledMap);

    return ResonanceMapReconciliationResult(
      map: reconciledMap,
      decision: decision,
    );
  }

  Future<List<ResonanceConnection>> _getLatestConnections(
    ResonanceMap map,
  ) async {
    final connectionsById = <String, ResonanceConnection>{};

    for (final experienceId in map.experienceIds) {
      final connections = await engine.getConnectionsInvolving(experienceId);
      for (final connection in connections) {
        if (map.containsExperience(connection.sourceId) &&
            map.containsExperience(connection.targetId)) {
          connectionsById[connection.id] = connection;
        }
      }
    }

    return connectionsById.values.toList(growable: false);
  }

  List<ResonanceConnection> _mergeConnections({
    required List<ResonanceConnection> historical,
    required List<ResonanceConnection> latest,
  }) {
    final latestById = {
      for (final connection in latest) connection.id: connection,
    };

    final merged = <ResonanceConnection>[];
    final seenIds = <String>{};

    for (final connection in historical) {
      final refreshed = latestById[connection.id] ?? connection;
      merged.add(refreshed);
      seenIds.add(refreshed.id);
    }

    for (final connection in latest) {
      if (seenIds.add(connection.id)) {
        merged.add(connection);
      }
    }

    return List.unmodifiable(merged);
  }
}
