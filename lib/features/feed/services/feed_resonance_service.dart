import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/repositories/resonance_repository.dart';
import '../../../systems/resonance/services/vent_resonance_discovery_service.dart';
import '../../../systems/resonance/services/vent_resonance_signal_generator.dart';
import '../../spaces/models/space.dart';
import '../../ventvo_voice/models/vent.dart';

/// Application service that prepares Vent experiences for Resonance and returns
/// experiences discovered for the Feed.
///
/// The Feed provider owns state; this service owns Feed-specific orchestration.
/// Matching remains entirely inside the shared Resonance system.
class FeedResonanceService {
  final ResonanceRepository repository;
  final VentResonanceDiscoveryService discoveryService;
  final VentResonanceSignalGenerator signalGenerator;

  const FeedResonanceService({
    required this.repository,
    required this.discoveryService,
    this.signalGenerator = const VentResonanceSignalGenerator(),
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

      await repository.saveCandidate(
        ResonanceCandidate(
          id: vent.id,
          type: ResonanceCandidateType.vent,
          voiceMark: vent.voiceMark,
          score: 0,
          signals: signalGenerator.generate(vent: vent, space: space),
        ),
      );
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
