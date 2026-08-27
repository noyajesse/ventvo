import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/space.dart';
import '../services/space_storage.dart';

final spaceProvider =
    AsyncNotifierProvider<SpaceNotifier, List<Space>>(SpaceNotifier.new);

class SpaceNotifier extends AsyncNotifier<List<Space>> {
  final SpaceStorage _storage = SpaceStorage();

  @override
  Future<List<Space>> build() async => _storage.load();

  Future<void> _persist(List<Space> spaces) async {
    state = AsyncData(spaces);
    await _storage.save(spaces);
  }

  Future<void> addSpace(Space space) async {
    final spaces = [...state.asData?.value ?? const <Space>[], space];
    await _persist(spaces);
  }

  Future<void> updateSpace(Space space) async {
    final current = state.asData?.value ?? const <Space>[];
    final spaces = [
      for (final existing in current)
        if (existing.id == space.id) space else existing,
    ];
    await _persist(spaces);
  }

  Future<void> addMoment(String spaceId, String ventId) async {
    final current = state.asData?.value ?? const <Space>[];
    final spaces = [
      for (final space in current)
        if (space.id == spaceId && !space.allVentIds.contains(ventId))
          Space(
            id: space.id,
            mode: space.mode,
            originatingVentId: space.originatingVentId,
            creatorVoiceMark: space.creatorVoiceMark,
            createdAt: space.createdAt,
            ventIds: [...space.allVentIds, ventId],
          )
        else
          space,
    ];
    await _persist(spaces);
  }

  Future<void> removeSpace(String id) async {
    final current = state.asData?.value ?? const <Space>[];
    await _persist(current.where((space) => space.id != id).toList());
  }

  Future<void> clearSpaces() async {
    await _storage.clear();
    state = const AsyncData([]);
  }
}
