import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/services/resonance_connection_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';

class FakeResonanceEngine implements ResonanceEngine {
  ResonanceConnection? createdConnection;
  ResonanceConnection? updatedConnection;
  final Map<String, ResonanceThread> threads = {};

  @override
  Future<ResonanceConnection> createConnection({required String sourceId, required String targetId, String? sourceVoiceId, String? targetVoiceId, required ResonanceConnectionType type, required double strength}) async {
    final connection = ResonanceConnection(id: '${sourceId}_$targetId', sourceId: sourceId, targetId: targetId, sourceVoiceId: sourceVoiceId, targetVoiceId: targetVoiceId, type: type, strength: strength, createdAt: DateTime(2026, 1, 1));
    createdConnection = connection;
    return connection;
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(String sourceId, String targetId) async => null;

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) async => const [];

  @override
  Future<void> updateConnection(ResonanceConnection connection) async { updatedConnection = connection; }

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) async {}

  @override
  Future<List<ResonanceCandidate>> discover(ResonanceQuery query) async => const [];

  @override
  Future<void> saveThread(ResonanceThread thread) async { threads[thread.id] = thread; }

  @override
  Future<ResonanceThread?> getThread(String threadId) async => threads[threadId];

  @override
  Future<List<ResonanceThread>> getThreadsForExperience(String experienceId) async => threads.values.where((thread) => thread.containsExperience(experienceId)).toList();

  @override
  Future<List<ResonanceThread>> getThreads() async => threads.values.toList();
}

ResonanceConnection _connection({ResonanceConnectionState state = ResonanceConnectionState.suggested}) {
  return ResonanceConnection(id: 'vent-1_vent-2', sourceId: 'vent-1', targetId: 'vent-2', sourceVoiceId: 'voice-1', targetVoiceId: 'voice-2', type: ResonanceConnectionType.sharedExperience, strength: 0.82, state: state, createdAt: DateTime(2026, 1, 1));
}

void main() {
  test('creates a shared-experience connection from a meaningful candidate', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    const candidate = ResonanceCandidate(id: 'vent-2', type: ResonanceCandidateType.vent, voiceId: 'voice-2', score: 0.82, signals: [ResonanceSignal(type: ResonanceSignalType.experiential, key: 'feeling_stuck', strength: 1), ResonanceSignal(type: ResonanceSignalType.semantic, key: 'university', strength: 0.8)]);
    final connection = await service.suggestConnection(sourceId: 'vent-1', sourceVoiceId: 'voice-1', candidate: candidate);
    expect(connection, isNotNull);
    expect(connection!.type, ResonanceConnectionType.sharedExperience);
    expect(connection.strength, 0.82);
    expect(connection.sourceVoiceId, 'voice-1');
    expect(connection.targetVoiceId, 'voice-2');
    expect(engine.createdConnection, connection);
  });

  test('does not connect a candidate to itself', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    const candidate = ResonanceCandidate(id: 'vent-1', type: ResonanceCandidateType.vent, score: 0.9, signals: []);
    final connection = await service.suggestConnection(sourceId: 'vent-1', candidate: candidate);
    expect(connection, isNull);
    expect(engine.createdConnection, isNull);
  });

  test('does not create a connection for a zero-score candidate', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    const candidate = ResonanceCandidate(id: 'vent-2', type: ResonanceCandidateType.vent, score: 0, signals: []);
    final connection = await service.suggestConnection(sourceId: 'vent-1', candidate: candidate);
    expect(connection, isNull);
  });

  test('accepts a suggested connection', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    final updated = await service.accept(_connection(), actorVoiceId: 'voice-1');
    expect(updated!.state, ResonanceConnectionState.accepted);
    expect(engine.updatedConnection, updated);
  });

  test('activates an accepted connection', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    final updated = await service.activate(_connection(state: ResonanceConnectionState.accepted), actorVoiceId: 'voice-1');
    expect(updated!.state, ResonanceConnectionState.active);
  });

  test('closes an active connection', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    final updated = await service.close(_connection(state: ResonanceConnectionState.active), actorVoiceId: 'voice-1');
    expect(updated!.state, ResonanceConnectionState.closed);
  });

  test('blocks an active connection', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    final updated = await service.block(_connection(state: ResonanceConnectionState.active), actorVoiceId: 'voice-1');
    expect(updated!.state, ResonanceConnectionState.blocked);
  });

  test('rejects invalid lifecycle transitions', () async {
    final engine = FakeResonanceEngine();
    final service = ResonanceConnectionService(engine: engine);
    final updated = await service.activate(_connection());
    expect(updated, isNull);
    expect(engine.updatedConnection, isNull);
  });
}
