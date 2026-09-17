import '../models/resonance_connection.dart';
import '../models/resonance_gathering_candidate.dart';
import '../models/resonance_map.dart';

/// Finds meaningful connected clusters inside a Resonance Map that can later
/// be offered as temporary Gatherings.
///
/// The service does not create chat rooms, invite users, or choose a fixed
/// participant count. It only turns existing relationship evidence into
/// opt-in Gathering candidates.
class ResonanceGatheringService {
  const ResonanceGatheringService();

  List<ResonanceGatheringCandidate> discoverCandidates(
    ResonanceMap map, {
    double minimumConnectionStrength = 0.65,
  }) {
    final eligible = map.connections.where((connection) {
      return _isEligible(connection, minimumConnectionStrength);
    }).toList(growable: false);

    if (eligible.isEmpty) return const [];

    final adjacency = <String, Set<String>>{};
    for (final id in map.experienceIds) {
      adjacency[id] = <String>{};
    }

    for (final connection in eligible) {
      adjacency[connection.sourceId]?.add(connection.targetId);
      adjacency[connection.targetId]?.add(connection.sourceId);
    }

    final remaining = map.experienceIds.toSet();
    final candidates = <ResonanceGatheringCandidate>[];

    while (remaining.isNotEmpty) {
      final start = remaining.first;
      final component = <String>{};
      final queue = <String>[start];

      while (queue.isNotEmpty) {
        final current = queue.removeLast();
        if (!remaining.remove(current)) continue;
        component.add(current);
        queue.addAll(adjacency[current]!.where(remaining.contains));
      }

      if (component.length < 2) continue;

      final componentConnections = eligible.where((connection) {
        return component.contains(connection.sourceId) &&
            component.contains(connection.targetId);
      }).toList(growable: false);

      final sortedIds = component.toList()..sort();
      candidates.add(
        ResonanceGatheringCandidate(
          id: 'gathering-candidate-${map.id}-${sortedIds.join('-')}',
          mapId: map.id,
          experienceIds: List.unmodifiable(sortedIds),
          connections: List.unmodifiable(componentConnections),
        ),
      );
    }

    return List.unmodifiable(candidates);
  }

  bool _isEligible(
    ResonanceConnection connection,
    double minimumConnectionStrength,
  ) {
    if (connection.state != ResonanceConnectionState.accepted &&
        connection.state != ResonanceConnectionState.active) {
      return false;
    }

    return connection.strength >= minimumConnectionStrength;
  }
}
