import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../models/voice_mark.dart';
import '../providers/voice_provider.dart';
import '../services/voice_identity_catalog.dart';

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

  late String selectedMarkId;
  late String suggestedName;

  @override
  void initState() {
    super.initState();
    final voice = ref.read(ventvoVoiceProvider).asData?.value;
    final currentMark = voice?.mark == null
        ? VoiceIdentityCatalog.marks.first
        : VoiceIdentityCatalog.markBySymbol(voice!.mark!);

    nameController = TextEditingController(text: voice?.name ?? '');
    expressionController =
        TextEditingController(text: voice?.expression ?? '');
    resonanceController =
        TextEditingController(text: voice?.resonance ?? '');
    selectedMarkId = currentMark.id;
    suggestedName = VoiceIdentityCatalog.names.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    expressionController.dispose();
    resonanceController.dispose();
    super.dispose();
  }

  VoiceMark get selectedMark => VoiceIdentityCatalog.markById(selectedMarkId);

  void _useSuggestedName(String name) {
    nameController.text = name;
    nameController.selection = TextSelection.collapsed(
      offset: nameController.text.length,
    );
    setState(() {});
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
    await notifier.updateMark(selectedMark.symbol);

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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  selectedMark.symbol,
                  key: ValueKey(selectedMark.id),
                  style: const TextStyle(
                    color: VentvoColors.textPrimary,
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose a mark',
              style: TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'A small visual sign for your Voice. It does not define you.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final mark in VoiceIdentityCatalog.marks)
                  ChoiceChip(
                    label: Text(
                      mark.symbol,
                      style: const TextStyle(fontSize: 20),
                    ),
                    selected: selectedMarkId == mark.id,
                    onSelected: (_) =>
                        setState(() => selectedMarkId = mark.id),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            _field('Voice name', nameController),
            const SizedBox(height: 10),
            const Text(
              'A name can be yours without being your real name.',
              style: TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in VoiceIdentityCatalog.names.take(6))
                  ActionChip(
                    label: Text(name),
                    onPressed: () => _useSuggestedName(name),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                final names = VoiceIdentityCatalog.names;
                final currentIndex = names.indexOf(suggestedName);
                final nextIndex = (currentIndex + 1) % names.length;
                setState(() => suggestedName = names[nextIndex]);
                _useSuggestedName(suggestedName);
              },
              child: const Text('Show another name'),
            ),
            const SizedBox(height: 12),
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
