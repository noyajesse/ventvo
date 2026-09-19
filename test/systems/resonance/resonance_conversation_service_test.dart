import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/repositories/local_resonance_conversation_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_conversation_service.dart';

ResonanceConnection _activeConnection() {
  return ResonanceConnection(
    id: 'vent-1_vent-2',
    sourceId: 'vent-1',
    targetId: 'vent-2',
    type: ResonanceConnectionType.sharedExperience,
    strength: 0.82,
    state: ResonanceConnectionState.active,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('opens a conversation only for an active Resonance', () async {
    final service = ResonanceConversationService(
      repository: LocalResonanceConversationRepository(),
    );

    final conversation = await service.openForConnection(
      connection: _activeConnection(),
      sourceVoiceMark: 'VAELOR ◇',
      targetVoiceMark: 'NYVEN ∿',
    );

    expect(conversation, isNotNull);
    expect(conversation!.connectionId, 'vent-1_vent-2');
    expect(conversation.sourceVoiceMark, 'VAELOR ◇');
    expect(conversation.targetVoiceMark, 'NYVEN ∿');
  });

  test('does not open a conversation for an accepted but inactive connection', () async {
    final service = ResonanceConversationService(
      repository: LocalResonanceConversationRepository(),
    );

    final connection = _activeConnection().copyWith(
      state: ResonanceConnectionState.accepted,
    );

    final conversation = await service.openForConnection(
      connection: connection,
      sourceVoiceMark: 'VAELOR ◇',
      targetVoiceMark: 'NYVEN ∿',
    );

    expect(conversation, isNull);
  });

  test('sends and retrieves direct messages', () async {
    final service = ResonanceConversationService(
      repository: LocalResonanceConversationRepository(),
    );
    final conversation = await service.openForConnection(
      connection: _activeConnection(),
      sourceVoiceMark: 'VAELOR ◇',
      targetVoiceMark: 'NYVEN ∿',
    );

    final message = await service.sendMessage(
      conversation: conversation!,
      senderVoiceId: 'voice-1',
      senderVoiceMark: 'VAELOR ◇',
      text: 'I did not expect someone else to understand.',
    );

    expect(message, isNotNull);
    final messages = await service.getMessages(conversation.id);
    expect(messages, hasLength(1));
    expect(
      messages.single.text,
      'I did not expect someone else to understand.',
    );
  });

  test('ignores empty messages', () async {
    final service = ResonanceConversationService(
      repository: LocalResonanceConversationRepository(),
    );
    final conversation = await service.openForConnection(
      connection: _activeConnection(),
      sourceVoiceMark: 'VAELOR ◇',
      targetVoiceMark: 'NYVEN ∿',
    );

    final message = await service.sendMessage(
      conversation: conversation!,
      senderVoiceId: 'voice-1',
      senderVoiceMark: 'VAELOR ◇',
      text: '   ',
    );

    expect(message, isNull);
    expect(await service.getMessages(conversation.id), isEmpty);
  });
}
