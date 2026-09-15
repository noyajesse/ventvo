import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../models/voice_seed.dart';
import '../providers/voice_provider.dart';
import '../services/voice_identity_catalog.dart';

class VoiceEvolutionScreen extends ConsumerStatefulWidget {
  const VoiceEvolutionScreen({super.key});

  @override
  ConsumerState<VoiceEvolutionScreen> createState() =>
      _VoiceEvolutionScreenState();
}

class _VoiceEvolutionScreenState extends ConsumerState<VoiceEvolutionScreen> {
  late final TextEditingController expressionController;
  late final TextEditingController resonanceController;

  late String selectedSeedId;

  @override
  void initState() {
    super.initState();
    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    final existingSeed = voice?.name == null
        ? null
        : _findSeedByStoredName(voice!.name!);

    expressionController =
        TextEditingController(text: voice?.expression ?? '');
    resonanceController =
        TextEditingController(text: voice?.resonance ?? '');
    selectedSeedId = existingSeed?.id ?? VoiceIdentityCatalog.seeds.first.id;
  }

  VoiceSeed? _findSeedByStoredName(String name) {
    for (final seed in VoiceIdentityCatalog.seeds) {
      if (seed.word == name) return seed;
    }
    return null;
  }

  @override
  void dispose() {
    expressionController.dispose();
    resonanceController.dispose();
    super.dispose();
  }

  VoiceSeed get selectedSeed => VoiceIdentityCatalog.seedById(selectedSeedId);

  Future<void> _save() async {
    final expression = expressionController.text.trim();
    final resonance = resonanceController.text.trim();

    if (expression.isEmpty || resonance.isEmpty) return;

    final notifier = ref.read(ventvoVoiceProvider.notifier);
    await notifier.updateName(selectedSeed.word);
    await notifier.updateExpression(expression);
    await notifier.updateResonance(resonance);
    await notifier.updateMark(selectedSeed.mark.symbol);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = expressionController.text.trim().isNotEmpty &&
        resonanceController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: const Text('Shape Your Voice'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
          children: [
            const Text(
              'Your Voice can change.',
              style: TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your Voice begins with a Seed. It is not a personality label. It is a small piece of the language you carry through Ventvo.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Column(
                key: ValueKey(selectedSeed.id),
                children: [
                  Text(
                    selectedSeed.mark.symbol,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedSeed.word,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 22,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedSeed.essence,
                    style: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: VentvoColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedSeed.meaning,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“${selectedSeed.feeling}”',
                    style: const TextStyle(
                      color: VentvoColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Find your Seed',
              style: TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'There is no right one. Choose the one that feels closest to where your Voice is now.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final seed in VoiceIdentityCatalog.seeds)
                  ChoiceChip(
                    label: Text('${seed.mark.symbol} ${seed.word}'),
                    selected: selectedSeedId == seed.id,
                    onSelected: (_) =>
                        setState(() => selectedSeedId = seed.id),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            _field('Expression', expressionController, maxLines: 3),
            const SizedBox(height: 8),
            const Text(
              'What your Voice is carrying right now.',
              style: TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            _field('Resonance', resonanceController, maxLines: 3),
            const SizedBox(height: 8),
            const Text(
              'What your Voice recognizes or feels connected to.',
              style: TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: canSave ? _save : null,
                child: const Text('Let My Voice Evolve'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: VentvoColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: VentvoColors.textMuted),
        filled: true,
        fillColor: VentvoColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
