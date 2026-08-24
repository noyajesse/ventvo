import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vent.dart';
import '../services/vent_storage.dart';

class VentNotifier extends AsyncNotifier<List<Vent>> {
  final VentStorage _storage = VentStorage();

  @override
  Future<List<Vent>> build() async {
    return _storage.load();
  }

  Future<void> _persist(List<Vent> vents) async {
    state = AsyncData(vents);
    await _storage.save(vents);
  }

  Future<void> addVent(Vent vent) async {
    final vents = [
      ...state.asData?.value ?? const <Vent>[],
      vent,
    ];
    await _persist(vents);
  }

  Future<void> updateVent(Vent vent) async {
    final current = state.asData?.value ?? const <Vent>[];
    final vents = [
      for (final existingVent in current)
        if (existingVent.id == vent.id) vent else existingVent,
    ];
    await _persist(vents);
  }

  Future<void> removeVent(String ventId) async {
    final current = state.asData?.value ?? const <Vent>[];
    final vents = [
      for (final vent in current)
        if (vent.id != ventId) vent,
    ];
    await _persist(vents);
  }

  Future<void> clearVents() async {
    await _storage.clear();
    state = const AsyncData([]);
  }
}

final ventProvider =
    AsyncNotifierProvider<VentNotifier, List<Vent>>(
  VentNotifier.new,
);
