import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vent.dart';
import '../providers/vent_provider.dart';
import '../providers/voice_provider.dart';

import '../../crash_out/providers/crash_out_provider.dart';
import 'voice_space_screen.dart';

class CreateVentScreen extends ConsumerStatefulWidget {
  final String? initialContent;
  final String? crashOutId;

  const CreateVentScreen({
    super.key,
    this.initialContent,
    this.crashOutId,
  });

  @override
  ConsumerState<CreateVentScreen> createState() => _CreateVentScreenState();
}

class _CreateVentScreenState extends ConsumerState<CreateVentScreen> {
  late final TextEditingController controller;
  String? selectedSpace;

  bool get isFromCrashOut => widget.crashOutId != null;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialContent ?? '');
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

    if (selectedSpace == null || content.length < 3) return;

    final voice = ref.read(ventvoVoiceProvider).valueOrNull;

    final vent = Vent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      spaceType: selectedSpace!,
      voiceMark: voice?.mark ?? '◇',
      createdAt: DateTime.now(),
    );

    await ref.read(ventProvider.notifier).addVent(vent);

    if (!mounted) return;

    if (widget.crashOutId != null) {
      ref.read(crashOutProvider.notifier).markConvertedToVent(widget.crashOutId!);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const VoiceSpaceScreen(),
        ),
        (route) => false,
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final voice = ref.watch(ventvoVoiceProvider).valueOrNull;
    final canRelease =
        selectedSpace != null && controller.text.trim().length >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: Text(
          isFromCrashOut ? 'Turn into a Vent' : 'Release a Moment',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFromCrashOut
                    ? 'Let this moment become a Vent.'
                    : 'Release a Moment',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '◇ ${voice?.mark ?? "Voice"}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller,
                maxLines: 7,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.5,
                ),
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
                'Choose the Space',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your choice determines how other Voices can respond.',
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 18),
              _spaceOption(
                title: Vent.justListen,
                description: 'I want to be heard without needing answers.',
              ),
              const SizedBox(height: 15),
              _spaceOption(
                title: Vent.openDiscussion,
                description: 'I want other Voices to share perspectives with me.',
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: canRelease ? _releaseVent : null,
                  child: Text(
                    isFromCrashOut ? 'Release as Vent' : 'Release Moment',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spaceOption({
    required String title,
    required String description,
  }) {
    final isSelected = selectedSpace == title;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title. $description',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => selectedSpace = title),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white24 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
