import '../models/resonance_connection.dart';
import '../models/resonance_thread.dart';
import 'resonance_engine.dart';
import 'resonance_thread_formation_policy.dart';
import 'resonance_thread_service.dart';

/// Decides whether an experience meaningfully continues an existing Thread or
/// has enough Resonance evidence to begin a new one.
///
/// Thread storage and mutation remain in [ResonanceThreadService]. This
/// service orchestrates formation; [ResonanceThreadFormationPolicy] owns the
/// business decision about whether a new Thread is justified.
class ResonanceThreadFormationService {
  final ResonanceEngine engine;
  final ResonanceThreadService threadService;
  final ResonanceThreadFormationPolicy formationPolicy;

  const ResonanceThreadFormationService({
    required this.engine,
    required this.threadService,
    this.formationPolicy = const ResonanceThreadFormationPolicy(),
  });

  /// Finds the strongest existing Thread that the experience can continue.
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
    final ranked = _rankThreads(
      experienceId: experienceId,
      eligibleConnections: eligibleConnections,
      threads: threads,
    );

    return ranked.isEmpty ? null : ranked.first.thread;
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
    final ranked = _rankThreads(
      experienceId: experienceId,
      eligibleConnections: eligibleConnections,
      threads: threads,
    );

    if (ranked.isEmpty) {
      return null;
    }

    final best = ranked.first;
    return threadService.extendThread(
      thread: best.thread,
      experienceId: experienceId,
      voiceMark: voiceMark,
      connection: best.connection,
    );
  }

  /// Handles a new formation event.
  ///
  /// Existing Thread first: if the experience continues one, it is extended.
  /// Otherwise the formation policy decides whether a new Thread may begin.
  /// When approved, the two strongest distinct counterpart experiences become
  /// the initial evidence of the new Thread. Repeated formation attempts are
  /// idempotent through [ResonanceThreadService].
  Future<ResonanceThread?> formThreadForExperience({
    required String experienceId,
    required String threadId,
    String? voiceMark,
    List<String> voiceMarks = const [],
    required DateTime createdAt,
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
  }) async {
    if (experienceId.trim().isEmpty || threadId.trim().isEmpty) {
      return null;
    }

    final connections = await engine.getConnectionsInvolving(experienceId);
    final existing = await findBestThreadForExperience(experienceId);
    if (existing != null) {
      final bestConnection = _bestConnectionForThread(
        existing,
        connections.where(_isEligibleConnection).toList(growable: false),
        experienceId,
      );
      if (bestConnection == null) {
        return null;
      }

      return threadService.extendThread(
        thread: existing,
        experienceId: experienceId,
        voiceMark: voiceMark,
        connection: bestConnection,
      );
    }

    final decision = formationPolicy.evaluate(
      experienceId: experienceId,
      connections: connections,
      isPrivacyRestricted: isPrivacyRestricted,
      isSafetyRestricted: isSafetyRestricted,
    );

    if (!decision.isEligible) {
      return null;
    }

    final selectedConnections = _selectFormationConnections(
      experienceId,
      connections,
    );

    if (selectedConnections.length <
        ResonanceThreadFormationPolicy.minimumMeaningfulConnections) {
      return null;
    }

    final experienceIds = <String>[
      experienceId,
      ...selectedConnections.map(
        (connection) => _counterpartId(connection, experienceId),
      ),
    ];

    final normalizedExperienceIds = experienceIds.toSet().toList();
    if (normalizedExperienceIds.length < 3) {
      return null;
    }

    return threadService.createThreadFromFormation(
      threadId: threadId,
      originatingExperienceId: experienceId,
      originatingVoiceMark: voiceMark,
      experienceIds: normalizedExperienceIds,
      voiceMarks: voiceMarks,
      connections: selectedConnections,
      createdAt: createdAt,
    );
  }

  List<_ThreadMatch> _rankThreads({
    required String experienceId,
    required List<ResonanceConnection> eligibleConnections,
    required List<ResonanceThread> threads,
  }) {
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

    ranked.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return a.thread.createdAt.compareTo(b.thread.createdAt);
    });

    return ranked;
  }

  List<ResonanceConnection> _selectFormationConnections(
    String experienceId,
    List<ResonanceConnection> connections,
  ) {
    final eligible = connections.where(_isFormationConnection).toList();
    eligible.sort((a, b) {
      final scoreComparison = _threadScore(b).compareTo(_threadScore(a));
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return a.id.compareTo(b.id);
    });

    final selected = <ResonanceConnection>[];
    final counterpartIds = <String>{};
    for (final connection in eligible) {
      final counterpart = _counterpartId(connection, experienceId);
      if (counterpart == null || counterpart == experienceId) {
        continue;
      }

      if (counterpartIds.add(counterpart)) {
        selected.add(connection);
      }

      if (selected.length ==
          ResonanceThreadFormationPolicy.minimumMeaningfulConnections) {
        break;
      }
    }

    return selected;
  }

  bool _isFormationConnection(ResonanceConnection connection) {
    return _isEligibleConnection(connection) &&
        connection.strength >=
            ResonanceThreadFormationPolicy.minimumConnectionStrength;
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
      final otherId = _counterpartId(connection, experienceId);
      if (otherId == null || !thread.containsExperience(otherId)) {
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

  String? _counterpartId(
    ResonanceConnection connection,
    String experienceId,
  ) {
    if (connection.sourceId == experienceId) {
      return connection.targetId;
    }
    if (connection.targetId == experienceId) {
      return connection.sourceId;
    }
    return null;
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
