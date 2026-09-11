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
import '../widgets/space_resonance_section.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final Space space;

  const SpaceScreen({
    super.key,
    required this.space,
  });

  static Future<void> open(
    BuildContext context,
    Space space,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: VentvoMotion.immersive,
        reverseTransitionDuration: VentvoMotion.immersive,
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SpaceScreen(space: space),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen> {
  final storage = SpaceResponseStorage();
  final controller = TextEditingController();
  final focusNode = FocusNode();

  List<SpaceResponse> responses = const [];

  bool composerOpen = false;
  bool pendingMoment = false;
  bool expressingMoment = false;
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
      hasHeard = value.any(
        (response) => response.isHeard && response.voiceMark == '◇ You',
      );
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
      pendingMoment = false;
    });

    focusNode.unfocus();
  }

  Future<void> _createMoment() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      expressingMoment = true;
    });

    final moment = Vent(
      id: 'moment_${DateTime.now().microsecondsSinceEpoch}',
      content: text,
      spaceId: widget.space.id,
      voiceMark: '◇ You',
      createdAt: DateTime.now(),
    );

    await ref.read(ventProvider.notifier).addVent(moment);

    await ref.read(spaceProvider.notifier).addMoment(
      widget.space.id,
      moment.id,
    );

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
      if (mounted) {
        focusNode.requestFocus();
      }
    });
  }

  Future<void> _chooseExpression() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: VentvoColors.surfaceElevated,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 34,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VentvoColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'What came up for you?',
                  style: TextStyle(
                    color: VentvoColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'You can listen, respond, or let the thought take you somewhere else.',
                  style: TextStyle(
                    color: VentvoColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                _expressionTile(
                  icon: Icons.headphones_rounded,
                  title: 'Just listen',
                  subtitle: 'Let them know you received it.',
                  onTap: () => Navigator.pop(context, 'heard'),
                ),
                const SizedBox(height: 6),
                _expressionTile(
                  icon: Icons.reply_rounded,
                  title: 'Say something back',
                  subtitle: 'Leave a response with this thought.',
                  onTap: () => Navigator.pop(context, 'response'),
                ),
                const SizedBox(height: 6),
                _expressionTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Let something emerge',
                  subtitle: 'Share a thought of your own.',
                  onTap: () => Navigator.pop(context, 'moment'),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _expressionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VentvoColors.border),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: VentvoColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: VentvoColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
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
            _topBar(),
            Expanded(
              child: ref.watch(ventProvider).when(
                    loading: () => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: VentvoColors.textMuted,
                        ),
                      ),
                    ),
                    error: (_, _) => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'This Space could not be opened.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: VentvoColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    data: _content,
                  ),
            ),
            if (widget.space.isOpenDiscussion) _composer(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: VentvoColors.textSecondary,
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          const Text(
            'Space',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: VentvoColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(List<Vent> allVents) {
    final ids = widget.space.allVentIds.toSet();

    final moments = allVents
        .where((vent) => ids.contains(vent.id))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final ordinary = responses
        .where((response) => !response.isMoment && !response.isHeard)
        .toList();

    final heard = responses
        .where((response) => response.isHeard)
        .toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 70),
      children: [
        if (moments.isNotEmpty) _origin(moments.first),

        if (moments.isNotEmpty) ...[
          const SizedBox(height: 42),
          SpaceResonanceSection(
            space: widget.space,
            excludedIds: widget.space.allVentIds,
          ),
        ],

        if (heard.isNotEmpty) ...[
          const SizedBox(height: 42),
          _heardSection(heard),
        ],

        if (ordinary.isNotEmpty) ...[
          const SizedBox(height: 30),
          _responseSection(ordinary),
        ],

        if (moments.length > 1) ...[
          const SizedBox(height: 42),
          _momentSection(moments.skip(1).toList()),
        ],

        if (ordinary.isEmpty && heard.isEmpty && moments.length <= 1)
          _quietSpace(),
      ],
    );
  }

  Widget _origin(Vent vent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              vent.voiceMark,
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Text(
              'ORIGIN',
              style: TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Hero(
          tag: 'moment-${vent.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              vent.content,
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 29,
                height: 1.43,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: 34,
          height: 1,
          color: VentvoColors.border,
        ),
      ],
    );
  }

  Widget _heardSection(List<SpaceResponse> heard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCaption(
          'PRESENCE',
          '${heard.length} ${heard.length == 1 ? 'person' : 'people'} listened.',
        ),
        const SizedBox(height: 16),
        ...heard.map(_heard),
      ],
    );
  }

  Widget _responseSection(List<SpaceResponse> ordinary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCaption(
          'RESPONSES',
          'Words left here by people who entered.',
        ),
        const SizedBox(height: 18),
        ...ordinary.map(_response),
      ],
    );
  }

  Widget _momentSection(List<Vent> moments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCaption(
          'FROM HERE',
          'Thoughts that grew out of this Space.',
        ),
        const SizedBox(height: 18),
        ...moments.map(_moment),
      ],
    );
  }

  Widget _sectionCaption(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _heard(SpaceResponse response) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: VentvoColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: VentvoColors.border),
            ),
            child: const Icon(
              Icons.headphones_rounded,
              size: 12,
              color: VentvoColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            response.voiceMark,
            style: const TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'listened',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _response(SpaceResponse response) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: VentvoColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 7),
                Text(
                  response.content,
                  style: const TextStyle(
                    color: VentvoColors.textSecondary,
                    fontSize: 15,
                    height: 1.58,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moment(Vent vent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(19, 18, 19, 20),
        decoration: BoxDecoration(
          color: VentvoColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: VentvoColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: VentvoColors.textMuted,
                ),
                const SizedBox(width: 8),
                const Text(
                  'A THOUGHT GREW',
                  style: TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  vent.voiceMark,
                  style: const TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              vent.content,
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 17,
                height: 1.52,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quietSpace() {
    return Padding(
      padding: const EdgeInsets.only(top: 52, left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 1,
            color: VentvoColors.border,
          ),
          const SizedBox(height: 18),
          const Text(
            'Nothing needs to happen here.',
            style: TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'You can stay without saying anything.',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 12,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Something came up?',
                        style: TextStyle(
                          color: VentvoColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: VentvoColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: VentvoColors.border),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: VentvoColors.textSecondary,
                        size: 17,
                      ),
                    ),
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
          padding: const EdgeInsets.fromLTRB(15, 8, 7, 8),
          decoration: BoxDecoration(
            color: VentvoColors.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: VentvoColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    color: VentvoColors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: pendingMoment
                        ? 'Let it emerge…'
                        : 'Say something back…',
                    hintStyle: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: expressingMoment
                    ? null
                    : () {
                        setState(() {
                          composerOpen = false;
                          pendingMoment = false;
                          controller.clear();
                        });
                        focusNode.unfocus();
                      },
                icon: const Icon(Icons.close_rounded),
                color: VentvoColors.textMuted,
                iconSize: 19,
                tooltip: 'Close',
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: VentvoColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: VentvoColors.border),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: expressingMoment ? null : _send,
                  icon: const Icon(Icons.arrow_upward_rounded),
                  color: VentvoColors.textPrimary,
                  iconSize: 19,
                  tooltip: 'Send',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
