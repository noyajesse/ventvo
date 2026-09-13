import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/repositories/resonance_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_discovery_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_reconciliation_service.dart';

class FakeResonanceRepository implements ResonanceRepository {
  final Map<String, ResonanceThread> threads = {};
  final List<ResonanceConnection> connections = [];

  @override
  Future<void> saveCandidate(ResonanceCandidate candidate) async {}

  @override
  Future<List<ResonanceCandidate>> findCandidates(ResonanceQuery query) async =>
      const [];

  @override
  Future<void> saveConnection(ResonanceConnection connection) async {
    final index = connections.indexWhere((item) => item.id == connection.id);
    if (index >= 0) {
      connections[index] = connection;
    } else {
      connections.add(connection);
    }
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) async {
    await saveConnection(connection);
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) async {
    for (final connection in connections) {
      if ((connection.sourceId == sourceId && connection.targetId == targetId) ||
          (connection.sourceId == targetId && connection.targetId == sourceId)) {
        return connection;
      }
    }
    return null;
  }

  @override
  Future<List<ResonanceConnection>> getConnectionsFor(String sourceId) async {
    return connections
        .where((connection) => connection.sourceId == sourceId)
        .toList();
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
  Future<void> saveThread(ResonanceThread thread) async {
    threads[thread.id] = thread;
  }

  @override
  Future<ResonanceThread?> getThread(String threadId) async => threads[threadId];

  @override
  Future<List<ResonanceThread>> getThreadsForExperience(
    String experienceId,
  ) async {
    return threads.values
        .where((thread) => thread.containsExperience(experienceId))
        .toList();
  }

  @override
  Future<List<ResonanceThread>> getThreads() async => threads.values.toList();
}

ResonanceConnection _connection({
  required String id,
  required String sourceId,
  required String targetId,
  ResonanceConnectionState state = ResonanceConnectionState.active,
}) {
  return ResonanceConnection(
    id: id,
    sourceId: sourceId,
    targetId: targetId,
    type: ResonanceConnectionType.sharedExperience,
    strength: 0.8,
    state: state,
    createdAt: DateTime(2026, 1, 1),
  );
}

ResonanceThread _thread({
  required String id,
  required String sourceId,
  required String targetId,
  required ResonanceConnection connection,
}) {
  return ResonanceThread.create(
    id: id,
    originatingExperienceId: sourceId,
    experienceIds: [sourceId, targetId],
    connections: [connection],
    createdAt: DateTime(2026, 1, 1),
  );
}

ResonanceThreadDiscoveryService _service(FakeResonanceRepository repository) {
  final engine = LocalResonanceEngine(repository: repository);
  return ResonanceThreadDiscoveryService(
    engine: engine,
    reconciliationService: ResonanceThreadReconciliationService(
      engine: engine,
    ),
  );
}

void main() {
  test('discovers only active Threads for an experience', () async {
    final repository = FakeResonanceRepository();
    final activeConnection = _connection(
      id: 'vent-1_vent-2',
      sourceId: 'vent-1',
      targetId: 'vent-2',
    );
    final closedConnection = _connection(
      id: 'vent-1_vent-3',
      sourceId: 'vent-1',
      targetId: 'vent-3',
      state: ResonanceConnectionState.closed,
    );

    repository.threads['thread-active'] = _thread(
      id: 'thread-active',
      sourceId: 'vent-1',
      targetId: 'vent-2',
      connection: activeConnection,
    );
    repository.threads['thread-closed'] = _thread(
      id: 'thread-closed',
      sourceId: 'vent-1',
      targetId: 'vent-3',
      connection: closedConnection,
    );
    repository.connections.addAll([activeConnection, closedConnection]);

    final result = await _service(repository).discoverForExperience('vent-1');

    expect(result.map((thread) => thread.id), ['thread-active']);
  });

  test('reconciles stale Thread state before discovery', () async {
    final repository = FakeResonanceRepository();
    final staleConnection = _connection(
      id: 'vent-1_vent-2',
      sourceId: 'vent-1',
      targetId: 'vent-2',
      state: ResonanceConnectionState.active,
    );
    final latestConnection = staleConnection.copyWith(
      state: ResonanceConnectionState.closed,
    );

    repository.threads['thread-1'] = _thread(
      id: 'thread-1',
      sourceId: 'vent-1',
      targetId: 'vent-2',
      connection: staleConnection,
    );
    repository.connections.add(latestConnection);

    final result = await _service(repository).discoverForExperience('vent-1');

    expect(result, isEmpty);
    expect(
      repository.threads['thread-1']!.connections.single.state,
      ResonanceConnectionState.closed,
    );
  });

  test('discoverAll returns only currently discoverable Threads', () async {
    final repository = FakeResonanceRepository();
    final active = _connection(
      id: 'vent-1_vent-2',
      sourceId: 'vent-1',
      targetId: 'vent-2',
    );
    final blocked = _connection(
      id: 'vent-3_vent-4',
      sourceId: 'vent-3',
      targetId: 'vent-4',
      state: ResonanceConnectionState.blocked,
    );

    repository.threads['thread-active'] = _thread(
      id: 'thread-active',
      sourceId: 'vent-1',
      targetId: 'vent-2',
      connection: active,
    );
    repository.threads['thread-blocked'] = _thread(
      id: 'thread-blocked',
      sourceId: 'vent-3',
      targetId: 'vent-4',
      connection: blocked,
    );
    repository.connections.addAll([active, blocked]);

    final result = await _service(repository).discoverAll();

    expect(result.map((thread) => thread.id), ['thread-active']);
  });

  test('respects the discovery limit', () async {
    final repository = FakeResonanceRepository();
    for (var index = 1; index <= 3; index++) {
      final sourceId = 'vent-$index';
      final targetId = 'vent-target-$index';
      final connection = _connection(
        id: '${sourceId}_$targetId',
        sourceId: sourceId,
        targetId: targetId,
      );
      repository.threads['thread-$index'] = _thread(
        id: 'thread-$index',
        sourceId: sourceId,
        targetId: targetId,
        connection: connection,
      );
      repository.connections.add(connection);
    }

    final result = await _service(repository).discoverAll(limit: 2);

    expect(result, hasLength(2));
  });

  test('rejects blank experience ids and invalid limits', () async {
    final service = _service(FakeResonanceRepository());

    expect(
      () => service.discoverForExperience('   '),
      throwsArgumentError,
    );
    expect(
      () => service.discoverAll(limit: 0),
      throwsArgumentError,
    );
  });
}
