import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/repositories/resonance_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_formation_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_service.dart';

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
    connections.add(connection);
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) async {
    final index = connections.indexWhere((item) => item.id == connection.id);
    if (index >= 0) {
      connections[index] = connection;
    }
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

ResonanceThreadFormationService _service(FakeResonanceRepository repository) {
  final engine = LocalResonanceEngine(repository: repository);
  return ResonanceThreadFormationService(
    engine: engine,
    threadService: ResonanceThreadService(engine: engine),
  );
}

ResonanceConnection _connection({
  required String id,
  required String sourceId,
  required String targetId,
  ResonanceConnectionType type = ResonanceConnectionType.sharedExperience,
  double strength = 0.8,
  ResonanceConnectionState state = ResonanceConnectionState.active,
}) {
  return ResonanceConnection(
    id: id,
    sourceId: sourceId,
    targetId: targetId,
    type: type,
    strength: strength,
    state: state,
    createdAt: DateTime(2026, 1, 1),
  );
}

ResonanceThread _thread({
  required String id,
  required String originatingExperienceId,
  required List<String> experienceIds,
  DateTime? createdAt,
}) {
  return ResonanceThread.create(
    id: id,
    originatingExperienceId: originatingExperienceId,
    experienceIds: experienceIds,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  test('finds a Thread when an active connection reaches a Thread member', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    repository.threads['thread-1'] = _thread(
      id: 'thread-1',
      originatingExperienceId: 'vent-1',
      experienceIds: ['vent-1'],
    );
    repository.connections.add(
      _connection(
        id: 'vent-1_vent-2',
        sourceId: 'vent-1',
        targetId: 'vent-2',
      ),
    );

    final result = await service.findBestThreadForExperience('vent-2');

    expect(result?.id, 'thread-1');
  });

  test('does not form a Thread from a suggested connection', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    repository.threads['thread-1'] = _thread(
      id: 'thread-1',
      originatingExperienceId: 'vent-1',
      experienceIds: ['vent-1'],
    );
    repository.connections.add(
      _connection(
        id: 'vent-1_vent-2',
        sourceId: 'vent-1',
        targetId: 'vent-2',
        state: ResonanceConnectionState.suggested,
      ),
    );

    final result = await service.findBestThreadForExperience('vent-2');

    expect(result, isNull);
  });

  test('does not form a Thread from a blocked or closed connection', () async {
    for (final state in [
      ResonanceConnectionState.blocked,
      ResonanceConnectionState.closed,
    ]) {
      final repository = FakeResonanceRepository();
      final service = _service(repository);
      repository.threads['thread-1'] = _thread(
        id: 'thread-1',
        originatingExperienceId: 'vent-1',
        experienceIds: ['vent-1'],
      );
      repository.connections.add(
        _connection(
          id: 'vent-1_vent-2',
          sourceId: 'vent-1',
          targetId: 'vent-2',
          state: state,
        ),
      );

      final result = await service.findBestThreadForExperience('vent-2');

      expect(result, isNull);
    }
  });

  test('selects the strongest eligible Thread connection', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    repository.threads['thread-weak'] = _thread(
      id: 'thread-weak',
      originatingExperienceId: 'vent-1',
      experienceIds: ['vent-1'],
    );
    repository.threads['thread-strong'] = _thread(
      id: 'thread-strong',
      originatingExperienceId: 'vent-3',
      experienceIds: ['vent-3'],
    );
    repository.connections.addAll([
      _connection(
        id: 'vent-1_vent-new',
        sourceId: 'vent-1',
        targetId: 'vent-new',
        type: ResonanceConnectionType.similarity,
        strength: 0.95,
      ),
      _connection(
        id: 'vent-3_vent-new',
        sourceId: 'vent-3',
        targetId: 'vent-new',
        type: ResonanceConnectionType.sharedExperience,
        strength: 0.8,
      ),
    ]);

    final result = await service.findBestThreadForExperience('vent-new');

    expect(result?.id, 'thread-strong');
  });

  test('returns null when the connection does not reach any Thread member', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    repository.threads['thread-1'] = _thread(
      id: 'thread-1',
      originatingExperienceId: 'vent-1',
      experienceIds: ['vent-1'],
    );
    repository.connections.add(
      _connection(
        id: 'vent-other_vent-new',
        sourceId: 'vent-other',
        targetId: 'vent-new',
      ),
    );

    final result = await service.findBestThreadForExperience('vent-new');

    expect(result, isNull);
  });

  test('extends the best Thread with the new experience', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    repository.threads['thread-1'] = _thread(
      id: 'thread-1',
      originatingExperienceId: 'vent-1',
      experienceIds: ['vent-1'],
    );
    repository.connections.add(
      _connection(
        id: 'vent-1_vent-new',
        sourceId: 'vent-1',
        targetId: 'vent-new',
      ),
    );

    final result = await service.extendBestThreadForExperience(
      experienceId: 'vent-new',
      voiceMark: 'Sol',
    );

    expect(result, isNotNull);
    expect(result!.experienceIds, ['vent-1', 'vent-new']);
    expect(result.voiceMarks, ['Sol']);
    expect(result.connections.map((connection) => connection.id), [
      'vent-1_vent-new',
    ]);
  });

  test('does not create a duplicate extension when experience is already in a Thread', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    repository.threads['thread-1'] = _thread(
      id: 'thread-1',
      originatingExperienceId: 'vent-1',
      experienceIds: ['vent-1', 'vent-new'],
    );
    repository.connections.add(
      _connection(
        id: 'vent-1_vent-new',
        sourceId: 'vent-1',
        targetId: 'vent-new',
      ),
    );

    final result = await service.extendBestThreadForExperience(
      experienceId: 'vent-new',
    );

    expect(result, isNull);
  });
}
