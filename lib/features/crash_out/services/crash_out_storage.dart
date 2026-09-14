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
    await prefs.setString(
      _key,
      jsonEncode(crashOuts.map(_toJson).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Map<String, dynamic> _toJson(CrashOut crashOut) {
    return {
      'id': crashOut.id,
      'textContent': crashOut.textContent,
      'audioPath': crashOut.audioPath,
      'type': crashOut.type.name,
      'createdAt': crashOut.createdAt.toIso8601String(),
      'status': crashOut.status.name,
    };
  }

  CrashOut _fromJson(Map<String, dynamic> json) {
    return CrashOut(
      id: json['id'] as String,
      textContent: json['textContent'] as String?,
      audioPath: json['audioPath'] as String?,
      type: CrashOutType.values.byName(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: CrashOutStatus.values.byName(json['status'] as String),
    );
  }
}