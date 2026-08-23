import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ventvo_voice.dart';
import '../services/voice_storage.dart';

class VentvoVoiceNotifier extends AsyncNotifier<VentvoVoice?> {
  final VentvoVoiceStorage _storage = VentvoVoiceStorage();

  @override
  Future<VentvoVoice?> build() async {
    return _storage.load();
  }

  Future<void> _persist(VentvoVoice voice) async {
    state = AsyncData(voice);
    await _storage.save(voice);
  }

  Future<void> setVoice(VentvoVoice voice) async {
    await _persist(voice);
  }

  Future<void> updateExpression(String expression) async {
    final voice = state.valueOrNull;
    if (voice == null) return;

    await _persist(voice.copyWith(expression: expression));
  }

  Future<void> updateResonance(String resonance) async {
    final voice = state.valueOrNull;
    if (voice == null) return;

    await _persist(voice.copyWith(resonance: resonance));
  }

  Future<void> updateMark(String mark) async {
    final voice = state.valueOrNull;
    if (voice == null) return;

    await _persist(voice.copyWith(mark: mark));
  }

  Future<void> updateName(String name) async {
    final voice = state.valueOrNull;
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
