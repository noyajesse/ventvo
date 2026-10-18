import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/crash_out_space_experience.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_space_provider.dart';

class CrashOutSpaceScreen extends ConsumerStatefulWidget {
  final HumanTension tension;
  final List<CrashOutSpaceExperience> experiences;
  final String? matchedExperienceId;

  const CrashOutSpaceScreen({
    super.key,
    required this.tension,
    required this.experiences,
    this.matchedExperienceId,
  });

  @override
  ConsumerState<CrashOutSpaceScreen> createState() =>
      _CrashOutSpaceScreenState();
}

class _CrashOutSpaceScreenState extends ConsumerState<CrashOutSpaceScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _replyingToExperienceId;
  String? _replyingToReplyId;

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
    final replyToId = _replyingToReplyId;
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
            replyToId: replyToId,
          ),
        );

    if (!mounted) return;
    _controller.clear();
    setState(() {
      _replyingToExperienceId = null;
      _replyingToReplyId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(crashOutSpaceProvider);
    final title = _spaceTitle(widget.tension);

    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101014),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Crash Out Space',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                children: [
                  Text(
                    'WHAT PEOPLE ARE CARRYING',
                    style: const TextStyle(
                      color: Color(0xFFC7B4F4),
                      fontSize: 10,
                      letterSpacing: 1.7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'There is not one way to live through this. Read what others are carrying, and reply when something speaks to you.',
                    style: TextStyle(
                      color: Color(0xFFB5B3BE),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1A24),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF393346)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: Color(0xFFC7B4F4),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prototype preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Sample experiences and replies are shown so you can explore the idea. They are fictional, not real user activity. Any reply you write is saved only on this device.',
                                style: TextStyle(
                                  color: Color(0xFFB5B3BE),
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 23),
                  Row(
                    children: [
                      const Text(
                        'Experiences',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF292633),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.experiences.length}',
                          style: const TextStyle(
                            color: Color(0xFFD9D1EA),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final experience in widget.experiences)
                    _ExperienceCard(
                      experience: experience,
                      replies: ref
                          .read(crashOutSpaceProvider.notifier)
                          .repliesFor(widget.tension.name, experience.id),
                      isMatched:
                          experience.id == widget.matchedExperienceId,
                      onReply: () => setState(() {
                        _replyingToExperienceId = experience.id;
                        _replyingToReplyId = null;
                      }),
                      onReplyToReply: (replyId) => setState(() {
                        _replyingToExperienceId = experience.id;
                        _replyingToReplyId = replyId;
                      }),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            if (_replyingToExperienceId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 9, 18, 5),
                color: const Color(0xFF19181F),
                child: Text(
                  _replyingToReplyId == null
                      ? 'Replying to ${_experienceName(_replyingToExperienceId!)}'
                      : 'Continuing a reply in ${_experienceName(_replyingToExperienceId!)}',
                  style: const TextStyle(
                    color: Color(0xFFC7B4F4),
                    fontSize: 12,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF17161C),
                border: Border(top: BorderSide(color: Color(0xFF302E37))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _replyingToExperienceId == null
                            ? 'Choose an experience to reply to'
                            : 'Write what you want to say...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF888591),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF24222B),
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
                    color: const Color(0xFF17161C),
                    disabledColor: const Color(0xFF777480),
                    style: IconButton.styleFrom(
                      backgroundColor: _hasText && _replyingToExperienceId != null
                          ? const Color(0xFFC7B4F4)
                          : const Color(0xFF302E37),
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

  String _spaceTitle(HumanTension tension) {
    switch (tension) {
      case HumanTension.connection:
        return 'People and closeness';
      case HumanTension.attention:
        return 'Being noticed';
      case HumanTension.dependence:
        return 'Asking for help';
      case HumanTension.explanation:
        return 'Being understood';
      case HumanTension.presence:
        return 'Staying and leaving';
      case HumanTension.responsibility:
        return 'Carrying too much';
      case HumanTension.recognition:
        return 'Being seen';
      case HumanTension.control:
        return 'Having a say';
      case HumanTension.belonging:
        return 'Finding your place';
      case HumanTension.vulnerability:
        return 'Letting someone in';
    }
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
}

class _ExperienceCard extends StatelessWidget {
  final CrashOutSpaceExperience experience;
  final List<CrashOutSpaceReply> replies;
  final bool isMatched;
  final VoidCallback onReply;
  final ValueChanged<String> onReplyToReply;

  const _ExperienceCard({
    required this.experience,
    required this.replies,
    required this.isMatched,
    required this.onReply,
    required this.onReplyToReply,
  });

  String _replyContext(CrashOutSpaceReply reply) {
    for (final candidate in replies) {
      if (candidate.id == reply.replyToId) {
        final name = candidate.voiceName?.trim();
        return 'In reply to ${name == null || name.isEmpty ? 'another Voice' : name}';
      }
    }
    return 'In reply to an earlier reply';
  }

  @override
  Widget build(BuildContext context) {
    final voiceName = experience.voiceName?.trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 14, 9),
      decoration: BoxDecoration(
        color: const Color(0xFF1A191F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMatched
              ? const Color(0xFF76658F)
              : const Color(0xFF302E37),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2836),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  experience.voiceMark.trim().isEmpty
                      ? '◇'
                      : experience.voiceMark.trim(),
                  style: const TextStyle(
                    color: Color(0xFFD5C7F2),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  voiceName == null || voiceName.isEmpty
                      ? 'Ventvo Voice'
                      : voiceName,
                  style: const TextStyle(
                    color: Color(0xFFCECBD5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isMatched)
                const Text(
                  'A DIFFERENT SIDE',
                  style: TextStyle(
                    color: Color(0xFFC7B4F4),
                    fontSize: 9,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            experience.content,
            style: const TextStyle(
              color: Color(0xFFF2F0F6),
              fontSize: 15,
              height: 1.55,
            ),
          ),
          if (replies.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFF302E37), height: 1),
            const SizedBox(height: 12),
            for (final reply in replies)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 2,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF76658F),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                  color: Color(0xFFAAA6B5),
                                  fontSize: 11,
                                ),
                              ),
                              if (reply.replyToId != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  _replyContext(reply),
                                  style: const TextStyle(
                                    color: Color(0xFF918C9F),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                reply.content,
                                style: const TextStyle(
                                  color: Color(0xFFD8D5DF),
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => onReplyToReply(reply.id),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFAAA6B5),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 28),
                        ),
                        child: const Text(
                          'Reply to this',
                          style: TextStyle(fontSize: 11),
                        ),
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
                foregroundColor: const Color(0xFFC7B4F4),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
