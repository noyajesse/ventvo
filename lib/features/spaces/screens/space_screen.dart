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
          return Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.55),
                    radius: 1.15,
                    colors: [
                      VentvoColors.surfaceElevated.withValues(alpha: 0.9 * value),
                      VentvoColors.background,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: -100,
                child: _ambientGlow(220, 0.06 * value),
              ),
              Positioned(
                top: 300,
                right: -120,
                child: _ambientGlow(260, 0.045 * value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ambientGlow(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: VentvoColors.primary.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 2,
      left: 4,
      child: IconButton(
        tooltip: 'Leave Space',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.close,
          color: VentvoColors.textSecondary,
          size: 21,
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
            offset: Offset(0, 26 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildRoom(vent),
    );
  }

  Widget _buildRoom(Vent vent) {
    final isListening = widget.space.isJustListen;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 76, 24, 34),
            children: [
              _buildRoomHeader(isListening),
              const SizedBox(height: 48),
              _buildVentMoment(vent),
              const SizedBox(height: 42),
              _buildEnteringLine(isListening),
              const SizedBox(height: 36),
              if (isListening) _buildListeningGuidance() else _buildConversation(),
            ],
          ),
        ),
        _buildInteraction(),
      ],
    );
  }

  Widget _buildRoomHeader(bool isListening) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: VentvoColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: VentvoColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isListening ? Icons.headphones_outlined : Icons.forum_outlined,
                color: VentvoColors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                isListening ? 'JUST LISTEN' : 'OPEN DISCUSSION',
                style: const TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          isListening
              ? 'A quiet place to be heard'
              : 'A room for this conversation',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildVentMoment(Vent vent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      decoration: BoxDecoration(
        color: VentvoColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        children: [
          Text(
            vent.voiceMark,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            vent.content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 25,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnteringLine(bool isListening) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: VentvoColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            isListening ? 'YOU ARE HERE' : 'THE ROOM',
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: VentvoColors.border)),
      ],
    );
  }

  Widget _buildListeningGuidance() {
    return Column(
      children: [
        const Icon(
          Icons.graphic_eq_rounded,
          color: VentvoColors.textMuted,
          size: 28,
        ),
        const SizedBox(height: 18),
        const Text(
          'You don’t have to say anything.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VentvoColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'No advice. No fixing.\nJust presence.',
          textAlign: TextAlign.center,
          style: TextStyle(
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
        Row(
          children: [
            const Expanded(
              child: Text(
                'VOICES IN THE ROOM',
                style: TextStyle(
                  color: VentvoColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
            Text(
              '${responses.length} ${responses.length == 1 ? 'Voice' : 'Voices'}',
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (responses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: VentvoColors.surface.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VentvoColors.border),
            ),
            child: const Text(
              'The room is quiet.\nYou can be the first Voice to enter the conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          )
        else
          ...responses.map(_buildResponse),
      ],
    );
  }

  Widget _buildResponse(SpaceResponse response) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: VentvoColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 1,
                height: 62,
                color: VentvoColors.border,
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 17),
              decoration: BoxDecoration(
                color: VentvoColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: VentvoColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response.voiceMark,
                    style: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    response.content,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
        child: GestureDetector(
          onTap: markHeard,
          child: AnimatedContainer(
            duration: VentvoMotion.micro,
            curve: VentvoMotion.standard,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              color: heard ? VentvoColors.surfaceElevated : VentvoColors.surface,
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
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 14,
                ),
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
