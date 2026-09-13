import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/repositories/resonance_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_service.dart';

class FakeResonanceRepository implements ResonanceRepository {
  final Map<String, ResonanceThread> threads = {};
  @override Future<void> saveCandidate(ResonanceCandidate candidate) async {}
  @override Future<List<ResonanceCandidate>> findCandidates(ResonanceQuery query) async => const [];
  @override Future<void> saveConnection(ResonanceConnection connection) async {}
  @override Future<void> updateConnection(ResonanceConnection connection) async {}
  @override Future<ResonanceConnection?> getConnectionBetween(String sourceId, String targetId) async => null;
  @override Future<List<ResonanceConnection>> getConnectionsFor(String sourceId) async => const [];
  @override Future<List<ResonanceConnection>> getConnectionsInvolving(String id) async => const [];
  @override Future<void> saveThread(ResonanceThread thread) async { threads[thread.id] = thread; }
  @override Future<ResonanceThread?> getThread(String threadId) async => threads[threadId];
  @override Future<List<ResonanceThread>> getThreadsForExperience(String experienceId) async => threads.values.where((thread) => thread.containsExperience(experienceId)).toList();
  @override Future<List<ResonanceThread>> getThreads() async => threads.values.toList();
}

ResonanceThreadService _service(FakeResonanceRepository repository) => ResonanceThreadService(engine: LocalResonanceEngine(repository: repository));

ResonanceConnection _connection({
  String id = 'vent-1_vent-2',
  String sourceId = 'vent-1',
  String targetId = 'vent-2',
  double strength = 0.8,
  ResonanceConnectionState state = ResonanceConnectionState.active,
}) => ResonanceConnection(
      id: id,
      sourceId: sourceId,
      targetId: targetId,
      type: ResonanceConnectionType.sharedExperience,
      strength: strength,
      state: state,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  test('creates a Thread from its originating experience', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final thread = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', originatingVoiceMark: 'Nera', createdAt: DateTime(2026, 1, 1));
    expect(thread.experienceIds, ['vent-1']);
    expect(thread.voiceMarks, ['Nera']);
    expect(await service.getThread('thread-1'), thread);
  });

  test('returns an existing Thread instead of overwriting it', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final first = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', createdAt: DateTime(2026, 1, 1));
    final second = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-2', createdAt: DateTime(2026, 2, 1));
    expect(second, first);
    expect(second.experienceIds, ['vent-1']);
  });

  test('extends a Thread when the connection links the new experience', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final thread = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', originatingVoiceMark: 'Nera', createdAt: DateTime(2026, 1, 1));
    final updated = await service.extendThread(thread: thread, experienceId: 'vent-2', voiceMark: 'Sol', connection: _connection());
    expect(updated, isNotNull);
    expect(updated!.experienceIds, ['vent-1', 'vent-2']);
    expect(updated.voiceMarks, ['Nera', 'Sol']);
    expect(updated.connections, hasLength(1));
  });

  test('rejects an extension whose connection does not touch the Thread', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final thread = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', createdAt: DateTime(2026, 1, 1));
    final updated = await service.extendThread(thread: thread, experienceId: 'vent-2', connection: _connection(id: 'vent-3_vent-4', sourceId: 'vent-3', targetId: 'vent-4'));
    expect(updated, isNull);
    expect(thread.experienceIds, ['vent-1']);
  });

  test('rejects an extension from a suggested connection', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final thread = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', createdAt: DateTime(2026, 1, 1));
    final updated = await service.extendThread(
      thread: thread,
      experienceId: 'vent-2',
      connection: _connection(state: ResonanceConnectionState.suggested),
    );
    expect(updated, isNull);
    expect(thread.experienceIds, ['vent-1']);
  });

  test('rejects an extension from a weak connection', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final thread = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', createdAt: DateTime(2026, 1, 1));
    final updated = await service.extendThread(
      thread: thread,
      experienceId: 'vent-2',
      connection: _connection(strength: 0.59),
    );
    expect(updated, isNull);
    expect(thread.experienceIds, ['vent-1']);
  });

  test('rejects an extension from a closed connection', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final thread = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', createdAt: DateTime(2026, 1, 1));
    final updated = await service.extendThread(
      thread: thread,
      experienceId: 'vent-2',
      connection: _connection(state: ResonanceConnectionState.closed),
    );
    expect(updated, isNull);
  });

  test('does not duplicate an experience already in the Thread', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    final thread = await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', createdAt: DateTime(2026, 1, 1));
    final updated = await service.extendThread(thread: thread, experienceId: 'vent-1', connection: _connection(id: 'vent-1_vent-1', sourceId: 'vent-1', targetId: 'vent-1'));
    expect(updated, same(thread));
    expect(updated!.experienceIds, ['vent-1']);
    expect(updated.connections, isEmpty);
  });

  test('can retrieve Threads containing an experience', () async {
    final repository = FakeResonanceRepository();
    final service = _service(repository);
    await service.createThread(threadId: 'thread-1', originatingExperienceId: 'vent-1', createdAt: DateTime(2026, 1, 1));
    await service.createThread(threadId: 'thread-2', originatingExperienceId: 'vent-2', createdAt: DateTime(2026, 1, 1));
    final threads = await service.getThreadsForExperience('vent-1');
    expect(threads.map((thread) => thread.id), ['thread-1']);
  });
}
