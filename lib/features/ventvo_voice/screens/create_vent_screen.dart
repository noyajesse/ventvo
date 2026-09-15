import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../crash_out/providers/crash_out_provider.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../models/vent.dart';
import '../providers/vent_provider.dart';
import '../providers/voice_provider.dart';
import 'voice_space_screen.dart';

class CreateVentScreen extends ConsumerStatefulWidget {
  final String? initialContent;
  final String? crashOutId;
  final SpaceMode? initialSpaceMode;

  const CreateVentScreen({
    super.key,
    this.initialContent,
    this.crashOutId,
    this.initialSpaceMode,
  });

  @override
  ConsumerState<CreateVentScreen> createState() => _CreateVentScreenState();
}

class _CreateVentScreenState extends ConsumerState<CreateVentScreen> {
  late final TextEditingController controller;
  SpaceMode? selectedMode;

  bool get isFromCrashOut => widget.crashOutId != null;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialContent ?? '');
    selectedMode = widget.initialSpaceMode;
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _releaseVent() async {
    final content = controller.text.trim();
    final mode = selectedMode;
    if (mode == null || content.length < 3) return;

    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    final now = DateTime.now();
    final ventId = now.millisecondsSinceEpoch.toString();
    final spaceId = 'space_$ventId';
    final voiceMark = voice?.mark ?? '◇';

    final space = Space(
      id: spaceId,
      mode: mode,
      originatingVentId: ventId,
      creatorVoiceMark: voiceMark,
      createdAt: now,
    );

    final vent = Vent(
      id: ventId,
      content: content,
      spaceId: spaceId,
      voiceMark: voiceMark,
      voiceName: voice?.name,
      createdAt: now,
      originatingCrashOutId: widget.crashOutId,
    );

    await ref.read(spaceProvider.notifier).addSpace(space);
    await ref.read(ventProvider.notifier).addVent(vent);
    await ref.read(ventResonanceDiscoveryServiceProvider).indexVent(
          vent: vent,
          space: space,
        );
    if (!mounted) return;

    if (widget.crashOutId != null) {
      await ref
          .read(crashOutProvider.notifier)
          .markConvertedToVent(widget.crashOutId!);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VoiceSpaceScreen()),
        (route) => false,
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final voice = ref.watch(ventvoVoiceProvider).asData?.value;
    final canRelease = selectedMode != null && controller.text.trim().length >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: Text(
          isFromCrashOut ? 'Turn into a Vent' : 'Release a Moment',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFromCrashOut ? 'Let this moment become a Vent.' : 'Release a Moment',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('◇ ${voice?.mark ?? "Voice"}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 30),
              TextField(
                controller: controller,
                maxLines: 7,
                style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'What wants to be heard?',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'Choose how this Vent can be held',
                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can choose between being heard or opening the experience to discussion.',
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 18),
              _spaceOption(
                mode: SpaceMode.justListen,
                title: 'Just Listen',
                description: 'I want to be heard without opening a discussion.',
              ),
              const SizedBox(height: 15),
              _spaceOption(
                mode: SpaceMode.openDiscussion,
                title: 'Open Discussion',
                description: 'I am open to other Voices sharing perspectives.',
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: canRelease ? _releaseVent : null,
                  child: Text(isFromCrashOut ? 'Release as Vent' : 'Release Moment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spaceOption({
    required SpaceMode mode,
    required String title,
    required String description,
  }) {
    final isSelected = selectedMode == mode;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title. $description',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => selectedMode = mode),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white24 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.white : Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
