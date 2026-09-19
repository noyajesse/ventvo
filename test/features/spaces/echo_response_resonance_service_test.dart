import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo.dart';
import 'package:ventvo/features/spaces/models/echo_resonance_link.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_connection_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_storage.dart';
import 'package:ventvo/features/spaces/services/echo_response_resonance_service.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_lifecycle.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';

class FakeLinkStorage extends EchoResonanceLinkStorage {
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

class FakeEngine implements ResonanceEngine {
  final List<ResonanceConnection> connections = [];

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
  Space openDiscussion() {
    return Space(
      id: 'space-1',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'vent-1',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
      ventIds: const [],
    );
  }

  Space justListen() {
    return Space(
      id: 'space-2',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-2',
      creatorVoiceMark: '○',
      createdAt: DateTime(2026, 1, 1),
      ventIds: const [],
    );
  }

  Echo echo(String spaceId) {
    return Echo(
      id: 'echo-1',
      spaceId: spaceId,
      ventId: 'vent-1',
      voiceMark: '△',
      authorVoiceId: 'voice-2',
      content: 'I felt this too.',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('creates and activates a response connection for an Echo', () async {
    final engine = FakeEngine();
    final storage = FakeLinkStorage();
    final linkService = EchoResonanceLinkService(storage: storage);
    final echoConnectionService = EchoResonanceConnectionService(
      engine: engine,
      linkService: linkService,
    );
    final connectionService = ResonanceConnectionService(
      engine: engine,
      lifecycle: const ResonanceConnectionLifecycle(),
    );
    final service = EchoResponseResonanceService(
      engine: engine,
      connectionService: connectionService,
      echoConnectionService: echoConnectionService,
    );

    final result = await service.connectEcho(
      space: openDiscussion(),
      echo: echo('space-1'),
      sourceExperienceId: 'vent:vent-1',
      sourceVoiceId: 'voice-1',
      actorVoiceId: 'voice-2',
    );

    expect(result, isNotNull);
    expect(result!.type, ResonanceConnectionType.response);
    expect(result.state, ResonanceConnectionState.active);
    expect(result.sourceId, 'vent:vent-1');
    expect(result.targetId, 'echo:echo-1');
    expect(storage.link?.echoId, 'echo-1');
    expect(storage.link?.connectionId, result.id);
  });

  test('does not create a connection in Just Listen', () async {
    final engine = FakeEngine();
    final storage = FakeLinkStorage();
    final echoConnectionService = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: storage),
    );
    final service = EchoResponseResonanceService(
      engine: engine,
      connectionService: ResonanceConnectionService(engine: engine),
      echoConnectionService: echoConnectionService,
    );

    final result = await service.connectEcho(
      space: justListen(),
      echo: echo('space-2'),
      sourceExperienceId: 'vent:vent-2',
    );

    expect(result, isNull);
    expect(engine.connections, isEmpty);
    expect(storage.link, isNull);
  });

  test('rejects an Echo belonging to another Space', () async {
    final engine = FakeEngine();
    final storage = FakeLinkStorage();
    final echoConnectionService = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: storage),
    );
    final service = EchoResponseResonanceService(
      engine: engine,
      connectionService: ResonanceConnectionService(engine: engine),
      echoConnectionService: echoConnectionService,
    );

    final result = await service.connectEcho(
      space: openDiscussion(),
      echo: echo('other-space'),
      sourceExperienceId: 'vent:vent-1',
    );

    expect(result, isNull);
    expect(engine.connections, isEmpty);
  });

  test('rejects a blank source experience', () async {
    final engine = FakeEngine();
    final storage = FakeLinkStorage();
    final echoConnectionService = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: storage),
    );
    final service = EchoResponseResonanceService(
      engine: engine,
      connectionService: ResonanceConnectionService(engine: engine),
      echoConnectionService: echoConnectionService,
    );

    final result = await service.connectEcho(
      space: openDiscussion(),
      echo: echo('space-1'),
      sourceExperienceId: '  ',
    );

    expect(result, isNull);
    expect(engine.connections, isEmpty);
  });
}
