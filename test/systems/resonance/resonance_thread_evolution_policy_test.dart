import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_evolution_policy.dart';

ResonanceThread _thread() {
  return ResonanceThread.create(
    id: 'thread-1',
    originatingExperienceId: 'vent-1',
    experienceIds: const ['vent-1', 'vent-2'],
    voiceMarks: const ['Nera', 'Sol'],
    createdAt: DateTime(2026, 1, 1),
  );
}

ResonanceConnection _connection({
  String sourceId = 'vent-1',
  String targetId = 'vent-3',
  double strength = 0.8,
  ResonanceConnectionState state = ResonanceConnectionState.active,
}) {
  return ResonanceConnection(
    id: '${sourceId}_$targetId',
    sourceId: sourceId,
    targetId: targetId,
    type: ResonanceConnectionType.sharedExperience,
    strength: strength,
    state: state,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  const policy = ResonanceThreadEvolutionPolicy();

  test('allows a strong live connection to add a new experience', () {
    final decision = policy.evaluate(
      thread: _thread(),
      experienceId: 'vent-3',
      connection: _connection(),
    );

    expect(decision.allowed, isTrue);
    expect(decision.reason, ResonanceThreadEvolutionReason.allowed);
  });

  test('rejects an experience already in the Thread', () {
    final decision = policy.evaluate(
      thread: _thread(),
      experienceId: 'vent-2',
      connection: _connection(targetId: 'vent-2'),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceThreadEvolutionReason.alreadyInThread);
  });

  test('rejects a connection that does not touch the Thread', () {
    final decision = policy.evaluate(
      thread: _thread(),
      experienceId: 'vent-3',
      connection: _connection(sourceId: 'vent-8', targetId: 'vent-3'),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason,
        ResonanceThreadEvolutionReason.notConnectedToThread);
  });

  test('rejects suggested connections', () {
    final decision = policy.evaluate(
      thread: _thread(),
      experienceId: 'vent-3',
      connection: _connection(state: ResonanceConnectionState.suggested),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason,
        ResonanceThreadEvolutionReason.connectionNotLive);
  });

  test('rejects closed connections', () {
    final decision = policy.evaluate(
      thread: _thread(),
      experienceId: 'vent-3',
      connection: _connection(state: ResonanceConnectionState.closed),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason,
        ResonanceThreadEvolutionReason.connectionNotLive);
  });

  test('rejects blocked connections', () {
    final decision = policy.evaluate(
      thread: _thread(),
      experienceId: 'vent-3',
      connection: _connection(state: ResonanceConnectionState.blocked),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason,
        ResonanceThreadEvolutionReason.connectionNotLive);
  });

  test('rejects weak connections', () {
    final decision = policy.evaluate(
      thread: _thread(),
      experienceId: 'vent-3',
      connection: _connection(strength: 0.59),
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceThreadEvolutionReason.insufficientResonance);
  });
}
