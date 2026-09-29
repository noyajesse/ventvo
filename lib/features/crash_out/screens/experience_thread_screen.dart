import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/crash_out.dart';
import '../models/experience_thread.dart';
import '../providers/experience_thread_provider.dart';

class ExperienceThreadScreen extends ConsumerStatefulWidget {
  final CrashOut crashOut;
  final ExperienceThread thread;

  const ExperienceThreadScreen({
    super.key,
    required this.crashOut,
    required this.thread,
  });

  @override
  ConsumerState<ExperienceThreadScreen> createState() =>
      _ExperienceThreadScreenState();
}

class _ExperienceThreadScreenState
    extends ConsumerState<ExperienceThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _replyToId;

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final stored =
        ref.read(experienceThreadProvider).asData?.value ?? const [];
    final thread = stored.firstWhere(
      (item) => item.id == widget.thread.id,
      orElse: () => widget.thread,
    );
    final voice = ref.read(ventvoVoiceProvider).asData?.value;

    final now = DateTime.now();
    final contribution = ExperienceContribution(
      id: now.microsecondsSinceEpoch.toString(),
      threadId: thread.id,
      content: text,
      type: ExperienceContributionType.response,
      createdAt: now,
      replyToId: _replyToId,
      voiceName: voice?.name,
      voiceMark: voice?.mark,
    );

    await ref.read(experienceThreadProvider.notifier).addContribution(
          threadId: thread.id,
          contribution: contribution,
        );

    if (!mounted) return;
    _controller.clear();
    setState(() => _replyToId = null);
  }

  void _setReply(ExperienceContribution contribution) {
    setState(() => _replyToId = contribution.id);
  }

  @override
  Widget build(BuildContext context) {
    final stored =
        ref.watch(experienceThreadProvider).asData?.value ?? const [];
    final activeThread = stored.firstWhere(
      (item) => item.id == widget.thread.id,
      orElse: () => widget.thread,
    );

    ExperienceContribution? replyTarget;
    if (_replyToId != null) {
      for (final item in activeThread.contributions) {
        if (item.id == _replyToId) {
          replyTarget = item;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        elevation: 0,
        title: const Text(
          'Crash Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                itemCount: activeThread.contributions.length,
                itemBuilder: (context, index) {
                  final contribution = activeThread.contributions[index];
                  ExperienceContribution? repliedTo;

                  if (contribution.replyToId != null) {
                    for (final item in activeThread.contributions) {
                      if (item.id == contribution.replyToId) {
                        repliedTo = item;
                        break;
                      }
                    }
                  }

                  return _ConversationMessage(
                    contribution: contribution,
                    repliedTo: repliedTo,
                    onReply: () => _setReply(contribution),
                  );
                },
              ),
            ),
            if (replyTarget != null)
              _ReplyBar(
                contribution: replyTarget,
                onCancel: () => setState(() => _replyToId = null),
              ),
            _Composer(
              controller: _controller,
              enabled: _hasText,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationMessage extends StatelessWidget {
  const _ConversationMessage({
    required this.contribution,
    required this.repliedTo,
    required this.onReply,
  });

  final ExperienceContribution contribution;
  final ExperienceContribution? repliedTo;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final voiceName = contribution.voiceName?.trim();
    final mark = contribution.voiceMark?.trim();
    final identity = [
      if (mark != null && mark.isNotEmpty) mark,
      if (voiceName != null && voiceName.isNotEmpty) voiceName,
    ].join('  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onLongPress: onReply,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (repliedTo != null) ...[
                _ReplyPreview(contribution: repliedTo!),
                const SizedBox(height: 7),
              ],
              Row(
                children: [
                  if (identity.isNotEmpty)
                    Text(
                      identity,
                      style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _time(contribution.createdAt),
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                contribution.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: onReply,
                child: const Text(
                  'Reply',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.contribution});

  final ExperienceContribution contribution;

  @override
  Widget build(BuildContext context) {
    final name = contribution.voiceName?.trim();
    final mark = contribution.voiceMark?.trim();
    final identity = [
      if (mark != null && mark.isNotEmpty) mark,
      if (name != null && name.isNotEmpty) name,
    ].join('  ');

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.white24, width: 2),
        ),
      ),
      child: Text(
        '${identity.isEmpty ? 'Reply' : identity}  ·  ${contribution.content}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white30,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({
    required this.contribution,
    required this.onCancel,
  });

  final ExperienceContribution contribution;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final name = contribution.voiceName?.trim().isNotEmpty == true
        ? contribution.voiceName!.trim()
        : 'VOICE';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Replying to ${identity.isEmpty ? 'this message' : identity}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 17),
            color: Colors.white38,
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(
          top: BorderSide(color: Colors.white10),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Say something...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.055),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Send',
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.arrow_upward_rounded),
            color: Colors.white,
            disabledColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
