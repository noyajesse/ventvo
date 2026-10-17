import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out_space_experience.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_space_provider.dart';
import '../services/crash_out_experience_interpreter.dart';

class CrashOutSpaceScreen extends ConsumerStatefulWidget {
  final HumanTension tension;
  final List<CrashOutSpaceExperience> experiences;
  final String matchedExperienceId;

  const CrashOutSpaceScreen({
    super.key,
    required this.tension,
    required this.experiences,
    required this.matchedExperienceId,
  });

  @override
  ConsumerState<CrashOutSpaceScreen> createState() =>
      _CrashOutSpaceScreenState();
}

class _CrashOutSpaceScreenState extends ConsumerState<CrashOutSpaceScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _replyingToExperienceId;

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

  Future<void> _sendReply() async {
    final experienceId = _replyingToExperienceId;
    final content = _controller.text.trim();
    if (experienceId == null || content.isEmpty) return;

    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    final now = DateTime.now();
    await ref.read(crashOutSpaceProvider.notifier).addReply(
          spaceId: widget.tension.name,
          experienceId: experienceId,
          reply: CrashOutSpaceReply(
            id: 'space_reply_${now.microsecondsSinceEpoch}',
            experienceId: experienceId,
            content: content,
            createdAt: now,
            voiceName: voice?.name,
            voiceMark: voice?.mark,
          ),
        );

    if (!mounted) return;
    _controller.clear();
    setState(() => _replyingToExperienceId = null);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(crashOutSpaceProvider);
    final title = widget.tension.label[0].toUpperCase() +
        widget.tension.label.substring(1);

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        title: const Text(
          'Crash Out Space',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Different experiences. Opposing sides. One place to understand what is underneath them.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.forum_outlined,
                          color: Colors.white38, size: 16),
                      const SizedBox(width: 7),
                      Text(
                        '${widget.experiences.length} experiences',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                itemCount: widget.experiences.length,
                itemBuilder: (context, index) {
                  final experience = widget.experiences[index];
                  final replies = ref
                      .read(crashOutSpaceProvider.notifier)
                      .repliesFor(widget.tension.name, experience.id);
                  final isMatched =
                      experience.id == widget.matchedExperienceId;
                  final direction = _directionFor(experience.content);
                  return _ExperienceCard(
                    experience: experience,
                    replies: replies,
                    isMatched: isMatched,
                    direction: direction,
                    onReply: () => setState(
                      () => _replyingToExperienceId = experience.id,
                    ),
                  );
                },
              ),
            ),
            if (_replyingToExperienceId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 5),
                color: const Color(0xFF171717),
                child: Text(
                  'Replying to ${_experienceName(_replyingToExperienceId!)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
              decoration: const BoxDecoration(
                color: Color(0xFF151515),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: _replyingToExperienceId == null
                            ? 'Choose an experience to reply to'
                            : 'Write your reply...',
                        hintStyle:
                            const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        _hasText && _replyingToExperienceId != null
                            ? _sendReply
                            : null,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    color: Colors.white,
                    disabledColor: Colors.white24,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _experienceName(String id) {
    for (final experience in widget.experiences) {
      if (experience.id == id) {
        final name = experience.voiceName?.trim();
        return name == null || name.isEmpty ? 'this experience' : name;
      }
    }
    return 'this experience';
  }

  String _directionFor(String content) {
    final representation =
        const CrashOutExperienceInterpreter().interpretText(content);
    for (final atom in representation.atoms) {
      if (atom.tension == widget.tension) {
        return atom.direction == ExperienceDirection.toward
            ? 'Moving toward'
            : 'Moving away';
      }
    }
    return 'Another perspective';
  }
}

class _ExperienceCard extends StatelessWidget {
  final CrashOutSpaceExperience experience;
  final List<CrashOutSpaceReply> replies;
  final bool isMatched;
  final String direction;
  final VoidCallback onReply;

  const _ExperienceCard({
    required this.experience,
    required this.replies,
    required this.isMatched,
    required this.direction,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final voiceName = experience.voiceName?.trim();
    final identity = [
      if (experience.voiceMark.trim().isNotEmpty) experience.voiceMark.trim(),
      if (voiceName != null && voiceName.isNotEmpty) voiceName,
    ].join('  ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isMatched ? const Color(0xFF202020) : const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMatched ? Colors.white24 : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  identity.isEmpty ? 'Ventvo Voice' : identity,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isMatched)
                const Text(
                  'THE OTHER SIDE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            direction,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Text(
            experience.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              height: 1.5,
            ),
          ),
          if (replies.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 11),
            for (final reply in replies)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 8),
                      child: Icon(Icons.subdirectory_arrow_right,
                          size: 14, color: Colors.white30),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            [
                              if (reply.voiceMark?.isNotEmpty ?? false)
                                reply.voiceMark!,
                              if (reply.voiceName?.isNotEmpty ?? false)
                                reply.voiceName!,
                            ].join('  ').isEmpty
                                ? 'Ventvo Voice'
                                : [
                                    if (reply.voiceMark?.isNotEmpty ?? false)
                                      reply.voiceMark!,
                                    if (reply.voiceName?.isNotEmpty ?? false)
                                      reply.voiceName!,
                                  ].join('  '),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            reply.content,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReply,
              icon: const Icon(Icons.reply_rounded, size: 16),
              label: const Text('Reply'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white60,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
