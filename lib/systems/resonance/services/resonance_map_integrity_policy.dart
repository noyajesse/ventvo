import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';

enum ResonanceMapIntegrityStatus {
  active,
  dormant,
  restricted,
  invalid,
}

class ResonanceMapIntegrityDecision {
  final ResonanceMapIntegrityStatus status;
  final List<ResonanceConnection> liveConnections;
  final List<ResonanceConnection> closedConnections;
  final List<ResonanceConnection> blockedConnections;

  const ResonanceMapIntegrityDecision({
    required this.status,
    required this.liveConnections,
    required this.closedConnections,
    required this.blockedConnections,
  });

  bool get isDiscoverable => status == ResonanceMapIntegrityStatus.active;
  bool get isDormant => status == ResonanceMapIntegrityStatus.dormant;
  bool get isRestricted => status == ResonanceMapIntegrityStatus.restricted;
  bool get isInvalid => status == ResonanceMapIntegrityStatus.invalid;
}

/// Determines whether a Resonance Map still represents meaningful structure.
///
/// Maps describe relationship graphs, not every historical or incidental
/// connection. Similarity can support discovery but cannot keep a Map active
/// on its own. Discovery links are never structural Map relationships.
class ResonanceMapIntegrityPolicy {
  static const double minimumConnectionStrength = 0.6;

  const ResonanceMapIntegrityPolicy();

  ResonanceMapIntegrityDecision evaluate(ResonanceMap map) {
    if (map.id.trim().isEmpty || map.experienceIds.length < 3) {
      return _invalid();
    }

    final experienceIds = map.experienceIds.toSet();
    final live = <ResonanceConnection>[];
    final closed = <ResonanceConnection>[];
    final blocked = <ResonanceConnection>[];

    for (final connection in map.connections) {
      if (connection.sourceId == connection.targetId ||
          !experienceIds.contains(connection.sourceId) ||
          !experienceIds.contains(connection.targetId)) {
        return _invalid();
      }

      switch (connection.state) {
        case ResonanceConnectionState.blocked:
          blocked.add(connection);
        case ResonanceConnectionState.closed:
          closed.add(connection);
        case ResonanceConnectionState.accepted:
        case ResonanceConnectionState.active:
          if (_isMeaningful(connection) &&
              connection.strength >= minimumConnectionStrength) {
            live.add(connection);
          }
        case ResonanceConnectionState.suggested:
          break;
      }
    }

    if (live.isNotEmpty) {
      return ResonanceMapIntegrityDecision(
        status: ResonanceMapIntegrityStatus.active,
        liveConnections: List.unmodifiable(live),
        closedConnections: List.unmodifiable(closed),
        blockedConnections: List.unmodifiable(blocked),
      );
    }

    if (blocked.isNotEmpty) {
      return ResonanceMapIntegrityDecision(
        status: ResonanceMapIntegrityStatus.restricted,
        liveConnections: const [],
        closedConnections: List.unmodifiable(closed),
        blockedConnections: List.unmodifiable(blocked),
      );
    }

    return ResonanceMapIntegrityDecision(
      status: ResonanceMapIntegrityStatus.dormant,
      liveConnections: const [],
      closedConnections: List.unmodifiable(closed),
      blockedConnections: const [],
    );
  }

  bool _isMeaningful(ResonanceConnection connection) {
    switch (connection.type) {
      case ResonanceConnectionType.sharedExperience:
      case ResonanceConnectionType.response:
      case ResonanceConnectionType.perspective:
        return true;
      case ResonanceConnectionType.similarity:
      case ResonanceConnectionType.discovery:
        return false;
    }
  }

  ResonanceMapIntegrityDecision _invalid() {
    return const ResonanceMapIntegrityDecision(
      status: ResonanceMapIntegrityStatus.invalid,
      liveConnections: [],
      closedConnections: [],
      blockedConnections: [],
    );
  }
}
