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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await storage.loadForSpace(widget.space.id);
    if (!mounted) return;
    setState(() { responses = value; loading = false; });
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
    setState(() { responses = [...responses, response]; controller.clear(); });
  }

  Future<void> _turnIntoMoment(SpaceResponse response) async {
    final moment = Vent(
      id: 'moment_${DateTime.now().microsecondsSinceEpoch}',
      content: response.content,
      spaceId: widget.space.id,
      voiceMark: response.voiceMark,
      createdAt: response.createdAt,
    );
    await ref.read(ventProvider.notifier).addVent(moment);
    await ref.read(spaceProvider.notifier).addMoment(widget.space.id, moment.id);
    if (!mounted) return;
    final index = responses.indexWhere((item) => item.id == response.id);
    if (index == -1) return;
    setState(() {
      responses = [
        ...responses.take(index),
        SpaceResponse(
          id: response.id,
          spaceId: response.spaceId,
          ventId: moment.id,
          voiceMark: response.voiceMark,
          content: response.content,
          createdAt: response.createdAt,
          isMoment: true,
        ),
        ...responses.skip(index + 1),
      ];
    });
  }

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: ref.watch(ventProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('This Space could not be opened.')),
              data: _content,
            )),
            if (widget.space.isOpenDiscussion) _composer(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 4, 20, 4),
    child: Row(children: [
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded, color: VentvoColors.textSecondary),
      ),
      const Spacer(),
      Text(
        widget.space.isJustListen ? 'JUST LISTEN' : 'OPEN DISCUSSION',
        style: const TextStyle(color: VentvoColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.8),
      ),
    ]),
  );

  Widget _content(List<Vent> allVents) {
    final ids = widget.space.allVentIds.toSet();
    final moments = allVents.where((v) => ids.contains(v.id)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      children: [
        _label('THE SPACE BEGINS HERE'),
        const SizedBox(height: 13),
        if (moments.isNotEmpty) _origin(moments.first),
        if (moments.length > 1) ...[
          const SizedBox(height: 42),
          _label('MOMENTS THAT EMERGED'),
          const SizedBox(height: 18),
          ...moments.skip(1).map(_moment),
        ],
        const SizedBox(height: 42),
        _label('VOICES AROUND IT'),
        const SizedBox(height: 17),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (responses.isEmpty)
          const Text('No one has responded yet. There is room for the first voice.', style: TextStyle(color: VentvoColors.textSecondary, height: 1.5))
        else
          ...responses.map(_response),
      ],
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.8));

  Widget _origin(Vent vent) => Container(
    padding: const EdgeInsets.fromLTRB(22, 22, 22, 27),
    decoration: BoxDecoration(color: VentvoColors.surfaceElevated, borderRadius: BorderRadius.circular(30)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(vent.voiceMark, style: const TextStyle(color: VentvoColors.textMuted)),
      const SizedBox(height: 17),
      Text(vent.content, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 25, height: 1.45, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _moment(Vent vent) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.only(top: 7), child: Icon(Icons.arrow_downward_rounded, size: 14, color: VentvoColors.textMuted)),
      const SizedBox(width: 12),
      Expanded(child: Text(vent.content, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 18, height: 1.5))),
    ]),
  );

  Widget _response(SpaceResponse response) => Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
    decoration: BoxDecoration(
      color: response.isMoment ? VentvoColors.surfaceElevated : VentvoColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: VentvoColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(response.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10)),
        const Spacer(),
        if (response.isMoment)
          const Text('MOMENT', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.2))
        else
          TextButton(onPressed: () => _turnIntoMoment(response), child: const Text('Make this a Moment')),
      ]),
      Text(response.content, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 15, height: 1.5)),
    ]),
  );

  Widget _composer() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(18, 7, 18, 15),
      child: Row(children: [
        Expanded(child: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 4,
          style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Share what this moment brought up.',
            hintStyle: const TextStyle(color: VentvoColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: VentvoColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        )),
        const SizedBox(width: 8),
        IconButton(onPressed: _respond, icon: const Icon(Icons.arrow_upward_rounded), color: VentvoColors.primary),
      ]),
    ),
  );
}
