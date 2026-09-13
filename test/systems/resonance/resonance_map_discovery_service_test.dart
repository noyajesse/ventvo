import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_discovery_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_reconciliation_service.dart';

class FakeResonanceMapEngine implements ResonanceMapEngine {
  final Map<String, ResonanceMap> maps = {};
  final Map<String, List<ResonanceConnection>> connectionsByExperience = {};

  @override
  Future<void> saveMap(ResonanceMap map) async {
    maps[map.id] = map;
  }

  @override
  Future<ResonanceMap?> getMap(String mapId) async => maps[mapId];

  @override
  Future<List<ResonanceMap>> getMapsForExperience(String experienceId) async {
    return maps.values
        .where((map) => map.containsExperience(experienceId))
        .toList(growable: false);
  }

  @override
  Future<List<ResonanceMap>> getMaps() async {
    return maps.values.toList(growable: false);
  }

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
}) {
  return ResonanceConnection(
    id: id,
    sourceId: sourceId,
    targetId: targetId,
    type: ResonanceConnectionType.sharedExperience,
    strength: 0.8,
    state: ResonanceConnectionState.active,
    createdAt: createdAt,
  );
}

ResonanceMap map(String id, {List<ResonanceConnection> connections = const []}) {
  return ResonanceMap.create(
    id: id,
    experienceIds: const [
      'experience-1',
      'experience-2',
      'experience-3',
    ],
    connections: connections,
    createdAt: createdAt,
  );
}

ResonanceMapDiscoveryService createService(FakeResonanceMapEngine engine) {
  return ResonanceMapDiscoveryService(
    engine: engine,
    reconciliationService: ResonanceMapReconciliationService(engine: engine),
  );
}

void main() {
  test('discovers an active Map for an experience', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map('map-1');
    engine.connectionsByExperience['experience-1'] = [
      connection(
        id: 'connection-1',
        sourceId: 'experience-1',
        targetId: 'experience-2',
      ),
    ];

    final result = await createService(engine).discoverForExperience(
      'experience-1',
    );

    expect(result.map((map) => map.id), ['map-1']);
  });

  test('does not discover a dormant Map', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map(
      'map-1',
      connections: [
        connection(
          id: 'connection-1',
          sourceId: 'experience-1',
          targetId: 'experience-2',
        ).copyWith(state: ResonanceConnectionState.closed),
      ],
    );

    final result = await createService(engine).discoverAll();

    expect(result, isEmpty);
  });

  test('discovers Maps across Resonance with a limit', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map('map-1');
    engine.maps['map-2'] = map('map-2');
    engine.connectionsByExperience['experience-1'] = [
      connection(
        id: 'connection-1',
        sourceId: 'experience-1',
        targetId: 'experience-2',
      ),
    ];

    final result = await createService(engine).discoverAll(limit: 1);

    expect(result, hasLength(1));
  });

  test('deduplicates Maps returned by the engine', () async {
    final engine = FakeResonanceMapEngine();
    final activeMap = map('map-1');
    engine.maps['map-1'] = activeMap;
    engine.connectionsByExperience['experience-1'] = [
      connection(
        id: 'connection-1',
        sourceId: 'experience-1',
        targetId: 'experience-2',
      ),
    ];

    final result = await createService(engine).discoverForExperience(
      'experience-1',
    );

    expect(result, hasLength(1));
    expect(result.single.id, 'map-1');
  });

  test('rejects a blank experience id', () async {
    final service = createService(FakeResonanceMapEngine());

    expect(
      () => service.discoverForExperience('   '),
      throwsArgumentError,
    );
  });

  test('rejects a non-positive limit', () async {
    final service = createService(FakeResonanceMapEngine());

    expect(
      () => service.discoverAll(limit: 0),
      throwsArgumentError,
    );
  });
}
