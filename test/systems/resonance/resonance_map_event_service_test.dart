import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_event_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_evolution_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_reconciliation_service.dart';

class FakeResonanceMapEngine implements ResonanceMapEngine {
  final Map<String, ResonanceMap> maps = {};
  final Map<String, List<ResonanceConnection>> connectionsByExperience = {};

  @override
  Future<void> saveMap(ResonanceMap map) async => maps[map.id] = map;

  @override
  Future<ResonanceMap?> getMap(String mapId) async => maps[mapId];

  @override
  Future<List<ResonanceMap>> getMapsForExperience(String experienceId) async {
    return maps.values
        .where((map) => map.containsExperience(experienceId))
        .toList(growable: false);
  }

  @override
  Future<List<ResonanceMap>> getMaps() async => maps.values.toList(growable: false);

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) async {
    return connectionsByExperience[id] ?? const [];
  }
}

final createdAt = DateTime(2026, 1, 1);

ResonanceConnection connection({
  required String id,
  required String sourceId,
  required String targetId,
  ResonanceConnectionState state = ResonanceConnectionState.active,
  ResonanceConnectionType type = ResonanceConnectionType.sharedExperience,
  double strength = 0.8,
}) {
  return ResonanceConnection(
    id: id,
    sourceId: sourceId,
    targetId: targetId,
    type: type,
    strength: strength,
    state: state,
    createdAt: createdAt,
  );
}

ResonanceMap map({List<ResonanceConnection> connections = const []}) {
  return ResonanceMap.create(
    id: 'map-1',
    experienceIds: const ['experience-1', 'experience-2', 'experience-3'],
    connections: connections,
    createdAt: createdAt,
  );
}

ResonanceMapEventService service(FakeResonanceMapEngine engine) {
  final reconciliation = ResonanceMapReconciliationService(engine: engine);
  return ResonanceMapEventService(
    mapEngine: engine,
    evolutionService: ResonanceMapEvolutionService(
      engine: engine,
      reconciliationService: reconciliation,
    ),
  );
}

void main() {
  test('accepted connection evolves a Map through the new endpoint', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map();
    engine.connectionsByExperience['experience-4'] = [
      connection(
        id: 'connection-4',
        sourceId: 'experience-1',
        targetId: 'experience-4',
        state: ResonanceConnectionState.accepted,
      ),
    ];

    await service(engine).handleConnectionStateChange(
      connection(
        id: 'connection-4',
        sourceId: 'experience-1',
        targetId: 'experience-4',
        state: ResonanceConnectionState.accepted,
      ),
    );

    expect(engine.maps['map-1']!.experienceIds, contains('experience-4'));
  });

  test('active connection evolves a Map through the new endpoint', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map();
    engine.connectionsByExperience['experience-4'] = [
      connection(
        id: 'connection-4',
        sourceId: 'experience-4',
        targetId: 'experience-1',
      ),
    ];

    await service(engine).handleConnectionStateChange(
      connection(
        id: 'connection-4',
        sourceId: 'experience-4',
        targetId: 'experience-1',
      ),
    );

    expect(engine.maps['map-1']!.experienceIds, contains('experience-4'));
  });

  test('suggested, closed, and blocked connections do not evolve Maps', () async {
    for (final state in [
      ResonanceConnectionState.suggested,
      ResonanceConnectionState.closed,
      ResonanceConnectionState.blocked,
    ]) {
      final engine = FakeResonanceMapEngine();
      engine.maps['map-1'] = map();
      engine.connectionsByExperience['experience-4'] = [
        connection(
          id: 'connection-4',
          sourceId: 'experience-1',
          targetId: 'experience-4',
          state: state,
        ),
      ];

      await service(engine).handleConnectionStateChange(
        connection(
          id: 'connection-4',
          sourceId: 'experience-1',
          targetId: 'experience-4',
          state: state,
        ),
      );

      expect(engine.maps['map-1']!.experienceIds, hasLength(3));
    }
  });

  test('does not evolve when both endpoints already belong to the same Map', () async {
    final existing = map();
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = existing;

    await service(engine).handleConnectionStateChange(
      connection(
        id: 'connection-4',
        sourceId: 'experience-1',
        targetId: 'experience-2',
      ),
    );

    expect(engine.maps['map-1']!.experienceIds, orderedEquals(existing.experienceIds));
  });

  test('does nothing when neither endpoint belongs to a Map', () async {
    final engine = FakeResonanceMapEngine();

    await service(engine).handleConnectionStateChange(
      connection(
        id: 'connection-4',
        sourceId: 'experience-4',
        targetId: 'experience-5',
      ),
    );

    expect(engine.maps, isEmpty);
  });

  test('does not evolve when resonance is too weak', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map();
    engine.connectionsByExperience['experience-4'] = [
      connection(
        id: 'weak',
        sourceId: 'experience-4',
        targetId: 'experience-1',
        strength: 0.59,
      ),
    ];

    await service(engine).handleConnectionStateChange(
      connection(
        id: 'connection-4',
        sourceId: 'experience-4',
        targetId: 'experience-1',
      ),
    );

    expect(engine.maps['map-1']!.experienceIds, hasLength(3));
  });
}
