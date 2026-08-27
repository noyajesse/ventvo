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
  bool expressingMoment = false;

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
    setState(() => expressingMoment = true);
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
    setState(() => expressingMoment = false);
  }

  Future<void> _chooseExpression() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: VentvoColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 34, height: 4, decoration: BoxDecoration(color: VentvoColors.border, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 24),
              const Text('How do you want to leave something here?', style: TextStyle(color: VentvoColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Respond to what is here, or leave a thought of your own.', style: TextStyle(color: VentvoColors.textSecondary, height: 1.5)),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.reply_rounded, color: VentvoColors.textSecondary),
                title: const Text('Respond', style: TextStyle(color: VentvoColors.textPrimary)),
                onTap: () => Navigator.pop(context, 'response'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.auto_awesome_rounded, color: VentvoColors.textSecondary),
                title: const Text('Leave a thought', style: TextStyle(color: VentvoColors.textPrimary)),
                subtitle: const Text('Let it stand on its own', style: TextStyle(color: VentvoColors.textMuted)),
                onTap: () => Navigator.pop(context, 'moment'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'moment') await _createMoment();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: VentvoColors.textSecondary)),
                  const Spacer(),
                  const Icon(Icons.more_horiz_rounded, color: VentvoColors.textMuted),
                ],
              ),
            ),
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

  Widget _content(List<Vent> allVents) {
    final ids = widget.space.allVentIds.toSet();
    final moments = allVents.where((v) => ids.contains(v.id)).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final ordinary = responses.where((r) => !r.isMoment).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 48),
      children: [
        if (moments.isNotEmpty) _origin(moments.first),
        if (ordinary.isNotEmpty) ...[
          const SizedBox(height: 34),
          ...ordinary.map(_response),
        ],
        if (moments.length > 1) ...[
          const SizedBox(height: 26),
          ...moments.skip(1).map(_moment),
        ],
        if (widget.space.isJustListen && ordinary.isEmpty) ...[
          const SizedBox(height: 34),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('You can stay here without saying anything.', style: TextStyle(color: VentvoColors.textMuted, fontSize: 13, height: 1.5)),
          ),
        ],
      ],
    );
  }

  Widget _origin(Vent vent) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vent.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 11)),
            const SizedBox(height: 18),
            Text(vent.content, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 30, height: 1.42, fontWeight: FontWeight.w500)),
            const SizedBox(height: 28),
            Container(height: 1, color: VentvoColors.border.withValues(alpha: .45)),
          ],
        ),
      );

  Widget _response(SpaceResponse response) => Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(response.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10)),
            const SizedBox(width: 11),
            Expanded(child: Text(response.content, style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 14, height: 1.55))),
          ],
        ),
      );

  Widget _moment(Vent vent) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(color: VentvoColors.surfaceElevated, borderRadius: BorderRadius.circular(24)),
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
              const SizedBox(width: 4),
              IconButton(onPressed: expressingMoment ? null : _chooseExpression, icon: const Icon(Icons.add_circle_outline_rounded), color: VentvoColors.textMuted),
              IconButton(onPressed: expressingMoment ? null : _respond, icon: const Icon(Icons.arrow_upward_rounded), color: VentvoColors.primary),
            ],
          ),
        ),
      );
}
