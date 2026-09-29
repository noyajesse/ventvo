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
    final responses = await _loadAll();
    responses.add(response);
    await _saveAll(responses);
  }

  Future<void> update(SpaceResponse response) async {
    final responses = await _loadAll();
    final index = responses.indexWhere((item) => item.id == response.id);
    if (index == -1) return;
    responses[index] = response;
    await _saveAll(responses);
  }

  Future<List<SpaceResponse>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_responsesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromMap)
          .whereType<SpaceResponse>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<SpaceResponse> responses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _responsesKey,
      jsonEncode(responses.map(_toMap).toList()),
    );
  }

  Map<String, dynamic> _toMap(SpaceResponse response) {
    return {
      'id': response.id,
      'spaceId': response.spaceId,
      'ventId': response.ventId,
      'voiceMark': response.voiceMark,
      'authorVoiceId': response.authorVoiceId,
      'content': response.content,
      'createdAt': response.createdAt.toIso8601String(),
      'isMoment': response.isMoment,
      'isHeard': response.isHeard,
      'echoKind': response.echoKind?.name,
    };
  }

  SpaceResponse? _fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final spaceId = map['spaceId'];
    final ventId = map['ventId'];
    final voiceMark = map['voiceMark'];
    final authorVoiceId = map['authorVoiceId'];
    final content = map['content'];
    final createdAt = map['createdAt'];
    final isMoment = map['isMoment'];
    final isHeard = map['isHeard'];
    final echoKind = map['echoKind'];

    if (id is! String ||
        spaceId is! String ||
        (ventId != null && ventId is! String) ||
        voiceMark is! String ||
        (authorVoiceId != null && authorVoiceId is! String) ||
        content is! String ||
        createdAt is! String ||
        (isMoment != null && isMoment is! bool) ||
        (isHeard != null && isHeard is! bool) ||
        (echoKind != null && echoKind is! String)) {
      return null;
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) return null;

    EchoKind? parsedEchoKind;
    if (echoKind != null) {
      parsedEchoKind = EchoKind.values.where((kind) => kind.name == echoKind).firstOrNull;
    }

    return SpaceResponse(
      id: id,
      spaceId: spaceId,
      ventId: ventId as String?,
      voiceMark: voiceMark,
      authorVoiceId: authorVoiceId as String?,
      content: content,
      createdAt: parsedCreatedAt,
      isMoment: isMoment as bool? ?? false,
      isHeard: isHeard as bool? ?? false,
      echoKind: parsedEchoKind,
    );
  }
}
