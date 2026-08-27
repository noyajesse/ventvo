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
  final controller = TextEditingController();
  final responseStorage = SpaceResponseStorage();
  late final AnimationController entrance;

  List<SpaceResponse> responses = [];
  bool loadingResponses = true;
  bool heard = false;

  @override
  void initState() {
    super.initState();
    entrance = AnimationController(
      vsync: this,
      duration: VentvoMotion.immersive,
    )..forward();
    loadResponses();
  }

  Future<void> loadResponses() async {
    final value = await responseStorage.loadForSpace(widget.space.id);
    if (!mounted) return;
    setState(() {
      responses = value;
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
    await responseStorage.add(response);
  }

  @override
  void dispose() {
    controller.dispose();
    entrance.dispose();
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
            const _SpaceAtmosphere(),
            Positioned.fill(
              child: ventsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: VentvoColors.primary),
                ),
                error: (_, _) => const Center(
                  child: Text(
                    'This Space could not be opened.',
                    style: TextStyle(color: VentvoColors.textSecondary),
                  ),
                ),
                data: (vents) => _buildSpace(vents),
              ),
            ),
            Positioned(
              top: 2,
              left: 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: VentvoColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpace(List<Vent> vents) {
    final ids = widget.space.allVentIds.toSet();
    final spaceVents = vents.where((vent) {
      return ids.contains(vent.id) || vent.spaceId == widget.space.id;
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (spaceVents.isEmpty) {
      return const Center(
        child: Text('This Space is empty.', style: TextStyle(color: VentvoColors.textMuted)),
      );
    }

    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(entrance.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 70, 22, 30),
              children: [
                _buildHeader(spaceVents.length),
                const SizedBox(height: 40),
                ..._buildMoments(spaceVents),
              ],
            ),
          ),
          _buildInteraction(),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    final listening = widget.space.isJustListen;
    return Column(
      children: [
        Icon(
          listening ? Icons.headphones_outlined : Icons.forum_outlined,
          color: VentvoColors.textMuted,
          size: 22,
        ),
        const SizedBox(height: 12),
        Text(
          listening ? 'JUST LISTEN' : 'OPEN DISCUSSION',
          style: const TextStyle(
            color: VentvoColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          listening ? 'A space to simply be heard.' : 'A space for this moment.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 7),
        Text(
          '$count ${count == 1 ? 'moment' : 'moments'}',
          style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  List<Widget> _buildMoments(List<Vent> vents) {
    final result = <Widget>[];
    for (var i = 0; i < vents.length; i++) {
      result.add(_buildMoment(vents[i], i == 0));
      if (i < vents.length - 1) result.add(_buildConnection());
    }

    result.add(const SizedBox(height: 34));
    result.add(
      widget.space.isJustListen ? _buildListeningNote() : _buildResponses(),
    );
    return result;
  }

  Widget _buildMoment(Vent vent, bool origin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 20, 21, 24),
      decoration: BoxDecoration(
        color: origin ? VentvoColors.surfaceElevated : VentvoColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: origin ? VentvoColors.primary.withValues(alpha: 0.28) : VentvoColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                vent.voiceMark,
                style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              if (origin)
                const Text(
                  'FIRST MOMENT',
                  style: TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            vent.content,
            style: TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: origin ? 23 : 18,
              height: 1.48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: VentvoColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: VentvoColors.border)),
          const SizedBox(width: 10),
          const Text(
            'CONTINUING',
            style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, letterSpacing: 1.4),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildResponses() {
    if (loadingResponses) {
      return const Center(child: CircularProgressIndicator(color: VentvoColors.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VOICES IN THE SPACE',
          style: TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        if (responses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: VentvoColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VentvoColors.border),
            ),
            child: const Text(
              'The Space is quiet.\nYou can be the first Voice to enter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VentvoColors.textSecondary, fontSize: 14, height: 1.5),
            ),
          )
        else
          ...responses.map(
            (response) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(17, 15, 17, 17),
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: VentvoColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.voiceMark,
                      style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      response.content,
                      style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListeningNote() {
    return const Column(
      children: [
        Icon(Icons.graphic_eq_rounded, color: VentvoColors.textMuted, size: 27),
        SizedBox(height: 15),
        Text(
          'Nothing is expected from you.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VentvoColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          'You can stay here without fixing, advising,\nor finding the right words.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VentvoColors.textSecondary, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildInteraction() {
    if (widget.space.isJustListen) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
          child: GestureDetector(
            onTap: () => setState(() => heard = true),
            child: AnimatedContainer(
              duration: VentvoMotion.micro,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                color: VentvoColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: VentvoColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    heard ? Icons.check_circle_outline : Icons.headphones_outlined,
                    color: heard ? VentvoColors.success : VentvoColors.textSecondary,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    heard ? 'You stayed. That’s enough.' : 'I’m here',
                    style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Bring something into the room...',
                  hintStyle: const TextStyle(color: VentvoColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: VentvoColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceAtmosphere extends StatelessWidget {
  const _SpaceAtmosphere();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.25,
            colors: [VentvoColors.surfaceElevated, VentvoColors.background],
          ),
        ),
      ),
    );
  }
}
