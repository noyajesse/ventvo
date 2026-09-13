import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_integrity_policy.dart';

void main() {
  const policy = ResonanceThreadIntegrityPolicy();
  final createdAt = DateTime(2026, 1, 1);

  ResonanceConnection connection({
    required String sourceId,
    required String targetId,
    ResonanceConnectionState state = ResonanceConnectionState.active,
    ResonanceConnectionType type = ResonanceConnectionType.sharedExperience,
    double strength = 0.8,
    String? id,
  }) {
    return ResonanceConnection(
      id: id ?? '${sourceId}_$targetId',
      sourceId: sourceId,
      targetId: targetId,
      type: type,
      strength: strength,
      state: state,
      createdAt: createdAt,
    );
  }

  ResonanceThread thread(List<ResonanceConnection> connections) {
    return ResonanceThread.create(
      id: 'thread-1',
      originatingExperienceId: 'experience-1',
      experienceIds: const [
        'experience-1',
        'experience-2',
        'experience-3',
      ],
      connections: connections,
      createdAt: createdAt,
    );
  }

  test('keeps a Thread active when a meaningful live connection remains', () {
    final result = policy.evaluate(
      thread([
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-2',
          id: 'connection-1',
        ),
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-3',
          id: 'connection-2',
          state: ResonanceConnectionState.closed,
        ),
      ]),
    );

    expect(result.status, ResonanceThreadIntegrityStatus.active);
    expect(result.liveConnections, hasLength(1));
    expect(result.closedConnections, hasLength(1));
    expect(result.isDiscoverable, isTrue);
  });

  test('moves a Thread to dormant when all meaningful connections close', () {
    final result = policy.evaluate(
      thread([
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-2',
          id: 'connection-1',
          state: ResonanceConnectionState.closed,
        ),
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-3',
          id: 'connection-2',
          state: ResonanceConnectionState.closed,
        ),
      ]),
    );

    expect(result.status, ResonanceThreadIntegrityStatus.dormant);
    expect(result.liveConnections, isEmpty);
    expect(result.closedConnections, hasLength(2));
    expect(result.isDormant, isTrue);
    expect(result.isDiscoverable, isFalse);
  });

  test('restricts a Thread when blocked connections are the only remaining links', () {
    final result = policy.evaluate(
      thread([
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-2',
          id: 'connection-1',
          state: ResonanceConnectionState.blocked,
        ),
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-3',
          id: 'connection-2',
          state: ResonanceConnectionState.closed,
        ),
      ]),
    );

    expect(result.status, ResonanceThreadIntegrityStatus.restricted);
    expect(result.blockedConnections, hasLength(1));
    expect(result.isRestricted, isTrue);
    expect(result.isDiscoverable, isFalse);
  });

  test('blocked connection does not hide a Thread that still has another live link', () {
    final result = policy.evaluate(
      thread([
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-2',
          id: 'connection-1',
          state: ResonanceConnectionState.blocked,
        ),
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-3',
          id: 'connection-2',
        ),
      ]),
    );

    expect(result.status, ResonanceThreadIntegrityStatus.active);
    expect(result.liveConnections, hasLength(1));
    expect(result.blockedConnections, hasLength(1));
    expect(result.isDiscoverable, isTrue);
  });

  test('suggested connections do not keep a Thread alive', () {
    final result = policy.evaluate(
      thread([
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-2',
          id: 'connection-1',
          state: ResonanceConnectionState.suggested,
        ),
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-3',
          id: 'connection-2',
          state: ResonanceConnectionState.suggested,
        ),
      ]),
    );

    expect(result.status, ResonanceThreadIntegrityStatus.dormant);
    expect(result.liveConnections, isEmpty);
  });

  test('weak live connections do not keep a Thread active', () {
    final result = policy.evaluate(
      thread([
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-2',
          id: 'connection-1',
          strength: 0.5,
        ),
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-3',
          id: 'connection-2',
          strength: 0.4,
        ),
      ]),
    );

    expect(result.status, ResonanceThreadIntegrityStatus.dormant);
    expect(result.liveConnections, isEmpty);
  });

  test('similarity and discovery connections do not keep a Thread active', () {
    final result = policy.evaluate(
      thread([
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-2',
          id: 'connection-1',
          type: ResonanceConnectionType.similarity,
        ),
        connection(
          sourceId: 'experience-1',
          targetId: 'experience-3',
          id: 'connection-2',
          type: ResonanceConnectionType.discovery,
        ),
      ]),
    );

    expect(result.status, ResonanceThreadIntegrityStatus.dormant);
    expect(result.liveConnections, isEmpty);
  });
}
