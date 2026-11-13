import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/crash_out.dart';

class CrashOutStorage {
  static const _key = 'ventvo_crash_outs';

  Future<List<CrashOut>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return [
        for (final item in decoded)
          if (item is Map<String, dynamic>) _fromJson(item),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<CrashOut> crashOuts) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _key,
      jsonEncode(crashOuts.map(_toJson).toList()),
    );
    if (!saved) {
      throw StateError('Failed to persist private Crash Outs locally.');
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final existed = prefs.containsKey(_key);
    final removed = await prefs.remove(_key);
    if (existed && !removed) {
      throw StateError('Failed to clear private Crash Outs locally.');
    }
  }

  Map<String, dynamic> _toJson(CrashOut crashOut) {
    return {
      'id': crashOut.id,
      'ownerVoiceId': crashOut.ownerVoiceId,
      'textContent': crashOut.textContent,
      'audioPath': crashOut.audioPath,
      'type': crashOut.type.name,
      'createdAt': crashOut.createdAt.toIso8601String(),
      'status': crashOut.status.name,
      'spaceId': crashOut.spaceId,
      'matchedExperienceId': crashOut.matchedExperienceId,
    };
  }

  CrashOut _fromJson(Map<String, dynamic> json) {
    return CrashOut(
      id: json['id'] as String,
      ownerVoiceId: json['ownerVoiceId'] is String
          ? json['ownerVoiceId'] as String
          : null,
      textContent: json['textContent'] as String?,
      audioPath: json['audioPath'] as String?,
      type: _parseType(json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: _parseStatus(json['status']),
      spaceId: json['spaceId'] is String ? json['spaceId'] as String : null,
      matchedExperienceId: json['matchedExperienceId'] is String
          ? json['matchedExperienceId'] as String
          : null,
    );
  }

  CrashOutType _parseType(Object? value) {
    return CrashOutType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CrashOutType.text,
    );
  }

  CrashOutStatus _parseStatus(Object? value) {
    return CrashOutStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => CrashOutStatus.keptPrivate,
    );
  }
}