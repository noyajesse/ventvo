import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/services/echo_resonance_experience_service.dart';
import '../../../systems/resonance/services/resonance_engine.dart';
import '../models/echo.dart';
import 'echo_resonance_link_service.dart';

/// Resolves an Echo against the canonical Resonance connection graph.
///
/// This service never creates a connection. It only finds an existing
/// connection that explicitly includes the Echo's internal experience ID and
/// records the safe Echo-to-connection link.
class EchoResonanceConnectionService {
  final ResonanceEngine engine;
  final EchoResonanceLinkService linkService;
  final EchoResonanceExperienceService experienceService;

  const EchoResonanceConnectionService({
    required this.engine,
    required this.linkService,
    this.experienceService = const EchoResonanceExperienceService(),
  });

  Future<ResonanceConnection?> resolveForEcho(Echo echo) async {
    final experienceId = experienceService.experienceIdFor(echo);
    if (experienceId == null) return null;

    final connections = await engine.getConnectionsInvolving(experienceId);
    if (connections.isEmpty) return null;

    final connection = _selectConnection(connections, experienceId);
    if (connection == null) return null;

    await linkService.linkEcho(
      echoId: echo.id,
      connectionId: connection.id,
    );

    return connection;
  }

  ResonanceConnection? _selectConnection(
    List<ResonanceConnection> connections,
    String experienceId,
  ) {
    final eligible = connections.where(
      (connection) =>
          connection.sourceId == experienceId ||
          connection.targetId == experienceId,
    );

    for (final connection in eligible) {
      if (connection.type == ResonanceConnectionType.response &&
          (connection.state == ResonanceConnectionState.accepted ||
              connection.state == ResonanceConnectionState.active)) {
        return connection;
      }
    }

    for (final connection in eligible) {
      if (connection.state == ResonanceConnectionState.active) {
        return connection;
      }
    }

    for (final connection in eligible) {
      if (connection.state == ResonanceConnectionState.accepted) {
        return connection;
      }
    }

    return null;
  }
}
