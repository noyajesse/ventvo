import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vent.dart';

class VentNotifier extends Notifier<List<Vent>> {
  @override
  List<Vent> build() {
    return const [];
  }

  void addVent(Vent vent) {
    state = [
      ...state,
      vent,
    ];
  }

  void updateVent(Vent vent) {
    state = [
      for (final existingVent in state)
        if (existingVent.id == vent.id) vent else existingVent,
    ];
  }

  void removeVent(String ventId) {
    state = [
      for (final vent in state)
        if (vent.id != ventId) vent,
    ];
  }
}

final ventProvider =
    NotifierProvider<VentNotifier, List<Vent>>(
  VentNotifier.new,
);
