import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/repositories/resonance_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';

class FakeResonanceRepository implements ResonanceRepository {
  final List<ResonanceCandidate> candidates;
  final List<ResonanceConnection> connections = [];

  FakeResonanceRepository(this.candidates);

  @override
  Future<void> saveCandidate(ResonanceCandidate candidate) async {
    final index = candidates.indexWhere((item) => item.id == candidate.id);
    if (index == -1) {
      candidates.add(candidate);
    } else {
      candidates[index] = candidate;
    }
  }

  @override
  Future<List<ResonanceCandidate>> findCandidates(ResonanceQuery query) async {
    return candidates;
  }

  @override
  Future<void> saveConnection(ResonanceConnection connection) async {
    connections.add(connection);
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) async {
    final index = connections.indexWhere((item) => item.id == connection.id);
    if (index == -1) return;
    connections[index] = connection;
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) async {
    for (final connection in connections) {
      if (connection.sourceId == sourceId &&
          connection.targetId == targetId) {
        return connection;
      }
    }
    return null;
  }

  @override
  Future<List<ResonanceConnection>> getConnectionsFor(String sourceId) async {
    return connections.where((item) => item.sourceId == sourceId).toList();
  }

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) async {
    return connections
        .where(
          (item) => item.sourceId == id || item.targetId == id,
        )
        .toList();
  }
}

void main() {
  test('ranks candidates by deterministic resonance score', () async {
    final repository = FakeResonanceRepository([
      const ResonanceCandidate(
        id: 'less',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.semantic,
            key: 'study',
            strength: 0.4,
          ),
        ],
      ),
      const ResonanceCandidate(
        id: 'more',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.experiential,
            key: 'study',
            strength: 1,
          ),
        ],
      ),
    ]);
    final ResonanceEngine engine = LocalResonanceEngine(repository: repository);

    final results = await engine.discover(
      const ResonanceQuery(
        sourceId: 'source',
        sourceType: ResonanceCandidateType.vent,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.experiential,
            key: 'study',
            strength: 1,
          ),
        ],
        limit: 1,
      ),
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'more');
    expect(results.single.score, 1);
  });

  test('excludes source and explicitly excluded candidates', () async {
    final repository = FakeResonanceRepository([
      const ResonanceCandidate(
        id: 'source',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.semantic,
            key: 'same',
            strength: 1,
          ),
        ],
      ),
      const ResonanceCandidate(
        id: 'excluded',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.semantic,
            key: 'same',
            strength: 1,
          ),
        ],
      ),
      const ResonanceCandidate(
        id: 'valid',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.semantic,
            key: 'same',
            strength: 1,
          ),
        ],
      ),
    ]);
    final engine = LocalResonanceEngine(repository: repository);

    final results = await engine.discover(
      const ResonanceQuery(
        sourceId: 'source',
        sourceType: ResonanceCandidateType.vent,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.semantic,
            key: 'same',
            strength: 1,
          ),
        ],
        excludedIds: {'excluded'},
      ),
    );

    expect(results.map((item) => item.id), ['valid']);
  });

  test('persists a created connection through the repository', () async {
    final repository = FakeResonanceRepository([]);
    final engine = LocalResonanceEngine(repository: repository);

    final connection = await engine.createConnection(
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.sharedExperience,
      strength: 0.8,
    );

    expect(repository.connections, hasLength(1));
    expect(repository.connections.single.id, connection.id);
    expect(connection.strength, 0.8);
  });

  test('returns the existing connection instead of creating a duplicate',
      () async {
    final repository = FakeResonanceRepository([]);
    final engine = LocalResonanceEngine(repository: repository);

    final first = await engine.createConnection(
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.similarity,
      strength: 0.6,
    );
    final second = await engine.createConnection(
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.sharedExperience,
      strength: 0.9,
    );

    expect(repository.connections, hasLength(1));
    expect(second.id, first.id);
    expect(second.type, first.type);
    expect(second.strength, first.strength);
  });

  test('preserves an accepted connection when discovery repeats', () async {
    final repository = FakeResonanceRepository([]);
    final engine = LocalResonanceEngine(repository: repository);

    final first = await engine.createConnection(
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.sharedExperience,
      strength: 0.8,
    );
    final accepted = first.copyWith(state: ResonanceConnectionState.accepted);
    await engine.updateConnection(accepted);

    final rediscovered = await engine.createConnection(
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.similarity,
      strength: 0.4,
    );

    expect(rediscovered.state, ResonanceConnectionState.accepted);
    expect(rediscovered.type, ResonanceConnectionType.sharedExperience);
    expect(rediscovered.strength, 0.8);
  });

  test('can look up a connection by its exact direction', () async {
    final repository = FakeResonanceRepository([]);
    final engine = LocalResonanceEngine(repository: repository);

    await engine.createConnection(
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.discovery,
      strength: 0.7,
    );

    expect(
      await engine.getConnectionBetween('vent-1', 'vent-2'),
      isNotNull,
    );
    expect(
      await engine.getConnectionBetween('vent-2', 'vent-1'),
      isNull,
    );
  });

  test('finds connections where an experience is either source or target',
      () async {
    final repository = FakeResonanceRepository([]);
    final engine = LocalResonanceEngine(repository: repository);

    await engine.createConnection(
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.discovery,
      strength: 0.7,
    );
    await engine.createConnection(
      sourceId: 'vent-3',
      targetId: 'vent-1',
      type: ResonanceConnectionType.response,
      strength: 0.8,
    );
    await engine.createConnection(
      sourceId: 'vent-4',
      targetId: 'vent-5',
      type: ResonanceConnectionType.similarity,
      strength: 0.9,
    );

    final connections = await engine.getConnectionsInvolving('vent-1');

    expect(connections, hasLength(2));
    expect(
      connections.map((connection) => connection.id),
      containsAll(<String>['vent-1_vent-2', 'vent-3_vent-1']),
    );
  });
}
