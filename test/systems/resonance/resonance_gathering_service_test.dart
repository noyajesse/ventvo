import 'package:flutter_test/flutter_test.dart';

import '../../../lib/systems/resonance/models/resonance_connection.dart';
import '../../../lib/systems/resonance/models/resonance_map.dart';
import '../../../lib/systems/resonance/services/resonance_gathering_service.dart';

void main() {
  final now = DateTime(2026, 9, 17);

  ResonanceConnection connection({
    required String id,
    required String source,
    required String target,
    double strength = 0.8,
    ResonanceConnectionState state = ResonanceConnectionState.accepted,
  }) {
    return ResonanceConnection(
      id: id,
      sourceId: source,
      targetId: target,
      type: ResonanceConnectionType.sharedExperience,
      strength: strength,
      state: state,
      createdAt: now,
    );
  }

  test('forms a candidate from a connected cluster without a fixed size', () {
    final map = ResonanceMap.create(
      id: 'map-starting-over',
      experienceIds: const ['a', 'b', 'c', 'd'],
      connections: [
        connection(id: 'ab', source: 'a', target: 'b'),
        connection(id: 'bc', source: 'b', target: 'c'),
        connection(id: 'cd', source: 'c', target: 'd'),
      ],
      createdAt: now,
    );

    final candidates = const ResonanceGatheringService().discoverCandidates(map);

    expect(candidates, hasLength(1));
    expect(candidates.single.experienceIds, ['a', 'b', 'c', 'd']);
    expect(candidates.single.connections, hasLength(3));
  });

  test('does not include suggested, closed, blocked, or weak relationships', () {
    final map = ResonanceMap.create(
      id: 'map-filtered',
      experienceIds: const ['a', 'b', 'c', 'd', 'e'],
      connections: [
        connection(id: 'ab', source: 'a', target: 'b'),
        connection(
          id: 'bc',
          source: 'b',
          target: 'c',
          state: ResonanceConnectionState.suggested,
        ),
        connection(
          id: 'cd',
          source: 'c',
          target: 'd',
          strength: 0.4,
        ),
        connection(
          id: 'de',
          source: 'd',
          target: 'e',
          state: ResonanceConnectionState.blocked,
        ),
      ],
      createdAt: now,
    );

    final candidates = const ResonanceGatheringService().discoverCandidates(map);

    expect(candidates, hasLength(1));
    expect(candidates.single.experienceIds, ['a', 'b']);
  });

  test('separates disconnected meaningful clusters', () {
    final map = ResonanceMap.create(
      id: 'map-two-clusters',
      experienceIds: const ['a', 'b', 'c', 'd'],
      connections: [
        connection(id: 'ab', source: 'a', target: 'b'),
        connection(id: 'cd', source: 'c', target: 'd'),
      ],
      createdAt: now,
    );

    final candidates = const ResonanceGatheringService().discoverCandidates(map);

    expect(candidates, hasLength(2));
    expect(candidates.map((candidate) => candidate.experienceIds), contains(['a', 'b']));
    expect(candidates.map((candidate) => candidate.experienceIds), contains(['c', 'd']));
  });
}
