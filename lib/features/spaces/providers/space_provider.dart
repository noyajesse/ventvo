import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/space.dart';

final spaceProvider =
    NotifierProvider<SpaceNotifier, List<Space>>(SpaceNotifier.new);

class SpaceNotifier extends Notifier<List<Space>> {
  @override
  List<Space> build() {
    return [];
  }

  Space? getById(String id) {
    for (final space in state) {
      if (space.id == id) {
        return space;
      }
    }

    return null;
  }

  void addSpace(Space space) {
    state = [...state, space];
  }

  void removeSpace(String id) {
    state = state.where((space) => space.id != id).toList();
  }
}