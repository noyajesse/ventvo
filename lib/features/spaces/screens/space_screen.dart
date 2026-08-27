import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/ventvo_motion.dart';
import '../../../core/theme/ventvo_colors.dart';
import '../../feed/providers/feed_provider.dart';
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
      reverseTransitionDuration: VentvoMotion.immersive,
      pageBuilder: (_, animation, _) => FadeTransition(
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
  final focusNode = FocusNode();
  List<SpaceResponse> responses = const [];
  bool expressingMoment = false;
  bool composerOpen = false;
  bool pendingMoment = false;
  bool hasHeard = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await storage.loadForSpace(widget.space.id);
    if (!mounted) return;
    setState(() {
      responses = value;
      hasHeard = value.any((response) => response.isHeard && response.voiceMark == '◇ You');
    });
  }

  Future<void> _markHeard() async {
    if (hasHeard) return;
    final heard = SpaceResponse(
      id: 'heard_${DateTime.now().microsecondsSinceEpoch}',
      spaceId: widget.space.id,
      ventId: widget.space.originatingVentId,
      voiceMark: '◇ You',
      content: 'Heard',
      createdAt: DateTime.now(),
      isHeard: true,
    );
    await storage.add(heard);
    if (!mounted) return;
    setState(() {
      responses = [...responses, heard];
      hasHeard = true;
    });
  }

  Future<void> _respond() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final response = SpaceResponse(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      spaceId: widget.space.id,
      ventId: widget.space.originatingVentId,
      voiceMark: '◇ You',
      content: text,
      createdAt: DateTime.now(),
    );
    await storage.add(response);
    if (!mounted) return;
    setState(() {
      responses = [...responses, response];
      controller.clear();
      composerOpen = false;
    });
    focusNode.unfocus();
  }

  Future<void> _createMoment() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() => expressingMoment = true);
    final moment = Vent(
      id: 'moment_${DateTime.now().microsecondsSinceEpoch}',
      content: text,
      spaceId: widget.space.id,
      voiceMark: '◇ You',
      createdAt: DateTime.now(),
    );
    await ref.read(ventProvider.notifier).addVent(moment);
    await ref.read(spaceProvider.notifier).addMoment(widget.space.id, moment.id);
    ref.read(feedProvider.notifier).addDiscoveredMoment(moment);
    if (!mounted) return;
    controller.clear();
    focusNode.unfocus();
    setState(() {
      expressingMoment = false;
      composerOpen = false;
      pendingMoment = false;
    });
  }

  void _openComposer({required bool moment}) {
    setState(() {
      composerOpen = true;
      pendingMoment = moment;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
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
              const Text('What came up for you?', style: TextStyle(color: VentvoColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('You can simply be here, say something back, or let your own thought emerge.', style: TextStyle(color: VentvoColors.textSecondary, height: 1.5)),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.headphones_rounded, color: VentvoColors.textSecondary),
                title: const Text('Just Listen', style: TextStyle(color: VentvoColors.textPrimary)),
                subtitle: const Text('Let them know you received it', style: TextStyle(color: VentvoColors.textMuted)),
                onTap: () => Navigator.pop(context, 'heard'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.reply_rounded, color: VentvoColors.textSecondary),
                title: const Text('Say something back', style: TextStyle(color: VentvoColors.textPrimary)),
                subtitle: const Text('Let your words stay with this Moment', style: TextStyle(color: VentvoColors.textMuted)),
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
    if (choice == 'heard') {
      await _markHeard();
    } else if (choice == 'response') {
      _openComposer(moment: false);
    } else {
      _openComposer(moment: true);
    }
  }

  Future<void> _send() async {
    if (pendingMoment) {
      await _createMoment();
    } else {
      await _respond();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
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
    final ordinary = responses.where((r) => !r.isMoment && !r.isHeard).toList();
    final heard = responses.where((r) => r.isHeard).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 48),
      children: [
        if (moments.isNotEmpty) _origin(moments.first),
        if (heard.isNotEmpty || ordinary.isNotEmpty) ...[
          const SizedBox(height: 28),
          _responseHeader(heard.length + ordinary.length),
          const SizedBox(height: 14),
          ...heard.map(_heard),
          ...ordinary.map(_response),
        ],
        if (moments.length > 1) ...[
          const SizedBox(height: 34),
          _emergenceLabel(),
          const SizedBox(height: 16),
          ...moments.skip(1).map(_moment),
        ],
        if (ordinary.isEmpty && heard.isEmpty && moments.length <= 1) ...[
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
            Row(
              children: [
                Text(vent.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 11)),
                const Spacer(),
                const Text('ORIGIN', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
              ],
            ),
            const SizedBox(height: 18),
            Hero(
              tag: 'moment-${vent.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(vent.content, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 30, height: 1.42, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 28),
            Container(height: 1, color: VentvoColors.border.withValues(alpha: .45)),
          ],
        ),
      );

  Widget _responseHeader(int count) => Padding(
        padding: const EdgeInsets.only(left: 22),
        child: Row(
          children: [
            Container(width: 1, height: 18, color: VentvoColors.border),
            const SizedBox(width: 10),
            Text(count == 1 ? 'ONE THING SAID BACK' : '$count THINGS SAID BACK', style: const TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.25)),
          ],
        ),
      );

  Widget _emergenceLabel() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 3),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 12, color: VentvoColors.textMuted),
            SizedBox(width: 8),
            Text('WHAT EMERGED HERE', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
          ],
        ),
      );

  Widget _heard(SpaceResponse response) => Padding(
        padding: const EdgeInsets.only(left: 22, bottom: 15),
        child: Row(
          children: [
            const Icon(Icons.headphones_rounded, size: 14, color: VentvoColors.textMuted),
            const SizedBox(width: 10),
            Text('${response.voiceMark} · Heard', style: const TextStyle(color: VentvoColors.textMuted, fontSize: 11)),
          ],
        ),
      );

  Widget _response(SpaceResponse response) => Padding(
        padding: const EdgeInsets.only(left: 22, bottom: 17),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 1, color: VentvoColors.border.withValues(alpha: .55)),
              const SizedBox(width: 13),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(response.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10)),
                      const SizedBox(height: 5),
                      Text(response.content, style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 14, height: 1.55)),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  const Text('EMERGED', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
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

  Widget _composer() {
    if (!composerOpen) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 15),
          child: Material(
            color: VentvoColors.surface,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _chooseExpression,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                child: Row(
                  children: [
                    Expanded(child: Text('What came up for you?', style: TextStyle(color: VentvoColors.textMuted, fontSize: 13))),
                    Icon(Icons.add_rounded, color: VentvoColors.textMuted, size: 20),
                  ],
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
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: VentvoColors.border.withValues(alpha: .5))),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: pendingMoment ? 'Leave what came up…' : 'Say something back…',
                    hintStyle: const TextStyle(color: VentvoColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              IconButton(onPressed: expressingMoment ? null : () => setState(() { composerOpen = false; pendingMoment = false; focusNode.unfocus(); }), icon: const Icon(Icons.close_rounded), color: VentvoColors.textMuted),
              IconButton(onPressed: expressingMoment ? null : _send, icon: const Icon(Icons.arrow_upward_rounded), color: VentvoColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
