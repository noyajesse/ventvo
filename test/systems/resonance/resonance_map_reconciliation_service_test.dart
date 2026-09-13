import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_reconciliation_service.dart';

a class FakeResonanceMapEngine implements ResonanceMapEngine {
  final Map<String, ResonanceMap> maps = {};
  final Map<String, List<ResonanceConnection>> connectionsByExperience = {};

  @override
  Future<void> saveMap(ResonanceMap map) async {
    maps[map.id] = map;
  }

  @override
  Future<ResonanceMap?> getMap(String mapId) async {
    return maps[mapId];
  }

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

const createdAt = DateTime(2026, 1, 1);

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
    experienceIds: const [
      'experience-1',
      'experience-2',
      'experience-3',
    ],
    connections: connections,
    createdAt: createdAt,
  );
}

void main() {
  test('refreshes an existing connection with its latest state', () async {
    final historical = connection(
      id: 'connection-1',
      sourceId: 'experience-1',
      targetId: 'experience-2',
    );
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map(connections: [historical]);
    engine.connectionsByExperience['experience-1'] = [
      historical.copyWith(state: ResonanceConnectionState.closed),
    ];

    final result = await ResonanceMapReconciliationService(engine: engine)
        .reconcile('map-1');

    expect(result, isNotNull);
    expect(result!.map.connections, hasLength(1));
    expect(
      result.map.connections.single.state,
      ResonanceConnectionState.closed,
    );
    expect(result.decision.isDormant, isTrue);
  });

  test('adds a newly discovered connection between Map experiences', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map();
    engine.connectionsByExperience['experience-1'] = [
      connection(
        id: 'connection-1',
        sourceId: 'experience-1',
        targetId: 'experience-2',
      ),
    ];

    final result = await ResonanceMapReconciliationService(engine: engine)
        .reconcile('map-1');

    expect(result!.map.connections, hasLength(1));
    expect(result.map.containsConnection('connection-1'), isTrue);
    expect(result.decision.isDiscoverable, isTrue);
  });

  test('preserves a historical connection missing from latest results', () async {
    final historical = connection(
      id: 'connection-1',
      sourceId: 'experience-1',
      targetId: 'experience-2',
      state: ResonanceConnectionState.closed,
    );
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map(connections: [historical]);

    final result = await ResonanceMapReconciliationService(engine: engine)
        .reconcile('map-1');

    expect(result!.map.connections, hasLength(1));
    expect(result.map.connections.single.id, 'connection-1');
    expect(result.map.connections.single.state, ResonanceConnectionState.closed);
  });

  test('ignores connections outside the Map experiences', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map();
    engine.connectionsByExperience['experience-1'] = [
      connection(
        id: 'outside-connection',
        sourceId: 'experience-1',
        targetId: 'experience-outside',
      ),
    ];

    final result = await ResonanceMapReconciliationService(engine: engine)
        .reconcile('map-1');

    expect(result!.map.connections, isEmpty);
  });

  test('returns null when the Map does not exist', () async {
    final engine = FakeResonanceMapEngine();

    final result = await ResonanceMapReconciliationService(engine: engine)
        .reconcile('missing-map');

    expect(result, isNull);
  });

  test('rejects a blank Map id', () async {
    final service = ResonanceMapReconciliationService(
      engine: FakeResonanceMapEngine(),
    );

    expect(
      () => service.reconcile('   '),
      throwsArgumentError,
    );
  });
}
