import 'package:flutter/material.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_gathering_candidate.dart';
import '../models/resonance_map_experience.dart';

class ResonanceGatheringScreen extends StatefulWidget {
  final ResonanceGatheringCandidate candidate;
  final List<ResonanceMapExperience> experiences;

  const ResonanceGatheringScreen({
    super.key,
    required this.candidate,
    required this.experiences,
  });

  @override
  State<ResonanceGatheringScreen> createState() => _ResonanceGatheringScreenState();
}

class _ResonanceGatheringScreenState extends State<ResonanceGatheringScreen> {
  final _controller = TextEditingController();
  final _messages = <_GatheringMessage>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_GatheringMessage(voiceMark: 'You', text: text));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: const Text('Gathering'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              children: [
                const Text(
                  'A MOMENT TO MEET',
                  style: TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'These experiences found each other.',
                  style: TextStyle(
                    color: VentvoColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${widget.experiences.length} Voices are connected through this landscape. You can meet here without turning the connection into a permanent group.',
                  style: const TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 22),
                ...widget.experiences.map(
                  (experience) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                      decoration: BoxDecoration(
                        color: VentvoColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: VentvoColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            experience.voiceMark,
                            style: const TextStyle(
                              color: VentvoColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            experience.content,
                            style: const TextStyle(
                              color: VentvoColors.textPrimary,
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.experiences.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'The conversation starts from the experiences that brought this Gathering together. What happens next belongs to the Voices here.',
                    style: TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 11,
                      height: 1.55,
                    ),
                  ),
                ],
                if (_messages.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'CONVERSATION',
                    style: TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._messages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                        decoration: BoxDecoration(
                          color: VentvoColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: VentvoColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.voiceMark,
                              style: const TextStyle(
                                color: VentvoColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              message.text,
                              style: const TextStyle(
                                color: VentvoColors.textPrimary,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Say something…',
                        filled: true,
                        fillColor: VentvoColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: VentvoColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: VentvoColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: VentvoColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GatheringMessage {
  final String voiceMark;
  final String text;

  const _GatheringMessage({required this.voiceMark, required this.text});
}
