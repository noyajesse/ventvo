import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
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

ResonanceMapEvolutionService service(FakeResonanceMapEngine engine) {
  return ResonanceMapEvolutionService(
    engine: engine,
    reconciliationService: ResonanceMapReconciliationService(engine: engine),
  );
}

void main() {
  test('evolves a Map with a new experience through meaningful resonance', () async {
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map();
    engine.connectionsByExperience['experience-4'] = [
      connection(
        id: 'connection-4',
        sourceId: 'experience-4',
        targetId: 'experience-1',
      ),
    ];

    final result = await service(engine).evolveWithExperience(
      mapId: 'map-1',
      experienceId: 'experience-4',
    );

    expect(result, isNotNull);
    expect(result!.experienceIds, contains('experience-4'));
    expect(result.connections, hasLength(1));
    expect(result.containsConnection('connection-4'), isTrue);
  });

  test('is idempotent when the experience is already in the Map', () async {
    final engine = FakeResonanceMapEngine();
    final existing = map();
    engine.maps['map-1'] = existing;

    final result = await service(engine).evolveWithExperience(
      mapId: 'map-1',
      experienceId: 'experience-1',
    );

    expect(result, isNotNull);
    expect(result!.experienceIds, orderedEquals(existing.experienceIds));
  });

  test('rejects an experience with no qualifying Map connection', () async {
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

    final result = await service(engine).evolveWithExperience(
      mapId: 'map-1',
      experienceId: 'experience-4',
    );

    expect(result, isNull);
    expect(engine.maps['map-1']!.experienceIds, hasLength(3));
  });

  test('preserves existing connections while adding new ones', () async {
    final historical = connection(
      id: 'historical',
      sourceId: 'experience-1',
      targetId: 'experience-2',
    );
    final engine = FakeResonanceMapEngine();
    engine.maps['map-1'] = map(connections: [historical]);
    engine.connectionsByExperience['experience-4'] = [
      connection(
        id: 'new-connection',
        sourceId: 'experience-4',
        targetId: 'experience-1',
      ),
    ];

    final result = await service(engine).evolveWithExperience(
      mapId: 'map-1',
      experienceId: 'experience-4',
    );

    expect(result!.connections, hasLength(2));
    expect(result.containsConnection('historical'), isTrue);
    expect(result.containsConnection('new-connection'), isTrue);
  });

  test('returns null when the Map does not exist', () async {
    final engine = FakeResonanceMapEngine();

    final result = await service(engine).evolveWithExperience(
      mapId: 'missing-map',
      experienceId: 'experience-4',
    );

    expect(result, isNull);
  });

  test('rejects blank ids', () async {
    final engine = FakeResonanceMapEngine();
    final mapService = service(engine);

    expect(
      () => mapService.evolveWithExperience(
        mapId: '   ',
        experienceId: 'experience-4',
      ),
      throwsArgumentError,
    );

    expect(
      () => mapService.evolveWithExperience(
        mapId: 'map-1',
        experienceId: '   ',
      ),
      throwsArgumentError,
    );
  });
}
