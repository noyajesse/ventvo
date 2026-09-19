import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo_resonance_link.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/spaces/models/space_response.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_connection_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_storage.dart';
import 'package:ventvo/features/spaces/services/echo_response_resonance_service.dart';
import 'package:ventvo/features/spaces/services/echo_service.dart';
import 'package:ventvo/features/spaces/services/space_response_storage.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_lifecycle.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_evolution_policy.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_evolution_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_event_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_integrity_policy.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_reconciliation_service.dart';

class _FakeResponseStorage extends SpaceResponseStorage {
  final List<SpaceResponse> responses = [];

  @override
  Future<List<SpaceResponse>> loadForSpace(String spaceId) async {
    return responses.where((response) => response.spaceId == spaceId).toList();
  }

  @override
  Future<void> add(SpaceResponse response) async => responses.add(response);
}

class _FakeLinkStorage extends EchoResonanceLinkStorage {
  final List<EchoResonanceLink> links = [];

  @override
  Future<EchoResonanceLink?> loadForEcho(String echoId) async {
    for (final link in links) {
      if (link.echoId == echoId) return link;
    }
    return null;
  }

  @override
  Future<void> save(EchoResonanceLink value) async => links.add(value);
}

class _FakeResonanceEngine implements ResonanceEngine, ResonanceMapEngine {
  final List<ResonanceConnection> connections = [];
  final List<ResonanceMap> maps = [];

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    String? sourceVoiceId,
    String? targetVoiceId,
    required ResonanceConnectionType type,
    required double strength,
  }) async {
    final existing = await getConnectionBetween(sourceId, targetId);
    if (existing != null) return existing;

    final connection = ResonanceConnection(
      id: '${sourceId}_$targetId',
      sourceId: sourceId,
      targetId: targetId,
      sourceVoiceId: sourceVoiceId,
      targetVoiceId: targetVoiceId,
      type: type,
      strength: strength,
      createdAt: DateTime(2026, 1, 1),
    );
    connections.add(connection);
    return connection;
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) async {
    for (final connection in connections) {
      if (connection.sourceId == sourceId && connection.targetId == targetId) {
        return connection;
      }
    }
    return null;
  }

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) async {
    return connections
        .where(
          (connection) =>
              connection.sourceId == id || connection.targetId == id,
        )
        .toList();
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) async {
    final index = connections.indexWhere((item) => item.id == connection.id);
    if (index >= 0) {
      connections[index] = connection;
    } else {
      connections.add(connection);
    }
  }

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) async {}

  @override
  Future<List<ResonanceCandidate>> discover(ResonanceQuery query) async => const [];

  @override
  Future<void> saveThread(ResonanceThread thread) async {}

  @override
  Future<ResonanceThread?> getThread(String threadId) async => null;

  @override
  Future<List<ResonanceThread>> getThreadsForExperience(
    String experienceId,
  ) async => const [];

  @override
  Future<List<ResonanceThread>> getThreads() async => const [];

  @override
  Future<void> saveMap(ResonanceMap map) async {
    final index = maps.indexWhere((item) => item.id == map.id);
    if (index >= 0) {
      maps[index] = map;
    } else {
      maps.add(map);
    }
  }

  @override
  Future<ResonanceMap?> getMap(String mapId) async {
    for (final map in maps) {
      if (map.id == mapId) return map;
    }
    return null;
  }

  @override
  Future<List<ResonanceMap>> getMapsForExperience(String experienceId) async {
    return maps
        .where((map) => map.containsExperience(experienceId))
        .toList();
  }

  @override
  Future<List<ResonanceMap>> getMaps() async => List.unmodifiable(maps);
}

ResonanceConnection _liveConnection({
  required String id,
  required String sourceId,
  required String targetId,
}) {
  return ResonanceConnection(
    id: id,
    sourceId: sourceId,
    targetId: targetId,
    type: ResonanceConnectionType.sharedExperience,
    strength: 0.9,
    state: ResonanceConnectionState.active,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('an Echo response evolves a Map that already contains its Vent', () async {
    final engine = _FakeResonanceEngine();

    final firstConnection = _liveConnection(
      id: 'vent-1_vent-2',
      sourceId: 'vent-1',
      targetId: 'vent-2',
    );
    final secondConnection = _liveConnection(
      id: 'vent-2_vent-3',
      sourceId: 'vent-2',
      targetId: 'vent-3',
    );
    engine.connections.addAll([firstConnection, secondConnection]);

    final map = ResonanceMap.create(
      id: 'map-1',
      experienceIds: const ['vent-1', 'vent-2', 'vent-3'],
      connections: [firstConnection, secondConnection],
      createdAt: DateTime(2026, 1, 1),
    );
    await engine.saveMap(map);

    final reconciliationService = ResonanceMapReconciliationService(
      engine: engine,
      integrityPolicy: const ResonanceMapIntegrityPolicy(),
    );
    final evolutionService = ResonanceMapEvolutionService(
      engine: engine,
      reconciliationService: reconciliationService,
      evolutionPolicy: const ResonanceMapEvolutionPolicy(),
      integrityPolicy: const ResonanceMapIntegrityPolicy(),
    );
    final mapEventService = ResonanceMapEventService(
      mapEngine: engine,
      evolutionService: evolutionService,
    );
    final connectionService = ResonanceConnectionService(
      engine: engine,
      lifecycle: const ResonanceConnectionLifecycle(),
      mapEventService: mapEventService,
    );

    final linkStorage = _FakeLinkStorage();
    final echoConnectionService = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: linkStorage),
    );
    final echoResponseService = EchoResponseResonanceService(
      engine: engine,
      connectionService: connectionService,
      echoConnectionService: echoConnectionService,
    );
    final echoService = EchoService(
      storage: _FakeResponseStorage(),
      responseResonanceService: echoResponseService,
    );

    final space = Space(
      id: 'space-1',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'vent-1',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final echo = await echoService.leaveEcho(
      space: space,
      content: 'I felt this too.',
      voiceMark: '△',
      authorVoiceId: 'voice-2',
      sourceVoiceId: 'voice-1',
    );

    expect(echo, isNotNull);
    final createdEcho = echo!;

    final responseConnection = engine.connections.singleWhere(
      (connection) => connection.targetId == 'echo:${createdEcho.id}',
    );
    expect(responseConnection.sourceId, 'vent-1');
    expect(responseConnection.type, ResonanceConnectionType.response);
    expect(responseConnection.state, ResonanceConnectionState.active);

    final updatedMap = await engine.getMap('map-1');
    expect(updatedMap, isNotNull);
    expect(updatedMap!.experienceIds, contains('echo:${createdEcho.id}'));
    expect(
      updatedMap.connections.any(
        (connection) => connection.id == responseConnection.id,
      ),
      isTrue,
    );
    expect(updatedMap.experienceIds, hasLength(4));
  });
}
