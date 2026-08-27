import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/ventvo_motion.dart';
import '../../../core/theme/ventvo_colors.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/space.dart';
import '../models/space_response.dart';
import '../providers/space_provider.dart';
import '../services/space_response_storage.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final Space space;
  const SpaceScreen({super.key, required this.space});

  static Future<void> open(BuildContext context, Space space) {
    return Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: VentvoMotion.immersive,
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: SpaceScreen(space: space),
      ),
    ));
  }

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen> {
  final storage = SpaceResponseStorage();
  final controller = TextEditingController();
  List<SpaceResponse> responses = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await storage.loadForSpace(widget.space.id);
    if (!mounted) return;
    setState(() => responses = value);
  }

  Future<void> _respond() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final response = SpaceResponse(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      spaceId: widget.space.id,
      ventId: widget.space.originatingVentId,
      voiceMark: '◇ Voice',
      content: text,
      createdAt: DateTime.now(),
    );

    await storage.add(response);
    if (!mounted) return;
    setState(() {
      responses = [...responses, response];
      controller.clear();
    });
  }

  Future<void> _createMoment() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final moment = Vent(
      id: 'moment_${DateTime.now().microsecondsSinceEpoch}',
      content: text,
      spaceId: widget.space.id,
      voiceMark: '◇ Voice',
      createdAt: DateTime.now(),
    );

    await ref.read(ventProvider.notifier).addVent(moment);
    await ref.read(spaceProvider.notifier).addMoment(widget.space.id, moment.id);
    if (!mounted) return;
    controller.clear();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ref.watch(ventProvider).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Center(child: Text('This Space could not be opened.')),
                data: _content,
              ),
            ),
            if (widget.space.isOpenDiscussion) _composer(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 16, 4),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: VentvoColors.textSecondary),
            ),
            const Spacer(),
            const Icon(Icons.more_horiz_rounded, color: VentvoColors.textMuted),
          ],
        ),
      );

  Widget _content(List<Vent> allVents) {
    final ids = widget.space.allVentIds.toSet();
    final moments = allVents.where((v) => ids.contains(v.id)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final ordinaryResponses = responses.where((response) => !response.isMoment).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 42),
      children: [
        if (moments.isNotEmpty) _origin(moments.first),
        if (ordinaryResponses.isNotEmpty) ...[
          const SizedBox(height: 34),
          ...ordinaryResponses.map(_response),
        ],
        if (moments.length > 1) ...[
          const SizedBox(height: 34),
          ...moments.skip(1).map(_moment),
        ],
        if (widget.space.isJustListen && ordinaryResponses.isEmpty) ...[
          const SizedBox(height: 34),
          _quietPresence(),
        ],
      ],
    );
  }

  Widget _origin(Vent vent) => Container(
        padding: const EdgeInsets.fromLTRB(22, 25, 22, 30),
        decoration: BoxDecoration(
          color: VentvoColors.surfaceElevated,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vent.voiceMark, style: const TextStyle(color: VentvoColors.textMuted)),
            const SizedBox(height: 18),
            Text(
              vent.content,
              style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 25, height: 1.45, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );

  Widget _moment(Vent vent) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(19, 19, 19, 21),
          decoration: BoxDecoration(
            color: VentvoColors.surfaceElevated,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 13, color: VentvoColors.textMuted),
                  const SizedBox(width: 8),
                  const Text('MOMENT', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
                  const Spacer(),
                  Text(vent.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 12),
              Text(vent.content, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 18, height: 1.5)),
            ],
          ),
        ),
      );

  Widget _response(SpaceResponse response) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(response.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                response.content,
                style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 14, height: 1.55),
              ),
            ),
          ],
        ),
      );

  Widget _quietPresence() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'You can stay here without saying anything.',
          style: TextStyle(color: VentvoColors.textMuted, fontSize: 13, height: 1.5),
        ),
      );

  Widget _composer() => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 7, 18, 15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Say what came up for you…',
                    hintStyle: const TextStyle(color: VentvoColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: VentvoColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              PopupMenuButton<String>(
                icon: const Icon(Icons.add_circle_outline_rounded, color: VentvoColors.textMuted),
                onSelected: (value) {
                  if (value == 'moment') _createMoment();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'moment', child: Text('Share as a Moment')),
                ],
              ),
              IconButton(
                onPressed: _respond,
                icon: const Icon(Icons.arrow_upward_rounded),
                color: VentvoColors.primary,
              ),
            ],
          ),
        ),
      );
}
