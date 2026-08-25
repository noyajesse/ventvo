import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/space.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final Space space;

  const SpaceScreen({
    super.key,
    required this.space,
  });

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen> {
  final TextEditingController controller = TextEditingController();

  final List<String> responses = [
    'I understand what you mean.',
    "You don't have to figure everything out at once.",
  ];

  bool isListening = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void startListening() {
    if (isListening) return;

    setState(() {
      isListening = true;
    });
  }

  void addEcho() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      responses.add(text);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ventsAsync = ref.watch(ventProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.space.modeLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ventsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, _) => const Center(
          child: Text(
            'Unable to load this Space.',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
        data: (vents) {
          final vent = vents
              .where(
                (item) => item.id == widget.space.originatingVentId,
              )
              .firstOrNull;

          if (vent == null) {
            return const Center(
              child: Text(
                'This Space is empty.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            );
          }

          return widget.space.isJustListen
              ? _buildJustListenSpace(context, vent)
              : _buildDiscussionSpace(context, vent);
        },
      ),
    );
  }

  Widget _buildJustListenSpace(
    BuildContext context,
    dynamic vent,
  ) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                28,
                30,
                28,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVoiceHeader(vent.voiceMark),
                  const SizedBox(height: 42),
                  _buildVentContent(vent.content),
                  const SizedBox(height: 52),
                  _buildSpaceLabel(
                    title: 'JUST LISTEN',
                    description:
                        'No advice. No fixing. Just presence.',
                  ),
                ],
              ),
            ),
          ),
          _buildListeningAction(),
        ],
      ),
    );
  }

  Widget _buildDiscussionSpace(
    BuildContext context,
    dynamic vent,
  ) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                28,
                30,
                28,
                24,
              ),
              children: [
                _buildVoiceHeader(vent.voiceMark),
                const SizedBox(height: 42),
                _buildVentContent(vent.content),
                const SizedBox(height: 52),
                _buildSpaceLabel(
                  title: 'OPEN DISCUSSION',
                  description:
                      'Share what this moment brings up for you.',
                ),
                const SizedBox(height: 38),
                _buildEchoes(),
              ],
            ),
          ),
          _buildEchoComposer(),
        ],
      ),
    );
  }

  Widget _buildVoiceHeader(String voiceMark) {
    return Row(
      children: [
        Text(
          '◇',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          voiceMark,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildVentContent(String content) {
    return Text(
      '“$content”',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildSpaceLabel({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildListeningAction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        28,
        12,
        28,
        28,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isListening
            ? _buildListeningConfirmation()
            : _buildListeningButton(),
      ),
    );
  }

  Widget _buildListeningButton() {
    return SizedBox(
      key: const ValueKey('listen-button'),
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: startListening,
        icon: const Icon(
          Icons.headphones_outlined,
          size: 20,
        ),
        label: const Text(
          "I'm listening",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildListeningConfirmation() {
    return Container(
      key: const ValueKey('listening-confirmation'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white70,
            size: 21,
          ),
          SizedBox(width: 10),
          Text(
            "You're here.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEchoes() {
    if (responses.isEmpty) {
      return const Text(
        'No Echoes yet.',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 14,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ECHOES',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 18),
        ...responses.map(
          (response) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                response,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEchoComposer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Share what this brings up...',
                hintStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: addEcho,
            tooltip: 'Send Echo',
            icon: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}