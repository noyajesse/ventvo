import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> _reply() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final current = ref.read(experienceThreadProvider).asData?.value;
    final thread = current?.firstWhere(
      (item) => item.id == widget.thread.id,
      orElse: () => widget.thread,
    );

    final replyToId = thread?.contributions.isNotEmpty == true
        ? thread!.contributions.last.id
        : null;

    final contribution = ExperienceContribution(
      id: now.microsecondsSinceEpoch.toString(),
      threadId: widget.thread.id,
      content: text,
      type: ExperienceContributionType.response,
      createdAt: now,
      replyToId: replyToId,
    );

    await ref.read(experienceThreadProvider.notifier).addContribution(
          threadId: widget.thread.id,
          contribution: contribution,
        );

    if (!mounted) return;
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(experienceThreadProvider).asData?.value
        .where((item) => item.id == widget.thread.id)
        .firstOrNull;

    final activeThread = thread ?? widget.thread;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Crash Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                itemCount: activeThread.contributions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final contribution = activeThread.contributions[index];
                  final isMine =
                      contribution.type == ExperienceContributionType.origin ||
                      contribution.type == ExperienceContributionType.response;

                  return _ExperienceBubble(
                    contribution: contribution,
                    isMine: isMine,
                  );
                },
              ),
            ),
            _Composer(
              controller: _controller,
              enabled: _hasText,
              onSend: _reply,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceBubble extends StatelessWidget {
  const _ExperienceBubble({
    required this.contribution,
    required this.isMine,
  });

  final ExperienceContribution contribution;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: isMine ? Colors.white12 : Colors.white10,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMine ? 20 : 5),
              bottomRight: Radius.circular(isMine ? 5 : 20),
            ),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            contribution.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
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
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Respond with your experience...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
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
