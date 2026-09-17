import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_gathering_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/services/resonance_gathering_service.dart';

const now = DateTime(2026, 1, 1);

ResonanceConnection connection({
  required String id,
  required String source,
  required String target,
  ResonanceConnectionState state = ResonanceConnectionState.accepted,
  double strength = 0.8,
}) {
  return ResonanceConnection(
    id: id,
    sourceId: source,
    targetId: target,
    type: ResonanceConnectionType.sharedExperience,
    strength: strength,
    state: state,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('forms a connected meaningful cluster', () {
    final map = ResonanceMap.create(
      id: 'map-one-cluster',
      experienceIds: const ['a', 'b'],
      connections: [
        connection(id: 'ab', source: 'a', target: 'b'),
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
    expect(
      candidates.map((candidate) => candidate.experienceIds),
      anyElement(equals(['a', 'b'])),
    );
    expect(
      candidates.map((candidate) => candidate.experienceIds),
      anyElement(equals(['c', 'd'])),
    );
  });
}
