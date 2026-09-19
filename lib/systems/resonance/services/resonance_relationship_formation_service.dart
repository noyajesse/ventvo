import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import '../models/resonance_thread.dart';
import 'resonance_map_formation_service.dart';
import 'resonance_thread_formation_service.dart';

/// Coordinates Thread and Map formation after real Resonance relationship
/// evidence changes state.
///
/// This service does not lower formation thresholds or invent relationships.
/// The Thread/Map formation policies remain the source of truth.
class ResonanceRelationshipFormationService {
  final ResonanceThreadFormationService threadFormationService;
  final ResonanceMapFormationService mapFormationService;

  const ResonanceRelationshipFormationService({
    required this.threadFormationService,
    required this.mapFormationService,
  });

  Future<ResonanceRelationshipFormationResult> handleConnectionStateChange(
    ResonanceConnection connection,
  ) async {
    if (!_canForm(connection)) {
      return const ResonanceRelationshipFormationResult.empty();
    }

    ResonanceThread? formedThread;
    ResonanceMap? formedMap;

    for (final experienceId in {
      connection.sourceId,
      connection.targetId,
    }) {
      final thread = await threadFormationService.formThreadForExperience(
        experienceId: experienceId,
        threadId: _buildThreadId(connection, experienceId),
        createdAt: connection.createdAt,
      );
      formedThread ??= thread;

      final map = await mapFormationService.formForExperience(
        experienceId,
        createdAt: connection.createdAt,
      );
      formedMap ??= map;
    }

    return ResonanceRelationshipFormationResult(
      thread: formedThread,
      map: formedMap,
    );
  }

  bool _canForm(ResonanceConnection connection) {
    return connection.state == ResonanceConnectionState.accepted ||
        connection.state == ResonanceConnectionState.active;
  }

  String _buildThreadId(
    ResonanceConnection connection,
    String experienceId,
  ) {
    final ids = [experienceId, connection.sourceId, connection.targetId]..sort();
    return 'thread-${ids.join('-')}';
  }
}

class ResonanceRelationshipFormationResult {
  final ResonanceThread? thread;
  final ResonanceMap? map;

  const ResonanceRelationshipFormationResult({
    this.thread,
    this.map,
  });

  const ResonanceRelationshipFormationResult.empty()
      : thread = null,
        map = null;
}
