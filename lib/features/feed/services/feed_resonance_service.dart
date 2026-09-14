import '../../../systems/resonance/services/vent_resonance_discovery_service.dart';
import '../../spaces/models/space.dart';
import '../../ventvo_voice/models/vent.dart';

/// Application service that prepares Vent experiences for Resonance and returns
/// experiences discovered for the Feed.
///
/// The Feed provider owns state; this service owns Feed-specific orchestration.
/// Matching and indexing remain entirely inside the shared Resonance system.
class FeedResonanceService {
  final VentResonanceDiscoveryService discoveryService;

  const FeedResonanceService({
    required this.discoveryService,
  });

  Future<List<Vent>> discover({
    required List<Vent> sources,
    required List<Space> spaces,
    required List<Vent> candidateVents,
    int limitPerSource = 10,
  }) async {
    final spacesById = {for (final space in spaces) space.id: space};

    for (final vent in candidateVents.where((item) => item.isDiscoverable)) {
      final space = spacesById[vent.spaceId];
      if (space == null) continue;
      await discoveryService.indexVent(vent: vent, space: space);
    }

    final scoresByVentId = <String, double>{};
    final excludedIds = sources.map((vent) => vent.id).toSet();

    for (final source in sources.where((item) => item.isDiscoverable)) {
      final sourceSpace = spacesById[source.spaceId];
      if (sourceSpace == null) continue;

      final candidates = await discoveryService.discoverForVent(
        vent: source,
        space: sourceSpace,
        limit: limitPerSource,
        excludedIds: excludedIds,
      );

      for (final candidate in candidates) {
        final existingScore = scoresByVentId[candidate.id];
        if (existingScore == null || candidate.score > existingScore) {
          scoresByVentId[candidate.id] = candidate.score;
        }
      }
    }

    final candidateById = {
      for (final vent in candidateVents)
        if (vent.isDiscoverable) vent.id: vent,
    };

    final discoveredIds = scoresByVentId.keys.toList()
      ..sort((a, b) {
        final scoreComparison =
            scoresByVentId[b]!.compareTo(scoresByVentId[a]!);
        if (scoreComparison != 0) return scoreComparison;
        return a.compareTo(b);
      });

    return [
      for (final id in discoveredIds)
        if (candidateById.containsKey(id)) candidateById[id]!,
    ];
  }
}
