import '../models/resonance_connection.dart';
import '../models/resonance_thread.dart';
import 'resonance_engine.dart';
import 'resonance_thread_service.dart';

/// Decides whether an experience meaningfully continues an existing Thread.
///
/// Thread storage and mutation remain in [ResonanceThreadService]. This
/// service only evaluates existing Resonance connections and selects the
/// strongest eligible Thread.
class ResonanceThreadFormationService {
  final ResonanceEngine engine;
  final ResonanceThreadService threadService;

  const ResonanceThreadFormationService({
    required this.engine,
    required this.threadService,
  });

  /// Finds the strongest existing Thread that the experience can continue.
  ///
  /// A connection must be accepted or active, must not be closed/blocked,
  /// and must connect the experience to an existing Thread member. The first
  /// deterministic implementation is intentionally conservative: it uses
  /// connection strength plus connection type rather than inventing a second
  /// matching system outside Resonance.
  Future<ResonanceThread?> findBestThreadForExperience(
    String experienceId,
  ) async {
    if (experienceId.trim().isEmpty) {
      return null;
    }

    final connections = await engine.getConnectionsInvolving(experienceId);
    final eligibleConnections = connections
        .where(_isEligibleConnection)
        .toList(growable: false);

    if (eligibleConnections.isEmpty) {
      return null;
    }

    final threads = await engine.getThreads();
    final ranked = <_ThreadMatch>[];

    for (final thread in threads) {
      if (thread.containsExperience(experienceId)) {
        continue;
      }

      final bestConnection = _bestConnectionForThread(
        thread,
        eligibleConnections,
        experienceId,
      );

      if (bestConnection == null) {
        continue;
      }

      ranked.add(
        _ThreadMatch(
          thread: thread,
          connection: bestConnection,
          score: _threadScore(bestConnection),
        ),
      );
    }

    if (ranked.isEmpty) {
      return null;
    }

    ranked.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return a.thread.createdAt.compareTo(b.thread.createdAt);
    });

    return ranked.first.thread;
  }

  /// Finds the best Thread and extends it when a meaningful continuation
  /// exists. Returns null when no existing Thread is strong enough.
  Future<ResonanceThread?> extendBestThreadForExperience({
    required String experienceId,
    String? voiceMark,
  }) async {
    if (experienceId.trim().isEmpty) {
      return null;
    }

    final connections = await engine.getConnectionsInvolving(experienceId);
    final eligibleConnections = connections
        .where(_isEligibleConnection)
        .toList(growable: false);

    if (eligibleConnections.isEmpty) {
      return null;
    }

    final threads = await engine.getThreads();
    final ranked = <_ThreadMatch>[];

    for (final thread in threads) {
      if (thread.containsExperience(experienceId)) {
        continue;
      }

      final bestConnection = _bestConnectionForThread(
        thread,
        eligibleConnections,
        experienceId,
      );

      if (bestConnection == null) {
        continue;
      }

      ranked.add(
        _ThreadMatch(
          thread: thread,
          connection: bestConnection,
          score: _threadScore(bestConnection),
        ),
      );
    }

    if (ranked.isEmpty) {
      return null;
    }

    ranked.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return a.thread.createdAt.compareTo(b.thread.createdAt);
    });

    final best = ranked.first;
    return threadService.extendThread(
      thread: best.thread,
      experienceId: experienceId,
      voiceMark: voiceMark,
      connection: best.connection,
    );
  }

  bool _isEligibleConnection(ResonanceConnection connection) {
    return (connection.state == ResonanceConnectionState.accepted ||
            connection.state == ResonanceConnectionState.active) &&
        connection.strength > 0;
  }

  ResonanceConnection? _bestConnectionForThread(
    ResonanceThread thread,
    List<ResonanceConnection> connections,
    String experienceId,
  ) {
    ResonanceConnection? best;
    var bestScore = -1.0;

    for (final connection in connections) {
      final otherId = connection.sourceId == experienceId
          ? connection.targetId
          : connection.sourceId;

      if (!thread.containsExperience(otherId)) {
        continue;
      }

      final score = _threadScore(connection);
      if (score > bestScore) {
        best = connection;
        bestScore = score;
      }
    }

    return best;
  }

  double _threadScore(ResonanceConnection connection) {
    final typeWeight = switch (connection.type) {
      ResonanceConnectionType.sharedExperience => 1.0,
      ResonanceConnectionType.response => 0.95,
      ResonanceConnectionType.perspective => 0.85,
      ResonanceConnectionType.similarity => 0.7,
      ResonanceConnectionType.discovery => 0.5,
    };

    final stateWeight = switch (connection.state) {
      ResonanceConnectionState.active => 1.0,
      ResonanceConnectionState.accepted => 0.9,
      ResonanceConnectionState.suggested => 0.0,
      ResonanceConnectionState.closed => 0.0,
      ResonanceConnectionState.blocked => 0.0,
    };

    return connection.strength.clamp(0.0, 1.0).toDouble() *
        typeWeight *
        stateWeight;
  }
}

class _ThreadMatch {
  final ResonanceThread thread;
  final ResonanceConnection connection;
  final double score;

  const _ThreadMatch({
    required this.thread,
    required this.connection,
    required this.score,
  });
}
