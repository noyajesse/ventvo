import '../../../features/spaces/models/space.dart';
import '../../../features/ventvo_voice/models/vent.dart';
import '../models/resonance_candidate.dart';
import '../models/resonance_query.dart';
import 'resonance_engine.dart';
import 'vent_resonance_signal_generator.dart';

/// Builds Resonance discovery requests from Space domain data.
///
/// Space does not own matching logic. This service translates Space data into
/// shared Resonance operations so the same engine can power discovery across
/// Feed, Space, and Crash Out.
class SpaceResonanceDiscoveryService {
  final ResonanceEngine engine;
  final VentResonanceSignalGenerator signalGenerator;

  const SpaceResonanceDiscoveryService({
    required this.engine,
    this.signalGenerator = const VentResonanceSignalGenerator(),
  });

  /// Indexes discoverable Vents so a Space can encounter them through the
  /// shared Resonance engine.
  ///
  /// This is orchestration only. Signal generation, candidate persistence, and
  /// matching remain inside the Resonance system.
  Future<void> indexVents({
    required Iterable<Vent> vents,
    required Iterable<Space> spaces,
  }) async {
    final spacesById = {
      for (final space in spaces) space.id: space,
    };

    for (final vent in vents) {
      if (!vent.isDiscoverable) continue;

      final space = spacesById[vent.spaceId];
      if (space == null) continue;

      await engine.indexCandidate(
        ResonanceCandidate(
          id: vent.id,
          type: ResonanceCandidateType.vent,
          voiceMark: vent.voiceMark,
          score: 0,
          signals: signalGenerator.generate(
            vent: vent,
            space: space,
          ),
        ),
      );
    }
  }

  Future<List<ResonanceCandidate>> discoverRelatedVents({
    required Space space,
    required Vent originatingVent,
    int limit = 10,
    Set<String> excludedIds = const {},
  }) async {
    if (!originatingVent.isDiscoverable) return const [];

    final signals = signalGenerator.generate(
      vent: originatingVent,
      space: space,
    );

    final query = ResonanceQuery(
      sourceId: space.id,
      sourceType: ResonanceCandidateType.vent,
      signals: signals,
      limit: limit,
      excludedIds: {
        ...excludedIds,
        originatingVent.id,
        ...space.allVentIds,
      },
    );

    return engine.discover(query);
  }
}
