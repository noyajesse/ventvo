import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/echo.dart';
import '../models/echo_note.dart';
import '../models/space.dart';
import '../providers/echo_note_provider.dart';
import '../providers/echo_provider.dart';
import '../services/echo_note_service.dart';
import '../services/echo_service.dart';
import '../widgets/space_resonance_section.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final Space space;

  const SpaceScreen({super.key, required this.space});

  static Future<void> open(BuildContext context, Space space) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SpaceScreen(space: space),
      ),
    );
  }

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen> {
  late final EchoService echoService;
  late final EchoNoteService echoNoteService;
  final controller = TextEditingController();
  final focusNode = FocusNode();

  List<Echo> echoes = const [];
  Map<String, List<EchoNote>> echoNotes = const {};
  bool composerOpen = false;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    echoService = ref.read(echoServiceProvider);
    echoNoteService = ref.read(echoNoteServiceProvider);
    _load();
  }

  Future<void> _load() async {
    final loadedEchoes = await echoService.loadForSpace(widget.space.id);
    final loadedNotes = await echoNoteService.loadForSpace(widget.space.id);
    if (!mounted) return;

    final groupedNotes = <String, List<EchoNote>>{};
    for (final note in loadedNotes) {
      groupedNotes.putIfAbsent(note.echoId, () => []).add(note);
    }

    setState(() {
      echoes = loadedEchoes;
      echoNotes = groupedNotes;
    });
  }

  Future<void> _leaveEcho() async {
    if (sending) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => sending = true);

    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    final echo = await echoService.leaveEcho(
      space: widget.space,
      content: text,
      voiceMark: voice?.mark ?? '◇',
    );

    if (!mounted) return;

    if (echo != null) {
      setState(() {
        echoes = [...echoes, echo];
        controller.clear();
        composerOpen = false;
      });
      focusNode.unfocus();
    }

    setState(() => sending = false);
  }

  Future<void> _openEchoNoteComposer(Echo echo) async {
    final noteController = TextEditingController();
    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    final note = await showModalBottomSheet<EchoNote>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 15,
          ),
          child: Material(
            color: VentvoColors.surface,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ECHO NOTE',
                    style: TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Leave a small piece of your own experience with this Echo.',
                    style: TextStyle(
                      color: VentvoColors.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    autofocus: true,
                    minLines: 2,
                    maxLines: 5,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What did this bring forward for you?',
                      hintStyle: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: VentvoColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final result = await echoNoteService.leaveEchoNote(
                          space: widget.space,
                          echo: echo,
                          content: noteController.text,
                          voiceMark: voice?.mark ?? '◇',
                        );
                        if (context.mounted) Navigator.pop(context, result);
                      },
                      child: const Text('Leave Echo Note'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    noteController.dispose();

    if (!mounted || note == null) return;
    setState(() {
      echoNotes = {
        ...echoNotes,
        echo.id: [...(echoNotes[echo.id] ?? const []), note],
      };
    });
  }

  void _openComposer() {
    setState(() => composerOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  void _closeComposer() {
    if (sending) return;
    setState(() {
      composerOpen = false;
      controller.clear();
    });
    focusNode.unfocus();
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
            if (widget.space.isOpenDiscussion) _echoComposer(),
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
    final moments = allVents.where((vent) => ids.contains(vent.id)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (moments.isEmpty) {
      return const Center(
        child: Text(
          'This Space is empty.',
          style: TextStyle(color: VentvoColors.textMuted, fontSize: 14),
        ),
      );
    }

    final origin = moments.first;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 70),
      children: [
        _modeHeader(),
        const SizedBox(height: 34),
        _origin(origin),
        const SizedBox(height: 42),
        SpaceResonanceSection(
          space: widget.space,
          excludedIds: widget.space.allVentIds,
        ),
        if (widget.space.isOpenDiscussion && echoes.isNotEmpty) ...[
          const SizedBox(height: 42),
          _echoSection(),
        ],
      ],
    );
  }

  Widget _modeHeader() {
    final isDiscussion = widget.space.isOpenDiscussion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isDiscussion ? 'OPEN DISCUSSION' : 'JUST LISTEN',
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          isDiscussion
              ? 'A space for people who are open to responding.'
              : 'A space to be heard without needing a conversation.',
          style: const TextStyle(
            color: VentvoColors.textSecondary,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _origin(Vent vent) {
    final voiceLabel = vent.voiceName?.trim();
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
            if (voiceLabel != null && voiceLabel.isNotEmpty) ...[
              const SizedBox(width: 7),
              Text(
                voiceLabel,
                style: const TextStyle(
                  color: VentvoColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                ),
              ),
            ],
            const Spacer(),
            const Text(
              'VENT',
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
        Material(
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
        const SizedBox(height: 30),
        Container(width: 34, height: 1, color: VentvoColors.border),
      ],
    );
  }

  Widget _echoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ECHOES',
          style: TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Voices leaving something of themselves with this Vent.',
          style: TextStyle(color: VentvoColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 18),
        ...echoes.map(_echo),
      ],
    );
  }

  Widget _echo(Echo echo) {
    final notes = echoNotes[echo.id] ?? const <EchoNote>[];

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      echo.voiceMark,
                      style: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      echo.content,
                      style: const TextStyle(
                        color: VentvoColors.textSecondary,
                        fontSize: 15,
                        height: 1.58,
                      ),
                    ),
                    const SizedBox(height: 9),
                    GestureDetector(
                      onTap: () => _openEchoNoteComposer(echo),
                      child: const Text(
                        'Add an Echo Note…',
                        style: TextStyle(
                          color: VentvoColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.only(left: 19),
              child: Column(
                children: notes.map(_echoNote).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _echoNote(EchoNote note) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.voiceMark,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              note.content,
              style: const TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _echoComposer() {
    if (!composerOpen) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 15),
          child: Material(
            color: VentvoColors.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _openComposer,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Leave an Echo…',
                        style: TextStyle(
                          color: VentvoColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 17,
                      color: VentvoColors.textMuted,
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
        child: Material(
          color: VentvoColors.surface,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'What do you want to leave here?',
                      hintStyle: TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sending ? null : _closeComposer,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: VentvoColors.textMuted,
                  tooltip: 'Close',
                ),
                IconButton(
                  onPressed: sending ? null : _leaveEcho,
                  icon: sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      : const Icon(Icons.arrow_upward_rounded, size: 18),
                  color: VentvoColors.textSecondary,
                  tooltip: 'Leave Echo',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
