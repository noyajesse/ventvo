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

  CrashOutReflection? reflectionForThread(String threadId) {
    final current = state.asData?.value ?? const <CrashOutReflection>[];
    for (final reflection in current) {
      if (reflection.threadId == threadId) return reflection;
    }
    return null;
  }

  Future<void> addReflection(CrashOutReflection reflection) async {
    final current = state.asData?.value ?? const <CrashOutReflection>[];
    final next = [
      for (final item in current)
        if (item.threadId != reflection.threadId) item,
      reflection,
    ];
    state = AsyncData(next);
    await _storage.save(next);
  }

  Future<void> deleteReflectionsForCrashOut(String crashOutId) async {
    final current =
        state.asData?.value ?? const <CrashOutReflection>[];
    final next = current
        .where((reflection) => reflection.crashOutId != crashOutId)
        .toList();
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
