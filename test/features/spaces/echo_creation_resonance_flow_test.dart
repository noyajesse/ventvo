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
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_lifecycle.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';

class _FakeResponseStorage extends SpaceResponseStorage {
  final List<SpaceResponse> responses = [];

  @override
  Future<List<SpaceResponse>> loadForSpace(String spaceId) async {
    return responses.where((response) => response.spaceId == spaceId).toList();
  }

  @override
  Future<void> add(SpaceResponse response) async {
    responses.add(response);
  }
}

class _FakeLinkStorage extends EchoResonanceLinkStorage {
  EchoResonanceLink? link;

  @override
  Future<EchoResonanceLink?> loadForEcho(String echoId) async {
    return link?.echoId == echoId ? link : null;
  }

  @override
  Future<void> save(EchoResonanceLink value) async {
    link = value;
  }
}

class _FakeEngine implements ResonanceEngine {
  final List<ResonanceConnection> connections = [];

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    required ResonanceConnectionType type,
    required double strength,
  }) async {
    final existing = await getConnectionBetween(sourceId, targetId);
    if (existing != null) return existing;

    final connection = ResonanceConnection(
      id: '${sourceId}_$targetId',
      sourceId: sourceId,
      targetId: targetId,
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
    if (index >= 0) connections[index] = connection;
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
}

void main() {
  final space = Space(
    id: 'space-1',
    mode: SpaceMode.openDiscussion,
    originatingVentId: 'vent-1',
    creatorVoiceMark: '◇',
    createdAt: DateTime(2026, 1, 1),
  );

  test('creates an Echo and connects it to Resonance', () async {
    final responseStorage = _FakeResponseStorage();
    final linkStorage = _FakeLinkStorage();
    final engine = _FakeEngine();
    final connectionService = ResonanceConnectionService(
      engine: engine,
      lifecycle: const ResonanceConnectionLifecycle(),
    );
    final echoConnectionService = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: linkStorage),
    );
    final resonanceService = EchoResponseResonanceService(
      engine: engine,
      connectionService: connectionService,
      echoConnectionService: echoConnectionService,
    );
    final echoService = EchoService(
      storage: responseStorage,
      responseResonanceService: resonanceService,
    );

    final echo = await echoService.leaveEcho(
      space: space,
      content: 'I felt this too.',
      voiceMark: '△',
    );

    expect(echo, isNotNull);
    expect(responseStorage.responses, hasLength(1));
    expect(engine.connections, hasLength(1));

    final connection = engine.connections.single;
    expect(connection.type, ResonanceConnectionType.response);
    expect(connection.state, ResonanceConnectionState.active);
    expect(connection.sourceId, 'vent:vent-1');
    expect(connection.targetId, 'echo:${echo!.id}');
    expect(linkStorage.link?.echoId, echo.id);
    expect(linkStorage.link?.connectionId, connection.id);
  });
}
