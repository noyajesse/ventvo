import '../models/resonance_conversation.dart';
import '../models/resonance_message.dart';

abstract class ResonanceConversationRepository {
  Future<void> saveConversation(ResonanceConversation conversation);
  Future<ResonanceConversation?> getConversation(String connectionId);
  Future<void> saveMessage(ResonanceMessage message);
  Future<List<ResonanceMessage>> getMessages(String conversationId);
}
