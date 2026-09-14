import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_signal.dart';
import 'resonance_connection_lifecycle.dart';
import 'resonance_engine.dart';
import 'resonance_map_event_service.dart';
import 'resonance_thread_reconciliation_service.dart';

/// Turns meaningful discovery results into suggested Resonance connections
/// and controls their lifecycle transitions.
class ResonanceConnectionService {
  final ResonanceEngine engine;
  final ResonanceConnectionLifecycle lifecycle;
  final ResonanceThreadReconciliationService? threadReconciliationService;
  final ResonanceMapEventService? mapEventService;

  const ResonanceConnectionService({
    required this.engine,
    this.lifecycle = const ResonanceConnectionLifecycle(),
    this.threadReconciliationService,
    this.mapEventService,
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

  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) {
    if (sourceId.trim().isEmpty || targetId.trim().isEmpty) {
      return Future.value(null);
    }
    return engine.getConnectionBetween(sourceId, targetId);
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

    await _reconcileThreadsFor(updated);
    await _handleMapEventFor(updated);
    return updated;
  }

  Future<void> _reconcileThreadsFor(
    ResonanceConnection connection,
  ) async {
    final service = threadReconciliationService;
    if (service == null) return;

    final threadIds = <String>{};
    for (final experienceId in [connection.sourceId, connection.targetId]) {
      final threads = await engine.getThreadsForExperience(experienceId);
      threadIds.addAll(threads.map((thread) => thread.id));
    }

    for (final threadId in threadIds) {
      await service.reconcile(threadId);
    }
  }

  Future<void> _handleMapEventFor(
    ResonanceConnection connection,
  ) async {
    final service = mapEventService;
    if (service == null) return;

    await service.handleConnectionStateChange(connection);
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
