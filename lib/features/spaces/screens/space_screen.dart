import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/ventvo_motion.dart';
import '../../../core/theme/ventvo_colors.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/space.dart';
import '../models/space_response.dart';
import '../services/space_response_storage.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final Space space;

  const SpaceScreen({super.key, required this.space});

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final SpaceResponseStorage _responseStorage = SpaceResponseStorage();
  late final AnimationController _entranceController;

  List<SpaceResponse> responses = [];
  bool loadingResponses = true;
  bool heard = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: VentvoMotion.immersive,
    )..forward();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final loaded = await _responseStorage.loadForSpace(widget.space.id);
    if (!mounted) return;
    setState(() {
      responses = loaded;
      loadingResponses = false;
    });
  }

  Future<void> addResponse() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final response = SpaceResponse(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      spaceId: widget.space.id,
      voiceMark: '◇ Voice',
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      responses = [...responses, response];
      controller.clear();
    });

    await _responseStorage.add(response);
  }

  void markHeard() {
    if (heard) return;
    setState(() => heard = true);
  }

  @override
  void dispose() {
    controller.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ventsAsync = ref.watch(ventProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(),
            Positioned.fill(
              child: ventsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: VentvoColors.primary),
                ),
                error: (_, _) => const Center(
                  child: Text(
                    'This moment could not be opened.',
                    style: TextStyle(color: VentvoColors.textSecondary),
                  ),
                ),
                data: (vents) {
                  final matchingVents = vents.where(
                    (item) => item.id == widget.space.originatingVentId,
                  );

                  if (matchingVents.isEmpty) {
                    return const Center(
                      child: Text(
                        'This Space is empty.',
                        style: TextStyle(color: VentvoColors.textMuted),
                      ),
                    );
                  }

                  return _buildAnimatedRoom(matchingVents.first);
                },
              ),
            ),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          final value = Curves.easeOut.transform(_entranceController.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.35),
                radius: 1.25,
                colors: [
                  VentvoColors.surfaceElevated.withValues(alpha: 0.95 * value),
                  VentvoColors.background,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 4,
      left: 6,
      child: IconButton(
        tooltip: 'Leave Space',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.close,
          color: VentvoColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildAnimatedRoom(Vent vent) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(_entranceController.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 32 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildRoom(vent),
    );
  }

  Widget _buildRoom(Vent vent) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(28, 82, 28, 40),
            children: [
              _buildRoomHeader(),
              const SizedBox(height: 62),
              _buildVentMoment(vent),
              const SizedBox(height: 58),
              _buildRoomDivider(),
              const SizedBox(height: 32),
              _buildRoomMessage(),
              if (widget.space.isOpenDiscussion) ...[
                const SizedBox(height: 48),
                _buildConversation(),
              ],
            ],
          ),
        ),
        _buildInteraction(),
      ],
    );
  }

  Widget _buildRoomHeader() {
    final isListening = widget.space.isJustListen;
    return Column(
      children: [
        Text(
          isListening ? 'JUST LISTEN' : 'OPEN DISCUSSION',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: VentvoColors.surface,
            border: Border.all(color: VentvoColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            isListening ? '🌊' : '💬',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isListening
              ? 'A quiet place to be heard'
              : 'A place to talk about this moment',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VentvoColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildVentMoment(Vent vent) {
    return Column(
      children: [
        Text(
          vent.voiceMark,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VentvoColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          vent.content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VentvoColors.textPrimary,
            fontSize: 27,
            height: 1.48,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomDivider() => Center(
        child: Container(width: 48, height: 1, color: VentvoColors.border),
      );

  Widget _buildRoomMessage() {
    final isListening = widget.space.isJustListen;
    return Column(
      children: [
        Text(
          isListening
              ? 'You don’t have to say anything.'
              : 'This moment is open to your perspective.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VentvoColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isListening
              ? 'No advice. No fixing.\nJust presence.'
              : 'Listen first. Then say what this moment brings up for you.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VentvoColors.textSecondary,
            fontSize: 14,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildConversation() {
    if (loadingResponses) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: VentvoColors.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE CONVERSATION',
          style: TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 18),
        if (responses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'You can be the first Voice to enter this conversation.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          )
        else
          ...responses.map(_buildResponse),
      ],
    );
  }

  Widget _buildResponse(SpaceResponse response) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              response.voiceMark,
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              response.content,
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteraction() {
    return widget.space.isJustListen
        ? _buildListeningInteraction()
        : _buildDiscussionInteraction();
  }

  Widget _buildListeningInteraction() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
        child: GestureDetector(
          onTap: markHeard,
          child: AnimatedContainer(
            duration: VentvoMotion.micro,
            curve: VentvoMotion.standard,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              color: heard
                  ? VentvoColors.surfaceElevated
                  : VentvoColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: heard
                    ? VentvoColors.success.withValues(alpha: 0.45)
                    : VentvoColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  heard
                      ? Icons.check_circle_outline
                      : Icons.headphones_outlined,
                  color: heard
                      ? VentvoColors.success
                      : VentvoColors.textSecondary,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Text(
                  heard ? 'You stayed. That’s enough.' : 'I’m here',
                  style: TextStyle(
                    color: heard
                        ? VentvoColors.textPrimary
                        : VentvoColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionInteraction() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: VentvoColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'What does this moment bring up for you?',
                  hintStyle: const TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: VentvoColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
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
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: addResponse,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: VentvoColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
