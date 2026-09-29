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

  Future<void> _continueExperience() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final current = ref.read(experienceThreadProvider).asData?.value;
    final thread = current?.firstWhere(
      (item) => item.id == widget.thread.id,
      orElse: () => widget.thread,
    );

    final replyToId = _replyToId ??
        (thread?.contributions.isNotEmpty == true
            ? thread!.contributions.last.id
            : null);

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
    _clearReplyTarget();
  }

  @override
  Widget build(BuildContext context) {
    final storedThreads =
        ref.watch(experienceThreadProvider).asData?.value ?? const [];
    var activeThread = widget.thread;

    for (final storedThread in storedThreads) {
      if (storedThread.id == widget.thread.id) {
        activeThread = storedThread;
        break;
      }
    }

    ExperienceContribution? replyTarget;
    if (_replyToId != null) {
      for (final contribution in activeThread.contributions) {
        if (contribution.id == _replyToId) {
          replyTarget = contribution;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Experience',
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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                itemCount: activeThread.contributions.length + 1,
                itemBuilder: (context, index) {
                  if (index == activeThread.contributions.length) {
                    return const _ContinuePrompt();
                  }

                  final contribution = activeThread.contributions[index];
                  final isFirst = index == 0;
                  final isLast = index ==
                      activeThread.contributions.length - 1;

                  return _ExperienceStep(
                    contribution: contribution,
                    isFirst: isFirst,
                    isLast: isLast,
                    isSelected: contribution.id == _replyToId,
                    onContinue: () => _selectReplyTarget(contribution),
                  );
                },
              ),
            ),
            if (replyTarget != null)
              _ReplyContext(
                contribution: replyTarget,
                onClear: _clearReplyTarget,
              ),
            _Composer(
              controller: _controller,
              enabled: _hasText,
              onSend: _continueExperience,
              isReplying: replyTarget != null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceStep extends StatelessWidget {
  const _ExperienceStep({
    required this.contribution,
    required this.isFirst,
    required this.isLast,
    required this.isSelected,
    required this.onContinue,
  });

  final ExperienceContribution contribution;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isOrigin =
        contribution.type == ExperienceContributionType.origin;
    final isOpposite =
        contribution.type == ExperienceContributionType.opposite;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                _TimelineDot(isOrigin: isOrigin, isOpposite: isOpposite),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 74,
                    margin: const EdgeInsets.only(top: 6),
                    color: Colors.white12,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : 2,
                bottom: isLast ? 24 : 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOrigin)
                    const _StepLabel('WHAT YOU LET OUT')
                  else if (isOpposite)
                    const _StepLabel('ANOTHER SIDE')
                  else if (contribution.type ==
                      ExperienceContributionType.related)
                    const _StepLabel('ANOTHER EXPERIENCE')
                  else
                    const _StepLabel('AN EXPERIENCE'),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.09)
                          : isOrigin
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 
                          isOrigin ? 0.12 : 0.08,
                        ),
                      ),
                    ),
                    child: Text(
                      contribution.content,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontSize: 17,
                        height: 1.55,
                        fontWeight:
                            isOrigin ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  TextButton(
                    onPressed: onContinue,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isSelected
                          ? 'Continuing from this experience'
                          : 'Continue from this experience',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: isSelected ? 0.62 : 0.32,
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 13),
                    Text(
                      isOrigin
                          ? 'Then another experience appeared.'
                          : 'And the experience continues.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.30),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({
    required this.isOrigin,
    required this.isOpposite,
  });

  final bool isOrigin;
  final bool isOpposite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOrigin
            ? Colors.white
            : isOpposite
                ? Colors.white70
                : Colors.white38,
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ContinuePrompt extends StatelessWidget {
  const _ContinuePrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 2, bottom: 18),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Your experience can continue here.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.36),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyContext extends StatelessWidget {
  const _ReplyContext({
    required this.contribution,
    required this.onClear,
  });

  final ExperienceContribution contribution;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 9, 12, 9),
      decoration: const BoxDecoration(
        color: Color(0xFF171717),
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Continuing from: “' + contribution.content + '”',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
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
    required this.isReplying,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  final bool isReplying;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
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
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: isReplying
                    ? 'What does this experience bring up for you?'
                    : 'Add your experience...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.055),
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
            tooltip: 'Continue',
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
