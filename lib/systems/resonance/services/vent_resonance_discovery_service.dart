import '../../../features/spaces/models/space.dart';
import '../../../features/ventvo_voice/models/vent.dart';
import '../models/resonance_candidate.dart';
import '../models/resonance_query.dart';
import 'resonance_engine.dart';
import 'vent_resonance_signal_generator.dart';

/// Builds Resonance discovery requests from Vent domain data.
///
/// This service is the bridge between Vent domain data and the shared
/// Resonance engine. Product features should not perform matching or indexing
/// directly against the Resonance repository.
class VentResonanceDiscoveryService {
  final ResonanceEngine engine;
  final VentResonanceSignalGenerator signalGenerator;

  const VentResonanceDiscoveryService({
    required this.engine,
    this.signalGenerator = const VentResonanceSignalGenerator(),
  });

  Future<void> indexVent({
    required Vent vent,
    required Space space,
  }) async {
    if (!vent.isDiscoverable) return;

    final candidate = ResonanceCandidate(
      id: vent.id,
      type: ResonanceCandidateType.vent,
      voiceMark: vent.voiceMark,
      score: 0,
      signals: signalGenerator.generate(vent: vent, space: space),
    );

    await engine.indexCandidate(candidate);
  }

  Future<List<ResonanceCandidate>> discoverForVent({
    required Vent vent,
    required Space space,
    int limit = 10,
    Set<String> excludedIds = const {},
  }) async {
    if (!vent.isDiscoverable) return const [];

    final signals = signalGenerator.generate(vent: vent, space: space);
    final query = ResonanceQuery(
      sourceId: vent.id,
      sourceType: ResonanceCandidateType.vent,
      signals: signals,
      limit: limit,
      excludedIds: excludedIds,
    );

    return engine.discover(query);
  }
}
