import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_signal.dart';
import 'resonance_engine.dart';

/// Turns meaningful discovery results into suggested Resonance connections.
///
/// Product features do not decide connection types or persist connections
/// themselves. This service keeps that orchestration inside the Resonance
/// system while the engine remains responsible for discovery and storage.
class ResonanceConnectionService {
  final ResonanceEngine engine;

  const ResonanceConnectionService({required this.engine});

  Future<ResonanceConnection?> suggestConnection({
    required String sourceId,
    required ResonanceCandidate candidate,
  }) async {
    if (candidate.id == sourceId || candidate.score <= 0) return null;

    final type = _inferType(candidate);
    return engine.createConnection(
      sourceId: sourceId,
      targetId: candidate.id,
      type: type,
      strength: candidate.score.clamp(0.0, 1.0).toDouble(),
    );
  }

  ResonanceConnectionType _inferType(ResonanceCandidate candidate) {
    final signals = candidate.profile?.signals ?? candidate.signals;
    final hasExperience = signals.any(
      (signal) => signal.type == ResonanceSignalType.experiential,
    );
    final hasContext = signals.any(
      (signal) => signal.type == ResonanceSignalType.semantic ||
          signal.type == ResonanceSignalType.context,
    );
    final hasIntent = signals.any(
      (signal) => signal.type == ResonanceSignalType.intent,
    );

    if (hasExperience && hasContext) {
      return ResonanceConnectionType.sharedExperience;
    }

    if (hasIntent && hasContext) {
      return ResonanceConnectionType.perspective;
    }

    return ResonanceConnectionType.similarity;
  }
}
