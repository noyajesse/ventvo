import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vent.dart';

class VentStorage {
  static const _ventsKey = 'ventvo_vents';

  Future<List<Vent>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ventsKey);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromMap)
          .whereType<Vent>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<Vent> vents) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(vents.map(_toMap).toList());
    await prefs.setString(_ventsKey, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ventsKey);
  }

  Map<String, dynamic> _toMap(Vent vent) {
    return {
      'id': vent.id,
      'content': vent.content,
      'spaceId': vent.spaceId,
      'voiceMark': vent.voiceMark,
      'voiceName': vent.voiceName,
      'createdAt': vent.createdAt.toIso8601String(),
      'intent': vent.intent.name,
      'visibility': vent.visibility.name,
      'safetyState': vent.safetyState.name,
      'originatingCrashOutId': vent.originatingCrashOutId,
    };
  }

  Vent? _fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final content = map['content'];
    final spaceId = map['spaceId'];
    final voiceMark = map['voiceMark'];
    final voiceName = map['voiceName'];
    final createdAt = map['createdAt'];

    if (id is! String ||
        content is! String ||
        spaceId is! String ||
        voiceMark is! String ||
        (voiceName != null && voiceName is! String) ||
        createdAt is! String) {
      return null;
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) return null;

    return Vent(
      id: id,
      content: content,
      spaceId: spaceId,
      voiceMark: voiceMark,
      voiceName: voiceName as String?,
      createdAt: parsedCreatedAt,
      intent: _parseIntent(map['intent']),
      visibility: _parseVisibility(map['visibility']),
      safetyState: _parseSafetyState(map['safetyState']),
      originatingCrashOutId: map['originatingCrashOutId'] as String?,
    );
  }

  VentIntent _parseIntent(Object? value) {
    return VentIntent.values.firstWhere(
      (item) => item.name == value,
      orElse: () => VentIntent.justListen,
    );
  }

  VentVisibility _parseVisibility(Object? value) {
    return VentVisibility.values.firstWhere(
      (item) => item.name == value,
      orElse: () => VentVisibility.public,
    );
  }

  VentSafetyState _parseSafetyState(Object? value) {
    return VentSafetyState.values.firstWhere(
      (item) => item.name == value,
      orElse: () => VentSafetyState.approved,
    );
  }
}
