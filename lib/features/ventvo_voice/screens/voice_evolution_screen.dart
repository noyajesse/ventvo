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

  VoiceSeed? get currentSeed {
    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    final name = voice?.name;
    if (name == null || name.trim().isEmpty) return null;

    for (final seed in VoiceIdentityCatalog.seeds) {
      if (seed.word.toLowerCase() == name.trim().toLowerCase()) {
        return seed;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    expressionController =
        TextEditingController(text: voice?.expression ?? '');
    resonanceController =
        TextEditingController(text: voice?.resonance ?? '');
  }

  @override
  void dispose() {
    expressionController.dispose();
    resonanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final expression = expressionController.text.trim();
    final resonance = resonanceController.text.trim();

    if (expression.isEmpty || resonance.isEmpty) return;

    final notifier = ref.read(ventvoVoiceProvider.notifier);
    await notifier.updateExpression(expression);
    await notifier.updateResonance(resonance);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final seed = currentSeed;
    final canSave = expressionController.text.trim().isNotEmpty &&
        resonanceController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: const Text('Let Your Voice Evolve'),
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
              'Your Seed is where your Voice began. What you carry around it can change as you live, express, and recognize new things.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            if (seed != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: VentvoColors.border.withValues(alpha: .55),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      seed.mark.symbol,
                      style: const TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      seed.word,
                      style: const TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 21,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      seed.essence,
                      style: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      seed.meaning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: VentvoColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'Your Seed will appear here once your Voice has been discovered.',
                style: TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 28),
            const Text(
              'What is changing?',
              style: TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your Seed does not need to be configured. Your expression can simply change with you.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
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
