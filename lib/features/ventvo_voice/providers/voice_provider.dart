import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ventvo_voice.dart';
import '../services/voice_identity_catalog.dart';
import '../services/voice_storage.dart';

class VentvoVoiceNotifier extends AsyncNotifier<VentvoVoice?> {
  final VentvoVoiceStorage _storage = VentvoVoiceStorage();

  @override
  Future<VentvoVoice?> build() async {
    final voice = await _storage.load();
    if (voice == null || voice.seedId != null) return voice;

    final name = voice.name?.trim().toLowerCase();
    if (name == null || name.isEmpty) return voice;

    for (final seed in VoiceIdentityCatalog.seeds) {
      if (seed.word.toLowerCase() == name) {
        final migrated = voice.copyWith(seedId: seed.id);
        await _storage.save(migrated);
        return migrated;
      }
    }

    return voice;
  }

  Future<void> _persist(VentvoVoice voice) async {
    state = AsyncData(voice);
    await _storage.save(voice);
  }

  /// Creates the local Voice shell used while the user shapes their Voice.
  ///
  /// The shell is intentionally incomplete: the following Voice steps fill
  /// in its mark, name, resonance, and expression. Keeping one Voice object
  /// throughout the flow prevents update methods from silently doing nothing.
  Future<VentvoVoice> ensureVoice() async {
    final existing = state.asData?.value;
    if (existing != null) return existing;

    final stored = await _storage.load();
    if (stored != null) {
      state = AsyncData(stored);
      return stored;
    }

    final now = DateTime.now();
    final voice = VentvoVoice(
      voiceId: 'voice_${now.millisecondsSinceEpoch}',
      createdAt: now,
    );
    await _persist(voice);
    return voice;
  }

  Future<void> setVoice(VentvoVoice voice) async {
    await _persist(voice);
  }

  Future<void> updateExpression(String expression) async {
    final voice = state.asData?.value;
    if (voice == null) return;

    await _persist(voice.copyWith(expression: expression));
  }

  Future<void> updateResonance(String resonance) async {
    final voice = state.asData?.value;
    if (voice == null) return;

    await _persist(voice.copyWith(resonance: resonance));
  }

  Future<void> updateMark(String mark) async {
    final voice = state.asData?.value;
    if (voice == null) return;

    await _persist(voice.copyWith(mark: mark));
  }

  Future<void> updateName(String name) async {
    final voice = state.asData?.value;
    if (voice == null) return;

    await _persist(voice.copyWith(name: name));
  }

  Future<void> clearVoice() async {
    await _storage.clear();
    state = const AsyncData(null);
  }
}

final ventvoVoiceProvider =
    AsyncNotifierProvider<VentvoVoiceNotifier, VentvoVoice?>(
  VentvoVoiceNotifier.new,
);
