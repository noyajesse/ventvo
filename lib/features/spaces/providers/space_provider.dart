import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/space.dart';
import '../services/space_storage.dart';

final spaceProvider =
    AsyncNotifierProvider<SpaceNotifier, List<Space>>(SpaceNotifier.new);

class SpaceNotifier extends AsyncNotifier<List<Space>> {
  final SpaceStorage _storage = SpaceStorage();

  @override
  Future<List<Space>> build() async {
    return _storage.load();
  }

  Future<void> addSpace(Space space) async {
    final spaces = [
      ...state.asData?.value ?? const <Space>[],
      space,
    ];
    state = AsyncData(spaces);
    await _storage.save(spaces);
  }

  Future<void> removeSpace(String id) async {
    final current = state.asData?.value ?? const <Space>[];
    final spaces = current.where((space) => space.id != id).toList();
    state = AsyncData(spaces);
    await _storage.save(spaces);
  }

  Future<void> clearSpaces() async {
    await _storage.clear();
    state = const AsyncData([]);
  }
}
