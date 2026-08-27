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

  static Route<void> route(Space space) => PageRouteBuilder<void>(
        transitionDuration: VentvoMotion.immersive,
        reverseTransitionDuration: VentvoMotion.immersive,
        pageBuilder: (_, __, ___) => SpaceScreen(space: space),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .025),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      );

  static Future<void> open(BuildContext context, Space space) =>
      Navigator.of(context).push(route(space));

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen>
    with SingleTickerProviderStateMixin {
  final responseStorage = SpaceResponseStorage();
  final responseController = TextEditingController();
  late final AnimationController entrance;

  List<SpaceResponse> responses = [];
  bool loadingResponses = true;
  bool isHere = false;

  @override
  void initState() {
    super.initState();
    entrance = AnimationController(
      vsync: this,
      duration: VentvoMotion.immersive,
    )..forward();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final loaded = await responseStorage.loadForSpace(widget.space.id);
    if (!mounted) return;
    setState(() {
      responses = loaded;
      loadingResponses = false;
    });
  }

  Future<void> _addResponse() async {
    final text = responseController.text.trim();
    if (text.isEmpty) return;

    final response = SpaceResponse(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      spaceId: widget.space.id,
      ventId: widget.space.originatingVentId,
      voiceMark: '◇ Voice',
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      responses = [...responses, response];
      responseController.clear();
    });
    await responseStorage.add(response);
  }

  @override
  void dispose() {
    responseController.dispose();
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
            const _SpaceBackdrop(),
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
                data: _buildSpace,
              ),
            ),
            Positioned(
              top: 4,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: VentvoColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpace(List<Vent> allVents) {
    final ids = widget.space.allVentIds.toSet();
    final moments = allVents.where((vent) {
      return ids.contains(vent.id) || vent.spaceId == widget.space.id;
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final originIndex = moments.indexWhere(
      (vent) => vent.id == widget.space.originatingVentId,
    );
    if (originIndex > 0) {
      final origin = moments.removeAt(originIndex);
      moments.insert(0, origin);
    }

    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(entrance.value);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - progress)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 78, 24, 34),
              children: [
                _buildIdentity(moments.length),
                const SizedBox(height: 48),
                if (moments.isEmpty)
                  _buildEmptyOrigin()
                else
                  _buildOriginMoment(moments.first),
                if (moments.length > 1) ...[
                  const SizedBox(height: 36),
                  _buildGrowingLabel(),
                  const SizedBox(height: 22),
                  ...moments.skip(1).map(_buildMoment),
                ],
                const SizedBox(height: 38),
                _buildVoices(),
              ],
            ),
          ),
          _buildContribution(),
        ],
      ),
    );
  }

  Widget _buildIdentity(int count) {
    final listening = widget.space.isJustListen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: listening ? VentvoColors.textMuted : VentvoColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              listening ? 'A QUIET SPACE' : 'A SPACE TO UNFOLD',
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          listening
              ? 'Nothing needs to be solved here.'
              : 'This thought has somewhere to go.',
          style: const TextStyle(
            color: VentvoColors.textPrimary,
            fontSize: 27,
            height: 1.18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$count ${count == 1 ? 'moment' : 'moments'} connected here',
          style: const TextStyle(
            color: VentvoColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildOriginMoment(Vent vent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHERE IT STARTED',
          style: TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 21, 22, 26),
          decoration: BoxDecoration(
            color: VentvoColors.surfaceElevated,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: VentvoColors.primary.withValues(alpha: .24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vent.voiceMark,
                style: const TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                vent.content,
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 23,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrigin() => const Text(
        'The moment that opened this Space is no longer here.',
        style: TextStyle(
          color: VentvoColors.textSecondary,
          fontSize: 16,
          height: 1.5,
        ),
      );

  Widget _buildGrowingLabel() => const Row(
        children: [
          Expanded(child: Divider(color: VentvoColors.border, height: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 13),
            child: Text(
              'THEN IT GREW',
              style: TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: VentvoColors.border, height: 1)),
        ],
      );

  Widget _buildMoment(Vent vent) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 7,
                height: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: VentvoColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 19),
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: VentvoColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vent.voiceMark,
                      style: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      vent.content,
                      style: const TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 17,
                        height: 1.48,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildVoices() {
    if (widget.space.isJustListen) {
      return const Column(
        children: [
          Icon(Icons.headphones_outlined, color: VentvoColors.textMuted, size: 25),
          SizedBox(height: 14),
          Text(
            'You don’t have to add anything.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Being here is the response.',
            textAlign: TextAlign.center,
            style: TextStyle(color: VentvoColors.textSecondary, fontSize: 13),
          ),
        ],
      );
    }

    if (loadingResponses) {
      return const Center(
        child: CircularProgressIndicator(color: VentvoColors.primary),
      );
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
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 17),
        if (responses.isEmpty)
          const Text(
            'No one has added their voice yet. There is room for yours.',
            style: TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          )
        else
          ...responses.map(_buildVoice),
      ],
    );
  }

  Widget _buildVoice(SpaceResponse response) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '◇',
              style: TextStyle(color: VentvoColors.textMuted, fontSize: 17),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response.voiceMark,
                    style: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
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
          ],
        ),
      );

  Widget _buildContribution() {
    if (widget.space.isJustListen) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 7, 24, 17),
          child: GestureDetector(
            onTap: () => setState(() => isHere = true),
            child: AnimatedContainer(
              duration: VentvoMotion.micro,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: VentvoColors.surface,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: VentvoColors.border),
              ),
              child: Text(
                isHere ? 'You’re here. That’s enough.' : 'I’m here',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 7, 18, 15),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: responseController,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'What did this moment bring up?',
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
              onTap: _addResponse,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: VentvoColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
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

class _SpaceBackdrop extends StatelessWidget {
  const _SpaceBackdrop();

  @override
  Widget build(BuildContext context) => const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -.75),
              radius: 1.25,
              colors: [VentvoColors.surfaceElevated, VentvoColors.background],
            ),
          ),
        ),
      );
}
