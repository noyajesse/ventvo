import '../models/resonance_connection.dart';
import '../models/resonance_conversation.dart';
import '../models/resonance_message.dart';
import '../repositories/resonance_conversation_repository.dart';

class ResonanceConversationService {
  final ResonanceConversationRepository repository;

  const ResonanceConversationService({required this.repository});

  Future<ResonanceConversation?> openForConnection({
    required ResonanceConnection connection,
    required String sourceVoiceMark,
    required String targetVoiceMark,
  }) async {
    if (connection.state != ResonanceConnectionState.active) return null;

    final existing = await repository.getConversation(connection.id);
    if (existing != null) return existing;

    final conversation = ResonanceConversation(
      id: 'conversation_${connection.id}',
      connectionId: connection.id,
      sourceExperienceId: connection.sourceId,
      targetExperienceId: connection.targetId,
      sourceVoiceMark: sourceVoiceMark,
      targetVoiceMark: targetVoiceMark,
      createdAt: DateTime.now(),
    );
    await repository.saveConversation(conversation);
    return conversation;
  }

  Future<List<ResonanceMessage>> getMessages(String conversationId) {
    return repository.getMessages(conversationId);
  }

  Future<ResonanceMessage?> sendMessage({
    required ResonanceConversation conversation,
    required String senderVoiceId,
    required String senderVoiceMark,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final message = ResonanceMessage(
      id: 'message_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversation.id,
      senderVoiceId: senderVoiceId,
      senderVoiceMark: senderVoiceMark,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    await repository.saveMessage(message);
    return message;
  }
}
