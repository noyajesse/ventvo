import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../crash_out/providers/crash_out_provider.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../models/vent.dart';
import '../providers/vent_provider.dart';
import '../providers/voice_lifecycle_provider.dart';
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
      spaceId: spaceId,      voiceMark: voiceMark,
      ownerVoiceId: voice?.voiceId,
      voiceName: voice?.name,
      voiceSeedId: voice?.seedId,
      createdAt: now,
      originatingCrashOutId: widget.crashOutId,
    );

    await ref.read(spaceProvider.notifier).addSpace(space);
    await ref.read(ventProvider.notifier).addVent(vent);
    await ref.read(ventResonanceDiscoveryServiceProvider).indexVent(
          vent: vent,
          space: space,
        );
    ref.invalidate(voiceLifecycleProvider);
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

    // A released Moment should be experienced in its Space immediately.
    // Replacing the composer keeps the back path returning to the Voice
    // rather than reopening the composer.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SpaceScreen(space: space),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final voice = ref.watch(ventvoVoiceProvider).asData?.value;
    final canRelease =
        selectedMode != null && controller.text.trim().length >= 3;
    final voiceIdentity = [
      if (voice?.mark != null && voice!.mark!.trim().isNotEmpty)
        voice.mark!.trim(),
      if (voice?.name != null && voice!.name!.trim().isNotEmpty)
        voice.name!.trim(),
    ].join('  ');

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        titleSpacing: 22,
        title: Text(
          isFromCrashOut ? 'Turn into a Vent' : 'Release a Moment',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFromCrashOut
                    ? 'Let this moment become a Vent.'
                    : 'Give the moment somewhere to exist.',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                voiceIdentity.isEmpty ? 'Your Voice' : voiceIdentity,
                style: textTheme.bodyMedium?.copyWith(
                  color: VentvoColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This Moment becomes part of your Voice journey.',
                style: textTheme.bodySmall?.copyWith(
                  color: VentvoColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: VentvoColors.border),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 8,
                  minLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  style: textTheme.bodyLarge?.copyWith(
                    color: VentvoColors.textPrimary,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What wants to be heard?',
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: VentvoColors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Choose how this Vent can be held',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'You decide whether this moment needs presence or conversation.',
                style: textTheme.bodySmall?.copyWith(
                  color: VentvoColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _spaceOption(
                mode: SpaceMode.justListen,
                title: 'Just Listen',
                description: 'I want to be heard without opening a discussion.',
                icon: Icons.hearing_outlined,
              ),
              const SizedBox(height: 10),
              _spaceOption(
                mode: SpaceMode.openDiscussion,
                title: 'Open Discussion',
                description: 'I am open to other Voices sharing perspectives.',
                icon: Icons.forum_outlined,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: canRelease ? _releaseVent : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VentvoColors.buttonBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: VentvoColors.surface,
                    disabledForegroundColor: VentvoColors.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    isFromCrashOut ? 'Release as Vent' : 'Release Moment',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'You can choose how people meet this moment.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: VentvoColors.textMuted,
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
    required SpaceMode mode,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = selectedMode == mode;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title. $description',
      child: Material(
        color: isSelected
            ? VentvoColors.primary.withValues(alpha: 0.08)
            : VentvoColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => selectedMode = mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? VentvoColors.primary.withValues(alpha: 0.65)
                    : VentvoColors.border,
                width: isSelected ? 1.3 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? VentvoColors.primary.withValues(alpha: 0.12)
                        : VentvoColors.background,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? VentvoColors.primary
                        : VentvoColors.textSecondary,
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(
                          color: VentvoColors.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? VentvoColors.primary
                      : VentvoColors.textMuted,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
