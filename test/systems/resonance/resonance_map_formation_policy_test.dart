import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_formation_policy.dart';

void main() {
  const policy = ResonanceMapFormationPolicy();

  ResonanceConnection connection({
    required String id,
    required String targetId,
    ResonanceConnectionType type = ResonanceConnectionType.sharedExperience,
    double strength = 0.7,
    ResonanceConnectionState state = ResonanceConnectionState.active,
  }) {
    return ResonanceConnection.create(
      id: id,
      sourceId: 'origin',
      targetId: targetId,
      type: type,
      strength: strength,
      state: state,
      createdAt: DateTime(2026),
    );
  }

  test('allows formation from two strong meaningful counterparts', () {
    final decision = policy.evaluate(
      experienceId: 'origin',
      connections: [
        connection(id: 'c1', targetId: 'experience-a', strength: 0.7),
        connection(id: 'c2', targetId: 'experience-b', strength: 0.7),
      ],
    );

    expect(decision.isEligible, isTrue);
    expect(decision.experienceIds, containsAll(['origin', 'experience-a', 'experience-b']));
    expect(decision.connections, hasLength(2));
  });

  test('rejects formation with only one counterpart', () {
    final decision = policy.evaluate(
      experienceId: 'origin',
      connections: [connection(id: 'c1', targetId: 'experience-a')],
    );

    expect(decision.isEligible, isFalse);
    expect(
      decision.reason,
      ResonanceMapFormationReason.insufficientExperiences,
    );
  });

  test('rejects similarity-only connections', () {
    final decision = policy.evaluate(
      experienceId: 'origin',
      connections: [
        connection(
          id: 'c1',
          targetId: 'experience-a',
          type: ResonanceConnectionType.similarity,
        ),
        connection(
          id: 'c2',
          targetId: 'experience-b',
          type: ResonanceConnectionType.similarity,
        ),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(
      decision.reason,
      ResonanceMapFormationReason.insufficientExperiences,
    );
  });

  test('rejects weak connections', () {
    final decision = policy.evaluate(
      experienceId: 'origin',
      connections: [
        connection(id: 'c1', targetId: 'experience-a', strength: 0.5),
        connection(id: 'c2', targetId: 'experience-b', strength: 0.5),
      ],
    );

    expect(decision.isEligible, isFalse);
    expect(
      decision.reason,
      ResonanceMapFormationReason.insufficientExperiences,
    );
  });

  test('privacy restriction vetoes formation', () {
    final decision = policy.evaluate(
      experienceId: 'origin',
      connections: [
        connection(id: 'c1', targetId: 'experience-a'),
        connection(id: 'c2', targetId: 'experience-b'),
      ],
      isPrivacyRestricted: true,
    );

    expect(decision.isEligible, isFalse);
    expect(decision.reason, ResonanceMapFormationReason.privacyRestricted);
  });

  test('safety restriction vetoes formation', () {
    final decision = policy.evaluate(
      experienceId: 'origin',
      connections: [
        connection(id: 'c1', targetId: 'experience-a'),
        connection(id: 'c2', targetId: 'experience-b'),
      ],
      isSafetyRestricted: true,
    );

    expect(decision.isEligible, isFalse);
    expect(decision.reason, ResonanceMapFormationReason.safetyRestricted);
  });

  test('accepted connections can form a Map', () {
    final decision = policy.evaluate(
      experienceId: 'origin',
      connections: [
        connection(
          id: 'c1',
          targetId: 'experience-a',
          state: ResonanceConnectionState.accepted,
        ),
        connection(
          id: 'c2',
          targetId: 'experience-b',
          state: ResonanceConnectionState.accepted,
        ),
      ],
    );

    expect(decision.isEligible, isTrue);
  });
}
