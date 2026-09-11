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

    final discovered = <Vent>[];
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
        final vent = candidateVents
            .where((item) => item.id == candidate.id)
            .firstOrNull;
        if (vent != null && !discovered.any((item) => item.id == vent.id)) {
          discovered.add(vent);
        }
      }
    }

    return discovered;
  }
}
