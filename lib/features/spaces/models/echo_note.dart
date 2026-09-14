class EchoNote {
  final String id;
  final String echoId;
  final String spaceId;
  final String? ventId;
  final String voiceMark;
  final String content;
  final DateTime createdAt;

  const EchoNote({
    required this.id,
    required this.echoId,
    required this.spaceId,
    this.ventId,
    required this.voiceMark,
    required this.content,
    required this.createdAt,
  });
}
