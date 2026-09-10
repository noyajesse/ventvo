import 'resonance_candidate.dart';
import 'resonance_signal.dart';

/// Describes a request for meaningful connections from Resonance.
///
/// The query contains only the signals needed for discovery. Private account
/// identity and other sensitive metadata must stay outside this model.
class ResonanceQuery {
  final String sourceId;
  final ResonanceCandidateType sourceType;
  final List<ResonanceSignal> signals;
  final int limit;
  final Set<String> excludedIds;

  const ResonanceQuery({
    required this.sourceId,
    required this.sourceType,
    this.signals = const [],
    this.limit = 10,
    this.excludedIds = const {},
  });
}
