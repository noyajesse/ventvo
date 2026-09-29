import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/crash_out_reflection.dart';

class CrashOutReflectionStorage {
  static const _key = 'ventvo_crash_out_reflections';

  Future<List<CrashOutReflection>> load() async {
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

  Future<void> save(List<CrashOutReflection> reflections) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(reflections.map(_toJson).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Map<String, dynamic> _toJson(CrashOutReflection reflection) {
    return {
      'id': reflection.id,
      'crashOutId': reflection.crashOutId,
      'threadId': reflection.threadId,
      'content': reflection.content,
      'createdAt': reflection.createdAt.toIso8601String(),
    };
  }

  CrashOutReflection _fromJson(Map<String, dynamic> json) {
    return CrashOutReflection(
      id: json['id'] as String,
      crashOutId: json['crashOutId'] as String,
      threadId: json['threadId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
