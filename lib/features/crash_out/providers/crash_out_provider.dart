
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

  void updateStatus(
    String id,
    CrashOutStatus status,
  ) {
    state = [
      for (final crashOut in state)
        if (crashOut.id == id)
          CrashOut(
            id: crashOut.id,
            textContent: crashOut.textContent,
            audioPath: crashOut.audioPath,
            type: crashOut.type,
            createdAt: crashOut.createdAt,
            status: status,
            matchingEligible:
                crashOut.matchingEligible,
            connectionNeed:
                crashOut.connectionNeed,
          )
        else
          crashOut,
    ];
  }

  void enableMatching(String id) {
    state = [
      for (final crashOut in state)
        if (crashOut.id == id)
          CrashOut(
            id: crashOut.id,
            textContent: crashOut.textContent,
            audioPath: crashOut.audioPath,
            type: crashOut.type,
            createdAt: crashOut.createdAt,
            status: CrashOutStatus.findingPeople,
            matchingEligible: true,
            connectionNeed:
                crashOut.connectionNeed,
          )
        else
          crashOut,
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
    NotifierProvider<
      CrashOutNotifier,
      List<CrashOut>
    >(
  CrashOutNotifier.new,
);

