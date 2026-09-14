import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../providers/voice_provider.dart';

class VoiceEvolutionScreen extends ConsumerStatefulWidget {
  const VoiceEvolutionScreen({super.key});

  @override
  ConsumerState<VoiceEvolutionScreen> createState() =>
      _VoiceEvolutionScreenState();
}

class _VoiceEvolutionScreenState extends ConsumerState<VoiceEvolutionScreen> {
  late final TextEditingController nameController;
  late final TextEditingController expressionController;
  late final TextEditingController resonanceController;

  static const marks = ['◇', '○', '△', '✦', '≈', '∿', '◌', '✧'];
  String selectedMark = '◇';

  @override
  void initState() {
    super.initState();
    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    nameController = TextEditingController(text: voice?.name ?? '');
    expressionController =
        TextEditingController(text: voice?.expression ?? '');
    resonanceController =
        TextEditingController(text: voice?.resonance ?? '');
    selectedMark = voice?.mark ?? marks.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    expressionController.dispose();
    resonanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final expression = expressionController.text.trim();
    final resonance = resonanceController.text.trim();

    if (name.isEmpty || expression.isEmpty || resonance.isEmpty) return;

    final notifier = ref.read(ventvoVoiceProvider.notifier);
    await notifier.updateName(name);
    await notifier.updateExpression(expression);
    await notifier.updateResonance(resonance);
    await notifier.updateMark(selectedMark);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = nameController.text.trim().isNotEmpty &&
        expressionController.text.trim().isNotEmpty &&
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
              'As you grow, you can choose what your Voice carries forward. Nothing here changes your private identity.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                selectedMark,
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mark',
              style: TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final mark in marks)
                  ChoiceChip(
                    label: Text(mark),
                    selected: selectedMark == mark,
                    onSelected: (_) => setState(() => selectedMark = mark),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            _field('Voice name', nameController),
            const SizedBox(height: 16),
            _field('Expression', expressionController, maxLines: 3),
            const SizedBox(height: 16),
            _field('Resonance', resonanceController, maxLines: 3),
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
