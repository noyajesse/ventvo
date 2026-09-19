import '../models/resonance_connection.dart';

/// Business rules that decide whether a group of Resonance connections
/// contains enough structure to justify forming a Map.
///
/// A Map is deliberately harder to form than a simple similarity result. It
/// needs at least three experiences connected by meaningful relationships.
class ResonanceMapFormationPolicy {
  static const int minimumExperiences = 3;
  static const int minimumMeaningfulConnections = 2;
  static const double minimumConnectionStrength = 0.6;
  static const double minimumCombinedScore = 1.2;

  const ResonanceMapFormationPolicy();

  ResonanceMapFormationDecision evaluate({
    required String experienceId,
    required List<ResonanceConnection> connections,
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
  }) {
    if (experienceId.trim().isEmpty) {
      return const ResonanceMapFormationDecision.ineligible(
        ResonanceMapFormationReason.invalidExperience,
      );
    }

    if (isPrivacyRestricted) {
      return const ResonanceMapFormationDecision.ineligible(
        ResonanceMapFormationReason.privacyRestricted,
      );
    }

    if (isSafetyRestricted) {
      return const ResonanceMapFormationDecision.ineligible(
        ResonanceMapFormationReason.safetyRestricted,
      );
    }

    final eligible = connections.where(_isEligible).toList(growable: false);
    final meaningful = eligible.where(_isMeaningful).toList(growable: false);

    final counterpartIds = meaningful
        .map((connection) => _counterpartId(connection, experienceId))
        .whereType<String>()
        .toSet();

    if (counterpartIds.length < minimumExperiences - 1) {
      return const ResonanceMapFormationDecision.ineligible(
        ResonanceMapFormationReason.insufficientExperiences,
      );
    }

    final voiceIds = _distinctVoiceIds(
      experienceId: experienceId,
      connections: meaningful,
    );
    if (voiceIds == null || voiceIds.length < minimumExperiences) {
      return const ResonanceMapFormationDecision.ineligible(
        ResonanceMapFormationReason.insufficientVoices,
      );
    }

    if (meaningful.length < minimumMeaningfulConnections) {
      return const ResonanceMapFormationDecision.ineligible(
        ResonanceMapFormationReason.insufficientConnections,
      );
    }

    final combinedScore = meaningful.fold<double>(
      0,
      (total, connection) => total + _score(connection),
    );

    if (combinedScore < minimumCombinedScore) {
      return const ResonanceMapFormationDecision.ineligible(
        ResonanceMapFormationReason.insufficientResonance,
      );
    }

    return ResonanceMapFormationDecision.eligible(
      experienceIds: [experienceId, ...counterpartIds],
      connections: meaningful,
    );
  }

  bool _isEligible(ResonanceConnection connection) {
    return (connection.state == ResonanceConnectionState.accepted ||
            connection.state == ResonanceConnectionState.active) &&
        connection.strength >= minimumConnectionStrength;
  }

  bool _isMeaningful(ResonanceConnection connection) {
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
      final counterpartId = _counterpartId(connection, experienceId);
      if (counterpartId == null) continue;

      final counterpartVoiceId = _counterpartVoiceId(
        connection,
        experienceId,
      );
      if (counterpartVoiceId == null || counterpartVoiceId.trim().isEmpty) {
        return null;
      }

      if (counterpartId == experienceId) {
        focalVoiceId ??= counterpartVoiceId;
      } else {
        counterpartVoiceIds.add(counterpartVoiceId);
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
    if (connection.sourceId == experienceId) return connection.targetId;
    if (connection.targetId == experienceId) return connection.sourceId;
    return null;
  }

  double _score(ResonanceConnection connection) {
    final typeWeight = switch (connection.type) {
      ResonanceConnectionType.sharedExperience => 1.0,
      ResonanceConnectionType.response => 0.95,
      ResonanceConnectionType.perspective => 0.85,
      ResonanceConnectionType.similarity => 0.0,
      ResonanceConnectionType.discovery => 0.0,
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

enum ResonanceMapFormationReason {
  invalidExperience,
  privacyRestricted,
  safetyRestricted,
  insufficientExperiences,
  insufficientVoices,
  insufficientConnections,
  insufficientResonance,
}

class ResonanceMapFormationDecision {
  final bool isEligible;
  final ResonanceMapFormationReason? reason;
  final List<String> experienceIds;
  final List<ResonanceConnection> connections;

  const ResonanceMapFormationDecision._({
    required this.isEligible,
    required this.reason,
    required this.experienceIds,
    required this.connections,
  });

  const ResonanceMapFormationDecision.eligible({
    required List<String> experienceIds,
    required List<ResonanceConnection> connections,
  }) : this._(
          isEligible: true,
          reason: null,
          experienceIds: experienceIds,
          connections: connections,
        );

  const ResonanceMapFormationDecision.ineligible(
    ResonanceMapFormationReason reason,
  ) : this._(
          isEligible: false,
          reason: reason,
          experienceIds: const [],
          connections: const [],
        );
}
