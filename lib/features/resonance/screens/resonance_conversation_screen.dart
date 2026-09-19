import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/models/resonance_conversation.dart';
import '../../../systems/resonance/models/resonance_message.dart';
import '../../../systems/resonance/providers/resonance_conversation_provider.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import 'resonance_relationship_screen.dart';

class ResonanceConversationScreen extends ConsumerStatefulWidget {
  final ResonanceCandidate candidate;
  final ResonanceConnection connection;

  const ResonanceConversationScreen({
    super.key,
    required this.candidate,
    required this.connection,
  });

  @override
  ConsumerState<ResonanceConversationScreen> createState() =>
      _ResonanceConversationScreenState();
}

class _ResonanceConversationScreenState
    extends ConsumerState<ResonanceConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<_ConversationView?> _conversationFuture;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _conversationFuture = _openConversation();
  }

  Future<_ConversationView?> _openConversation() async {
    if (widget.connection.state != ResonanceConnectionState.active) return null;

    final voice = await ref.read(ventvoVoiceProvider.future);
    final localVoiceId = voice?.voiceId;
    if (localVoiceId == null || localVoiceId.trim().isEmpty) return null;

    final conversation = await ref
        .read(resonanceConversationServiceProvider)
        .openForConnection(
          connection: widget.connection,
          sourceVoiceMark: voice?.mark ?? 'YOUR VOICE',
          targetVoiceMark: widget.candidate.voiceMark ?? 'OTHER VOICE',
        );
    if (conversation == null) return null;

    final messages = await ref
        .read(resonanceConversationServiceProvider)
        .getMessages(conversation.id);

    return _ConversationView(
      conversation: conversation,
      messages: messages,
      localVoiceId: localVoiceId,
    );
  }

  Future<void> _send() async {
    if (_sending) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final view = await _conversationFuture;
    if (view == null || !mounted) return;

    final voice = await ref.read(ventvoVoiceProvider.future);
    final senderVoiceId = voice?.voiceId;
    if (senderVoiceId == null || senderVoiceId.trim().isEmpty) return;

    setState(() => _sending = true);
    await ref.read(resonanceConversationServiceProvider).sendMessage(
          conversation: view.conversation,
          senderVoiceId: senderVoiceId,
          senderVoiceMark: voice?.mark ?? 'YOUR VOICE',
          text: text,
        );

    if (!mounted) return;
    _controller.clear();
    setState(() {
      _sending = false;
      _conversationFuture = _openConversation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: Text(widget.candidate.voiceMark ?? 'Connection'),
        actions: [
          IconButton(
            tooltip: 'Resonance details',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ResonanceRelationshipScreen(
                  candidate: widget.candidate,
                  connection: widget.connection,
                ),
              ),
            ),
            icon: const Icon(Icons.waves_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_ConversationView?>(
        future: _conversationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final view = snapshot.data;
          if (view == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'This conversation is not available yet. The Resonance must be active first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              _OriginContext(view: view),
              Expanded(
                child: view.messages.isEmpty
                    ? const _EmptyConversation()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                        itemCount: view.messages.length,
                        itemBuilder: (context, index) {
                          final message = view.messages[index];
                          return _MessageBubble(
                            message: message,
                            mine: message.senderVoiceId == view.localVoiceId,
                          );
                        },
                      ),
              ),
              _Composer(
                controller: _controller,
                sending: _sending,
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConversationView {
  final ResonanceConversation conversation;
  final List<ResonanceMessage> messages;
  final String localVoiceId;

  const _ConversationView({
    required this.conversation,
    required this.messages,
    required this.localVoiceId,
  });
}

class _OriginContext extends StatelessWidget {
  final _ConversationView view;

  const _OriginContext({required this.view});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 15),
      decoration: const BoxDecoration(
        color: VentvoColors.surface,
        border: Border(
          bottom: BorderSide(color: VentvoColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONNECTED THROUGH',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                view.conversation.sourceVoiceMark,
                style: const TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.waves_rounded,
                  size: 15,
                  color: VentvoColors.textMuted,
                ),
              ),
              Text(
                view.conversation.targetVoiceMark,
                style: const TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'This conversation began with a Resonance between experiences.',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'You both chose to continue the connection. Start the conversation when you are ready.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ResonanceMessage message;
  final bool mine;

  const _MessageBubble({
    required this.message,
    required this.mine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: mine ? VentvoColors.surfacePressed : VentvoColors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: VentvoColors.border),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderVoiceMark,
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: const BoxDecoration(
          color: VentvoColors.surface,
          border: Border(
            top: BorderSide(color: VentvoColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Write something...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
