/// Links an Echo to an existing Resonance connection.
///
/// The link is deliberately separate from Echo so the presentation model does
/// not need to know how Resonance connections are stored or created.
class EchoResonanceLink {
  final String echoId;
  final String connectionId;
  final DateTime createdAt;

  const EchoResonanceLink({
    required this.echoId,
    required this.connectionId,
    required this.createdAt,
  });
}
