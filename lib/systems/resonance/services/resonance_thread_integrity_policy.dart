import '../models/resonance_connection.dart';
import '../models/resonance_thread.dart';

enum ResonanceThreadIntegrityStatus {
  active,
  dormant,
  restricted,
  invalid,
}

class ResonanceThreadIntegrityDecision {
  final ResonanceThreadIntegrityStatus status;
  final List<ResonanceConnection> liveConnections;
  final List<ResonanceConnection> closedConnections;
  final List<ResonanceConnection> blockedConnections;

  const ResonanceThreadIntegrityDecision({
    required this.status,
    required this.liveConnections,
    required this.closedConnections,
    required this.blockedConnections,
  });

  bool get isDiscoverable => status == ResonanceThreadIntegrityStatus.active;

  bool get isDormant => status == ResonanceThreadIntegrityStatus.dormant;

  bool get isRestricted =>
      status == ResonanceThreadIntegrityStatus.restricted;

  bool get isInvalid => status == ResonanceThreadIntegrityStatus.invalid;
}

/// Determines whether a Thread remains structurally and meaningfully alive
/// after its connections change state.
///
/// Connection history is preserved. Closing or blocking one connection does
/// not delete the Thread. Instead, current discoverability is derived from
/// the connections that are still live and safe to surface.
class ResonanceThreadIntegrityPolicy {
  static const double minimumMeaningfulStrength = 0.6;

  const ResonanceThreadIntegrityPolicy();

  ResonanceThreadIntegrityDecision evaluate(ResonanceThread thread) {
    final experienceIds = thread.experienceIds.toSet();
    final liveConnections = <ResonanceConnection>[];
    final closedConnections = <ResonanceConnection>[];
    final blockedConnections = <ResonanceConnection>[];

    for (final connection in thread.connections) {
      if (!experienceIds.contains(connection.sourceId) ||
          !experienceIds.contains(connection.targetId) ||
          connection.sourceId == connection.targetId) {
        return const ResonanceThreadIntegrityDecision(
          status: ResonanceThreadIntegrityStatus.invalid,
          liveConnections: [],
          closedConnections: [],
          blockedConnections: [],
        );
      }

      switch (connection.state) {
        case ResonanceConnectionState.accepted:
        case ResonanceConnectionState.active:
          if (_isMeaningful(connection)) {
            liveConnections.add(connection);
          }
        case ResonanceConnectionState.closed:
          closedConnections.add(connection);
        case ResonanceConnectionState.blocked:
          blockedConnections.add(connection);
        case ResonanceConnectionState.suggested:
          // Suggested connections do not keep a Thread alive. A formed
          // Thread is based on accepted/active relationships only.
          break;
      }
    }

    final status = liveConnections.isNotEmpty
        ? ResonanceThreadIntegrityStatus.active
        : blockedConnections.isNotEmpty
            ? ResonanceThreadIntegrityStatus.restricted
            : ResonanceThreadIntegrityStatus.dormant;

    return ResonanceThreadIntegrityDecision(
      status: status,
      liveConnections: List.unmodifiable(liveConnections),
      closedConnections: List.unmodifiable(closedConnections),
      blockedConnections: List.unmodifiable(blockedConnections),
    );
  }

  bool _isMeaningful(ResonanceConnection connection) {
    if (connection.strength < minimumMeaningfulStrength) {
      return false;
    }

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
}
