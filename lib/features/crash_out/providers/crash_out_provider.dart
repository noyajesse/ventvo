import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';

class CrashOutNotifier extends Notifier<List<CrashOut>> {
  @override
  List<CrashOut> build() {
    return [];
  }

  void addCrashOut(CrashOut crashOut) {
    state = [
      ...state,
      crashOut,
    ];
  }

  void keepPrivate(String id) {
    state = [
      for (final crashOut in state)
        crashOut.id == id
            ? crashOut.copyWith(
                status: CrashOutStatus.keptPrivate,
              )
            : crashOut,
    ];
  }

  void markConvertedToVent(String id) {
    state = [
      for (final crashOut in state)
        crashOut.id == id
            ? crashOut.copyWith(
                status: CrashOutStatus.convertedToVent,
              )
            : crashOut,
    ];
  }

  void deleteCrashOut(String id) {
    state = state
        .where(
          (crashOut) => crashOut.id != id,
        )
        .toList();
  }
}

final crashOutProvider =
    NotifierProvider<CrashOutNotifier, List<CrashOut>>(
  CrashOutNotifier.new,
);