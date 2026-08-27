import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/space_response.dart';

class SpaceResponseStorage {
  static const _responsesKey = 'ventvo_space_responses';

  Future<List<SpaceResponse>> loadForSpace(String spaceId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_responsesKey);

    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromMap)
          .whereType<SpaceResponse>()
          .where((response) => response.spaceId == spaceId)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(SpaceResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_responsesKey);

    List<dynamic> decoded = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        final value = jsonDecode(raw);
        if (value is List) decoded = value;
      } catch (_) {
        decoded = [];
      }
    }

    decoded.add(_toMap(response));
    await prefs.setString(_responsesKey, jsonEncode(decoded));
  }

  Map<String, dynamic> _toMap(SpaceResponse response) {
    return {
      'id': response.id,
      'spaceId': response.spaceId,
      'ventId': response.ventId,
      'voiceMark': response.voiceMark,
      'content': response.content,
      'createdAt': response.createdAt.toIso8601String(),
      'isMoment': response.isMoment,
    };
  }

  SpaceResponse? _fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final spaceId = map['spaceId'];
    final ventId = map['ventId'];
    final voiceMark = map['voiceMark'];
    final content = map['content'];
    final createdAt = map['createdAt'];
    final isMoment = map['isMoment'];

    if (id is! String ||
        spaceId is! String ||
        (ventId != null && ventId is! String) ||
        voiceMark is! String ||
        content is! String ||
        createdAt is! String ||
        (isMoment != null && isMoment is! bool)) {
      return null;
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) return null;

    return SpaceResponse(
      id: id,
      spaceId: spaceId,
      ventId: ventId as String?,
      voiceMark: voiceMark,
      content: content,
      createdAt: parsedCreatedAt,
      isMoment: isMoment as bool? ?? false,
    );
  }
}
