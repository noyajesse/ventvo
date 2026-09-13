import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_formation_policy.dart';

ResonanceConnection _connection({
  required String id,
  required String targetId,
  ResonanceConnectionType type = ResonanceConnectionType.sharedExperience,
  double strength = 0.8,
  ResonanceConnectionState state = ResonanceConnectionState.active,
}) {
  return ResonanceConnection(
    id: id,
    sourceId: 'vent-new',
    targetId: targetId,
    type: type,
    strength: strength,
    state: state,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  const policy = ResonanceThreadFormationPolicy();

  test('requires at least two distinct connected experiences', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      connections: [
        _connection(id: 'connection-1', targetId: 'vent-1'),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(
      decision.reason,
      ResonanceThreadFormationReason.insufficientExperiences,
    );
  });

  test('does not create a Thread from weak connections', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      connections: [
        _connection(id: 'connection-1', targetId: 'vent-1', strength: 0.5),
        _connection(id: 'connection-2', targetId: 'vent-2', strength: 0.5),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(
      decision.reason,
      ResonanceThreadFormationReason.insufficientExperiences,
    );
  });

  test('requires accepted or active connections', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      connections: [
        _connection(
          id: 'connection-1',
          targetId: 'vent-1',
          state: ResonanceConnectionState.suggested,
        ),
        _connection(
          id: 'connection-2',
          targetId: 'vent-2',
          state: ResonanceConnectionState.blocked,
        ),
      ],
    );

    expect(decision.isEligible, isFalse);
  });

  test('similarity alone is not enough to begin a Thread', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      connections: [
        _connection(
          id: 'connection-1',
          targetId: 'vent-1',
          type: ResonanceConnectionType.similarity,
        ),
        _connection(
          id: 'connection-2',
          targetId: 'vent-2',
          type: ResonanceConnectionType.similarity,
        ),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(decision.reason, ResonanceThreadFormationReason.similarityOnly);
  });

  test('shared experiences can make a Thread eligible', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      connections: [
        _connection(id: 'connection-1', targetId: 'vent-1', strength: 0.8),
        _connection(id: 'connection-2', targetId: 'vent-2', strength: 0.8),
      ],
    );

    expect(decision.isEligible, isTrue);
    expect(decision.reason, isNull);
  });

  test('response and perspective connections can contribute to a Thread', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      connections: [
        _connection(
          id: 'connection-1',
          targetId: 'vent-1',
          type: ResonanceConnectionType.response,
          strength: 0.7,
        ),
        _connection(
          id: 'connection-2',
          targetId: 'vent-2',
          type: ResonanceConnectionType.perspective,
          strength: 0.7,
        ),
      ],
    );

    expect(decision.isEligible, isTrue);
  });

  test('privacy restriction vetoes Thread formation', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      isPrivacyRestricted: true,
      connections: [
        _connection(id: 'connection-1', targetId: 'vent-1'),
        _connection(id: 'connection-2', targetId: 'vent-2'),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(decision.reason, ResonanceThreadFormationReason.privacyRestricted);
  });

  test('safety restriction vetoes Thread formation', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      isSafetyRestricted: true,
      connections: [
        _connection(id: 'connection-1', targetId: 'vent-1'),
        _connection(id: 'connection-2', targetId: 'vent-2'),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(decision.reason, ResonanceThreadFormationReason.safetyRestricted);
  });

  test('duplicate connections to the same experience do not count twice', () {
    final decision = policy.evaluate(
      experienceId: 'vent-new',
      connections: [
        _connection(id: 'connection-1', targetId: 'vent-1'),
        _connection(id: 'connection-2', targetId: 'vent-1'),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(
      decision.reason,
      ResonanceThreadFormationReason.insufficientExperiences,
    );
  });

  test('empty experience id is rejected', () {
    final decision = policy.evaluate(
      experienceId: ' ',
      connections: const [],
    );

    expect(decision.isEligible, isFalse);
    expect(decision.reason, ResonanceThreadFormationReason.invalidExperience);
  });
}
