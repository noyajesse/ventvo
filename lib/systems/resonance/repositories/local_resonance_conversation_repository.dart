import '../models/resonance_conversation.dart';
import '../models/resonance_message.dart';
import 'resonance_conversation_repository.dart';

class LocalResonanceConversationRepository
    implements ResonanceConversationRepository {
  final Map<String, ResonanceConversation> _conversations = {};
  final Map<String, List<ResonanceMessage>> _messages = {};

  @override
  Future<void> saveConversation(ResonanceConversation conversation) async {
    _conversations[conversation.connectionId] = conversation;
  }

  @override
  Future<ResonanceConversation?> getConversation(String connectionId) async {
    return _conversations[connectionId];
  }

  @override
  Future<void> saveMessage(ResonanceMessage message) async {
    _messages.putIfAbsent(message.conversationId, () => []).add(message);
  }

  @override
  Future<List<ResonanceMessage>> getMessages(String conversationId) async {
    return List<ResonanceMessage>.unmodifiable(
      _messages[conversationId] ?? const [],
    );
  }
}
