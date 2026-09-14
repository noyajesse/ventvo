import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo.dart';
import 'package:ventvo/features/spaces/models/echo_resonance_link.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_connection_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_storage.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
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

class FakeResonanceEngine implements ResonanceEngine {
  List<ResonanceConnection> connections = const [];

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
  Future<void> indexCandidate(ResonanceCandidate candidate) async {}

  @override
  Future<List<ResonanceCandidate>> discover(ResonanceQuery query) async => const [];

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    required ResonanceConnectionType type,
    required double strength,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) async => null;

  @override
  Future<void> updateConnection(ResonanceConnection connection) async {}

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
  Echo echo() {
    return Echo(
      id: 'echo-1',
      spaceId: 'space-1',
      ventId: 'vent-1',
      voiceMark: '◇',
      content: 'I felt this too.',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  ResonanceConnection connection({
    required ResonanceConnectionType type,
    required ResonanceConnectionState state,
    String targetId = 'echo:echo-1',
  }) {
    return ResonanceConnection(
      id: 'vent-1_$targetId',
      sourceId: 'vent-1',
      targetId: targetId,
      type: type,
      strength: 0.8,
      state: state,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('resolves an accepted response connection and records the Echo link', () async {
    final engine = FakeResonanceEngine();
    engine.connections = [
      connection(
        type: ResonanceConnectionType.response,
        state: ResonanceConnectionState.accepted,
      ),
    ];
    final storage = FakeLinkStorage();
    final service = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: storage),
    );

    final result = await service.resolveForEcho(echo());

    expect(result?.id, 'vent-1_echo:echo-1');
    expect(storage.link?.echoId, 'echo-1');
    expect(storage.link?.connectionId, result?.id);
  });

  test('prefers a live response connection over other eligible connections', () async {
    final engine = FakeResonanceEngine();
    engine.connections = [
      connection(
        type: ResonanceConnectionType.similarity,
        state: ResonanceConnectionState.active,
      ),
      connection(
        type: ResonanceConnectionType.response,
        state: ResonanceConnectionState.active,
      ),
    ];
    final storage = FakeLinkStorage();
    final service = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: storage),
    );

    final result = await service.resolveForEcho(echo());

    expect(result?.type, ResonanceConnectionType.response);
  });

  test('does not create a link when no accepted or active connection exists', () async {
    final engine = FakeResonanceEngine();
    engine.connections = [
      connection(
        type: ResonanceConnectionType.response,
        state: ResonanceConnectionState.suggested,
      ),
    ];
    final storage = FakeLinkStorage();
    final service = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: storage),
    );

    expect(await service.resolveForEcho(echo()), isNull);
    expect(storage.link, isNull);
  });

  test('does not create a link for a connection pointing at another experience', () async {
    final engine = FakeResonanceEngine();
    engine.connections = [
      connection(
        type: ResonanceConnectionType.response,
        state: ResonanceConnectionState.active,
        targetId: 'echo:other',
      ),
    ];
    final storage = FakeLinkStorage();
    final service = EchoResonanceConnectionService(
      engine: engine,
      linkService: EchoResonanceLinkService(storage: storage),
    );

    expect(await service.resolveForEcho(echo()), isNull);
    expect(storage.link, isNull);
  });
}
