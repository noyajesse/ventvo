import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out_reflection.dart';
import '../services/crash_out_reflection_storage.dart';

class CrashOutReflectionNotifier
    extends AsyncNotifier<List<CrashOutReflection>> {
  final CrashOutReflectionStorage _storage = CrashOutReflectionStorage();

  @override
  Future<List<CrashOutReflection>> build() async {
    return _storage.load();
  }

  Future<void> addReflection(CrashOutReflection reflection) async {
    final current = state.asData?.value ?? const <CrashOutReflection>[];
    final next = [...current, reflection];
    state = AsyncData(next);
    await _storage.save(next);
  }

  Future<void> clearReflections() async {
    await _storage.clear();
    state = const AsyncData([]);
  }
}

final crashOutReflectionProvider = AsyncNotifierProvider<
    CrashOutReflectionNotifier, List<CrashOutReflection>>(
  CrashOutReflectionNotifier.new,
);
