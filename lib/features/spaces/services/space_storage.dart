import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/space.dart';

class SpaceStorage {
  static const _spacesKey = 'ventvo_spaces';

  Future<List<Space>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_spacesKey);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromMap)
          .whereType<Space>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<Space> spaces) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(spaces.map(_toMap).toList());
    await prefs.setString(_spacesKey, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spacesKey);
  }

  Map<String, dynamic> _toMap(Space space) {
    return {
      'id': space.id,
      'mode': space.mode.name,
      'originatingVentId': space.originatingVentId,
      'creatorVoiceMark': space.creatorVoiceMark,
      'createdAt': space.createdAt.toIso8601String(),
    };
  }

  Space? _fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final mode = map['mode'];
    final originatingVentId = map['originatingVentId'];
    final creatorVoiceMark = map['creatorVoiceMark'];
    final createdAt = map['createdAt'];

    if (id is! String ||
        mode is! String ||
        originatingVentId is! String ||
        creatorVoiceMark is! String ||
        createdAt is! String) {
      return null;
    }

    final parsedMode = SpaceMode.values.where((item) => item.name == mode).firstOrNull;
    final parsedCreatedAt = DateTime.tryParse(createdAt);

    if (parsedMode == null || parsedCreatedAt == null) return null;

    return Space(
      id: id,
      mode: parsedMode,
      originatingVentId: originatingVentId,
      creatorVoiceMark: creatorVoiceMark,
      createdAt: parsedCreatedAt,
    );
  }
}
