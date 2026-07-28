import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ventvo_voice.dart';

class VentvoVoiceNotifier extends Notifier<VentvoVoice> {
  @override
  VentvoVoice build() {
    return VentvoVoice(
      createdAt: DateTime.now(),
    );
  }

  void updateExpression(String expression) {
    state = state.copyWith(
      expression: expression,
    );
  }

  void updateResonance(String resonance) {
    state = state.copyWith(
      resonance: resonance,
    );
  }

  void updateMark(String mark) {
    state = state.copyWith(
      mark: mark,
    );
  }

  void updateName(String name) {
    state = state.copyWith(
      name: name,
    );
  }
}

final ventvoVoiceProvider =
    NotifierProvider<VentvoVoiceNotifier, VentvoVoice>(
  VentvoVoiceNotifier.new,
);