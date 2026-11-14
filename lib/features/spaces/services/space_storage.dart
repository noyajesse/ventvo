import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/space.dart';

class SpaceStorage {
  SpaceStorage({this.prefs});

  static const _spacesKey = 'ventvo_spaces';
  final SharedPreferences? prefs;

  Future<SharedPreferences> get _instance async =>
      prefs ?? await SharedPreferences.getInstance();

  Future<List<Space>> load() async {
    final storage = await _instance;
    final raw = storage.getString(_spacesKey);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final spaces = <Space>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final parsed = _fromMap(item);
          if (parsed != null) spaces.add(parsed);
        }
      }
      return spaces;
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<Space> spaces) async {
    final storage = await _instance;
    final raw = jsonEncode(spaces.map(_toMap).toList());
    final saved = await storage.setString(_spacesKey, raw);
    if (!saved) {
      throw StateError('Failed to persist spaces to local storage.');
    }
  }

  Future<void> clear() async {
    final storage = await _instance;
    final removed = await storage.remove(_spacesKey);
    if (!removed) {
      throw StateError('Failed to clear spaces from local storage.');
    }
  }

  Map<String, dynamic> _toMap(Space space) {
    return {
      'id': space.id,
      'mode': space.mode.name,
      'originatingVentId': space.originatingVentId,
      'creatorVoiceMark': space.creatorVoiceMark,
      'createdAt': space.createdAt.toIso8601String(),
      'ventIds': space.allVentIds,
    };
  }

  Space? _fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final mode = map['mode'];
    final originatingVentId = map['originatingVentId'];
    final creatorVoiceMark = map['creatorVoiceMark'];
    final createdAt = map['createdAt'];
    final savedVentIds = map['ventIds'];

    if (id is! String ||
        mode is! String ||
        originatingVentId is! String ||
        creatorVoiceMark is! String ||
        createdAt is! String) {
      return null;
    }

    final parsedMode = SpaceMode.values
        .where((item) => item.name == mode)
        .firstOrNull;
    final parsedCreatedAt = DateTime.tryParse(createdAt);

    if (parsedMode == null || parsedCreatedAt == null) return null;

    final ventIds = savedVentIds is List
        ? savedVentIds.whereType<String>().toList()
        : <String>[];

    return Space(
      id: id,
      mode: parsedMode,
      originatingVentId: originatingVentId,
      creatorVoiceMark: creatorVoiceMark,
      createdAt: parsedCreatedAt,
      ventIds: ventIds,
    );
  }
}
