class ResonanceMessage {
  final String id;
  final String conversationId;
  final String senderVoiceId;
  final String senderVoiceMark;
  final String text;
  final DateTime createdAt;

  const ResonanceMessage({
    required this.id,
    required this.conversationId,
    required this.senderVoiceId,
    required this.senderVoiceMark,
    required this.text,
    required this.createdAt,
  });
}
