import '../models/resonance_candidate.dart';
import '../models/resonance_query.dart';
import 'resonance_engine.dart';

/// Application-facing discovery boundary for the Feed.
///
/// The Feed consumes Resonance results through this service instead of
/// implementing its own matching or ranking logic.
class ResonanceFeedDiscoveryService {
  final ResonanceEngine engine;

  const ResonanceFeedDiscoveryService({required this.engine});

  Future<List<ResonanceCandidate>> discover({
    required String sourceId,
    List<ResonanceSignal> signals = const [],
    int limit = 20,
    Set<String> excludedIds = const {},
  }) async {
    _validateSourceId(sourceId);
    _validateLimit(limit);

    final query = ResonanceQuery(
      sourceId: sourceId,
      sourceType: ResonanceCandidateType.vent,
      signals: signals,
      limit: limit,
      excludedIds: excludedIds,
    );

    return List.unmodifiable(await engine.discover(query));
  }

  void _validateSourceId(String sourceId) {
    if (sourceId.trim().isEmpty) {
      throw ArgumentError.value(
        sourceId,
        'sourceId',
        'Source id cannot be empty.',
      );
    }
  }

  void _validateLimit(int limit) {
    if (limit <= 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Limit must be greater than zero.',
      );
    }
  }
}
