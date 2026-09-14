import '../models/echo_resonance_link.dart';
import 'echo_resonance_link_storage.dart';

/// Application boundary for linking an Echo to an existing Resonance
/// connection.
///
/// This service never creates a Resonance connection. A connection must first
/// be created by the canonical Resonance connection system, then this service
/// records the relationship for the Echo.
class EchoResonanceLinkService {
  final EchoResonanceLinkStorage storage;

  const EchoResonanceLinkService({required this.storage});

  Future<EchoResonanceLink?> getForEcho(String echoId) {
    final normalizedEchoId = echoId.trim();
    if (normalizedEchoId.isEmpty) return Future.value(null);
    return storage.loadForEcho(normalizedEchoId);
  }

  Future<EchoResonanceLink?> linkEcho({
    required String echoId,
    required String connectionId,
  }) async {
    final normalizedEchoId = echoId.trim();
    final normalizedConnectionId = connectionId.trim();

    if (normalizedEchoId.isEmpty || normalizedConnectionId.isEmpty) {
      return null;
    }

    final link = EchoResonanceLink(
      echoId: normalizedEchoId,
      connectionId: normalizedConnectionId,
      createdAt: DateTime.now(),
    );

    await storage.save(link);
    return link;
  }
}
