import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_evolution_policy.dart';

void main() {
  final policy = ResonanceMapEvolutionPolicy();
  final map = ResonanceMap.create(
    id: 'map-1',
    experienceIds: const ['experience-1', 'experience-2', 'experience-3'],
    createdAt: DateTime(2026),
  );

  ResonanceConnection connection({
    String id = 'connection-1',
    String sourceId = 'experience-4',
    String targetId = 'experience-1',
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
      createdAt: DateTime(2026),
    );
  }

  test('allows a new experience through a meaningful live connection', () {
    final decision = policy.evaluate(
      map: map,
      experienceId: 'experience-4',
      connections: [connection()],
    );

    expect(decision.allowed, isTrue);
    expect(decision.reason, ResonanceMapEvolutionReason.allowed);
    expect(decision.connections, hasLength(1));
  });

  test('rejects an experience already in the Map', () {
    final decision = policy.evaluate(
      map: map,
      experienceId: 'experience-1',
      connections: [
        connection(sourceId: 'experience-1', targetId: 'experience-2'),
      ],
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceMapEvolutionReason.alreadyInMap);
  });

  test('rejects connections that do not touch the Map', () {
    final decision = policy.evaluate(
      map: map,
      experienceId: 'experience-4',
      connections: [
        connection(targetId: 'experience-5'),
      ],
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceMapEvolutionReason.insufficientResonance);
  });

  test('rejects weak connections', () {
    final decision = policy.evaluate(
      map: map,
      experienceId: 'experience-4',
      connections: [connection(strength: 0.59)],
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceMapEvolutionReason.insufficientResonance);
  });

  test('rejects similarity and discovery connections', () {
    for (final type in [
      ResonanceConnectionType.similarity,
      ResonanceConnectionType.discovery,
    ]) {
      final decision = policy.evaluate(
        map: map,
        experienceId: 'experience-4',
        connections: [connection(type: type)],
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, ResonanceMapEvolutionReason.insufficientResonance);
    }
  });

  test('rejects non-live connections', () {
    for (final state in [
      ResonanceConnectionState.suggested,
      ResonanceConnectionState.closed,
      ResonanceConnectionState.blocked,
    ]) {
      final decision = policy.evaluate(
        map: map,
        experienceId: 'experience-4',
        connections: [connection(state: state)],
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, ResonanceMapEvolutionReason.insufficientResonance);
    }
  });

  test('rejects privacy restricted evolution', () {
    final decision = policy.evaluate(
      map: map,
      experienceId: 'experience-4',
      connections: [connection()],
      isPrivacyRestricted: true,
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceMapEvolutionReason.privacyRestricted);
  });

  test('rejects safety restricted evolution', () {
    final decision = policy.evaluate(
      map: map,
      experienceId: 'experience-4',
      connections: [connection()],
      isSafetyRestricted: true,
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceMapEvolutionReason.safetyRestricted);
  });

  test('rejects an invalid Map', () {
    final invalidMap = ResonanceMap.create(
      id: 'map-1',
      experienceIds: const ['experience-1', 'experience-2'],
      createdAt: DateTime(2026),
    );

    final decision = policy.evaluate(
      map: invalidMap,
      experienceId: 'experience-4',
      connections: [connection()],
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceMapEvolutionReason.invalidMap);
  });

  test('rejects a blank experience id', () {
    final decision = policy.evaluate(
      map: map,
      experienceId: '   ',
      connections: [connection()],
    );

    expect(decision.allowed, isFalse);
    expect(decision.reason, ResonanceMapEvolutionReason.invalidExperience);
  });
}
