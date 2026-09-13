import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_signal.dart';
import 'resonance_connection_lifecycle.dart';
import 'resonance_engine.dart';

/// Turns meaningful discovery results into suggested Resonance connections
/// and controls their lifecycle transitions.
class ResonanceConnectionService {
  final ResonanceEngine engine;
  final ResonanceConnectionLifecycle lifecycle;

  const ResonanceConnectionService({
    required this.engine,
    this.lifecycle = const ResonanceConnectionLifecycle(),
  });

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

  Future<ResonanceConnection?> accept(
    ResonanceConnection connection,
  ) async {
    return _transition(connection, ResonanceConnectionState.accepted);
  }

  Future<ResonanceConnection?> activate(
    ResonanceConnection connection,
  ) async {
    return _transition(connection, ResonanceConnectionState.active);
  }

  Future<ResonanceConnection?> close(
    ResonanceConnection connection,
  ) async {
    return _transition(connection, ResonanceConnectionState.closed);
  }

  Future<ResonanceConnection?> block(
    ResonanceConnection connection,
  ) async {
    return _transition(connection, ResonanceConnectionState.blocked);
  }

  Future<ResonanceConnection?> _transition(
    ResonanceConnection connection,
    ResonanceConnectionState targetState,
  ) async {
    if (!lifecycle.canTransition(connection.state, targetState)) {
      return null;
    }

    final updated = connection.copyWith(state: targetState);
    await engine.updateConnection(updated);
    return updated;
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
