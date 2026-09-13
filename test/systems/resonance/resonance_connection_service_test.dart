import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';

class FakeResonanceEngine implements ResonanceEngine {
  ResonanceConnection? createdConnection;

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    required ResonanceConnectionType type,
    required double strength,
  }) async {
    final connection = ResonanceConnection(
      id: '${sourceId}_$targetId',
      sourceId: sourceId,
      targetId: targetId,
      type: type,
      strength: strength,
      createdAt: DateTime(2026, 1, 1),
    );
    createdConnection = connection;
    return connection;
  }

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) async {}

  @override
  Future<List<ResonanceCandidate>> discover(ResonanceQuery query) async =>
      const [];
}

void main() {
  test('creates a shared-experience connection from a meaningful candidate',
      () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    const candidate = ResonanceCandidate(
      id: 'vent-2',
      type: ResonanceCandidateType.vent,
      score: 0.82,
      signals: [
        ResonanceSignal(
          type: ResonanceSignalType.experiential,
          key: 'feeling_stuck',
          strength: 1,
        ),
        ResonanceSignal(
          type: ResonanceSignalType.semantic,
          key: 'university',
          strength: 0.8,
        ),
      ],
    );

    final connection = await service.suggestConnection(
      sourceId: 'vent-1',
      candidate: candidate,
    );

    expect(connection, isNotNull);
    expect(connection!.type, ResonanceConnectionType.sharedExperience);
    expect(connection.strength, 0.82);
    expect(engine.createdConnection, connection);
  });

  test('does not connect a candidate to itself', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    const candidate = ResonanceCandidate(
      id: 'vent-1',
      type: ResonanceCandidateType.vent,
      score: 0.9,
      signals: [],
    );

    final connection = await service.suggestConnection(
      sourceId: 'vent-1',
      candidate: candidate,
    );

    expect(connection, isNull);
    expect(engine.createdConnection, isNull);
  });

  test('does not create a connection for a zero-score candidate', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    const candidate = ResonanceCandidate(
      id: 'vent-2',
      type: ResonanceCandidateType.vent,
      score: 0,
      signals: [],
    );

    final connection = await service.suggestConnection(
      sourceId: 'vent-1',
      candidate: candidate,
    );

    expect(connection, isNull);
  });
}
