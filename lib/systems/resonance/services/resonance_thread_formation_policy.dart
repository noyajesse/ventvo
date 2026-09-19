import '../models/resonance_connection.dart';

/// Business rules that decide whether an experience has enough Resonance
/// evidence to begin a new Thread.
///
/// This policy intentionally does not create or mutate Threads. It answers a
/// single domain question: is this collection of connections meaningful enough
/// to justify creating one?
class ResonanceThreadFormationPolicy {
  static const int minimumMeaningfulConnections = 2;
  static const double minimumConnectionStrength = 0.6;
  static const double minimumCombinedScore = 1.2;

  const ResonanceThreadFormationPolicy();

  ResonanceThreadFormationDecision evaluate({
    required String experienceId,
    required List<ResonanceConnection> connections,
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
  }) {
    if (experienceId.trim().isEmpty) {
      return const ResonanceThreadFormationDecision.ineligible(
        ResonanceThreadFormationReason.invalidExperience,
      );
    }

    if (isPrivacyRestricted) {
      return const ResonanceThreadFormationDecision.ineligible(
        ResonanceThreadFormationReason.privacyRestricted,
      );
    }

    if (isSafetyRestricted) {
      return const ResonanceThreadFormationDecision.ineligible(
        ResonanceThreadFormationReason.safetyRestricted,
      );
    }

    final eligible = connections.where(_isEligible).toList(growable: false);

    final counterpartIds = eligible
        .map((connection) => _counterpartId(connection, experienceId))
        .whereType<String>()
        .toSet();

    if (counterpartIds.length < minimumMeaningfulConnections) {
      return const ResonanceThreadFormationDecision.ineligible(
        ResonanceThreadFormationReason.insufficientExperiences,
      );
    }

    final voiceIds = _distinctVoiceIds(
      experienceId: experienceId,
      connections: eligible,
    );
    if (voiceIds == null || voiceIds.length < minimumMeaningfulConnections + 1) {
      return const ResonanceThreadFormationDecision.ineligible(
        ResonanceThreadFormationReason.insufficientVoices,
      );
    }

    final hasMeaningfulConnection = eligible.any(_isMeaningfulConnectionType);
    if (!hasMeaningfulConnection) {
      return const ResonanceThreadFormationDecision.ineligible(
        ResonanceThreadFormationReason.similarityOnly,
      );
    }

    final combinedScore = eligible.fold<double>(
      0,
      (total, connection) => total + _score(connection),
    );

    if (combinedScore < minimumCombinedScore) {
      return const ResonanceThreadFormationDecision.ineligible(
        ResonanceThreadFormationReason.insufficientResonance,
      );
    }

    return const ResonanceThreadFormationDecision.eligible();
  }

  bool _isEligible(ResonanceConnection connection) {
    return (connection.state == ResonanceConnectionState.accepted ||
            connection.state == ResonanceConnectionState.active) &&
        connection.strength >= minimumConnectionStrength;
  }

  bool _isMeaningfulConnectionType(ResonanceConnection connection) {
    return connection.type == ResonanceConnectionType.sharedExperience ||
        connection.type == ResonanceConnectionType.response ||
        connection.type == ResonanceConnectionType.perspective;
  }

  Set<String>? _distinctVoiceIds({
    required String experienceId,
    required List<ResonanceConnection> connections,
  }) {
    String? focalVoiceId;
    final counterpartVoiceIds = <String>{};

    for (final connection in connections) {
      if (connection.sourceId == experienceId) {
        final sourceVoiceId = connection.sourceVoiceId;
        final targetVoiceId = connection.targetVoiceId;
        if (sourceVoiceId == null ||
            sourceVoiceId.trim().isEmpty ||
            targetVoiceId == null ||
            targetVoiceId.trim().isEmpty) {
          return null;
        }
        focalVoiceId ??= sourceVoiceId;
        counterpartVoiceIds.add(targetVoiceId);
      } else if (connection.targetId == experienceId) {
        final sourceVoiceId = connection.sourceVoiceId;
        final targetVoiceId = connection.targetVoiceId;
        if (sourceVoiceId == null ||
            sourceVoiceId.trim().isEmpty ||
            targetVoiceId == null ||
            targetVoiceId.trim().isEmpty) {
          return null;
        }
        focalVoiceId ??= targetVoiceId;
        counterpartVoiceIds.add(sourceVoiceId);
      }
    }

    if (focalVoiceId == null || counterpartVoiceIds.length < 2) {
      return null;
    }

    return {focalVoiceId, ...counterpartVoiceIds};
  }

  String? _counterpartVoiceId(
    ResonanceConnection connection,
    String experienceId,
  ) {
    if (connection.sourceId == experienceId) {
      return connection.targetVoiceId;
    }
    if (connection.targetId == experienceId) {
      return connection.sourceVoiceId;
    }
    return null;
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

  double _score(ResonanceConnection connection) {
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

enum ResonanceThreadFormationReason {
  invalidExperience,
  privacyRestricted,
  safetyRestricted,
  insufficientExperiences,
  insufficientVoices,
  similarityOnly,
  insufficientResonance,
}

class ResonanceThreadFormationDecision {
  final bool isEligible;
  final ResonanceThreadFormationReason? reason;

  const ResonanceThreadFormationDecision._({
    required this.isEligible,
    required this.reason,
  });

  const ResonanceThreadFormationDecision.eligible()
      : this._(isEligible: true, reason: null);

  const ResonanceThreadFormationDecision.ineligible(
    ResonanceThreadFormationReason reason,
  ) : this._(isEligible: false, reason: reason);
}
