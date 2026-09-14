import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/services/resonance_connection_service.dart';
import '../../../systems/resonance/services/resonance_engine.dart';
import '../models/echo.dart';
import '../models/space.dart';
import 'echo_resonance_connection_service.dart';
import 'echo_resonance_link_service.dart';

/// Turns an explicit Echo in an Open Discussion Space into a response
/// Resonance connection.
///
/// This service owns the product-level orchestration. It does not expose
/// private identity and never permits Just Listen to create a relationship.
class EchoResponseResonanceService {
  final ResonanceEngine engine;
  final ResonanceConnectionService connectionService;
  final EchoResonanceConnectionService echoConnectionService;

  const EchoResponseResonanceService({
    required this.engine,
    required this.connectionService,
    required this.echoConnectionService,
  });

  Future<ResonanceConnection?> connectEcho({
    required Space space,
    required Echo echo,
    required String sourceExperienceId,
  }) async {
    if (!space.isOpenDiscussion) return null;
    if (echo.spaceId != space.id) return null;
    if (sourceExperienceId.trim().isEmpty) return null;

    final echoExperienceId = 'echo:${echo.id.trim()}';
    if (echoExperienceId == 'echo:') return null;

    final connection = await engine.createConnection(
      sourceId: sourceExperienceId.trim(),
      targetId: echoExperienceId,
      type: ResonanceConnectionType.response,
      strength: 1,
    );

    final activated = await connectionService.activate(connection);
    if (activated == null) return null;

    await echoConnectionService.resolveForEcho(echo);
    return activated;
  }
}
