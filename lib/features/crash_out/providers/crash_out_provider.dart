import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../services/crash_out_opposite_experience_service.dart';
import '../services/crash_out_storage.dart';

class CrashOutNotifier extends AsyncNotifier<List<CrashOut>> {
  final CrashOutStorage _storage = CrashOutStorage();

  @override
  Future<List<CrashOut>> build() async {
    return _storage.load();
  }

  Future<void> _persist(List<CrashOut> crashOuts) async {
    state = AsyncData(crashOuts);
    await _storage.save(crashOuts);
  }

  Future<void> addCrashOut(CrashOut crashOut) async {
    final current = state.asData?.value ?? const <CrashOut>[];
    await _persist([...current, crashOut]);
  }

  Future<void> keepPrivate(String id) async {
    final current = state.asData?.value ?? const <CrashOut>[];
    await _persist([
      for (final crashOut in current)
        crashOut.id == id
            ? crashOut.copyWith(status: CrashOutStatus.keptPrivate)
            : crashOut,
    ]);
  }

  Future<void> markConvertedToVent(String id) async {
    final current = state.asData?.value ?? const <CrashOut>[];
    await _persist([
      for (final crashOut in current)
        crashOut.id == id
            ? crashOut.copyWith(status: CrashOutStatus.convertedToVent)
            : crashOut,
    ]);
  }

  Future<void> deleteCrashOut(String id) async {
    final current = state.asData?.value ?? const <CrashOut>[];
    await _persist(
      current.where((crashOut) => crashOut.id != id).toList(),
    );
  }

  Future<void> clearCrashOuts() async {
    await _storage.clear();
    state = const AsyncData([]);
  }
}

final crashOutProvider =
    AsyncNotifierProvider<CrashOutNotifier, List<CrashOut>>(
  CrashOutNotifier.new,
);

final crashOutOppositeExperienceServiceProvider =
    Provider<CrashOutOppositeExperienceService>((ref) {
  return const CrashOutOppositeExperienceService();
});
