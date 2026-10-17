import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrashOutSpaceReply {
  final String id;
  final String experienceId;
  final String content;
  final DateTime createdAt;
  final String? voiceName;
  final String? voiceMark;
  final String? replyToId;

  const CrashOutSpaceReply({
    required this.id,
    required this.experienceId,
    required this.content,
    required this.createdAt,
    this.voiceName,
    this.voiceMark,
    this.replyToId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'experienceId': experienceId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'voiceName': voiceName,
        'voiceMark': voiceMark,
        'replyToId': replyToId,
      };

  static CrashOutSpaceReply? fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final experienceId = map['experienceId'];
    final content = map['content'];
    final createdAt = map['createdAt'];
    if (id is! String ||
        id.trim().isEmpty ||
        experienceId is! String ||
        experienceId.trim().isEmpty ||
        content is! String ||
        content.trim().isEmpty ||
        createdAt is! String) {
      return null;
    }

    final parsedDate = DateTime.tryParse(createdAt);
    if (parsedDate == null) return null;

    return CrashOutSpaceReply(
      id: id,
      experienceId: experienceId,
      content: content,
      createdAt: parsedDate,
      voiceName: map['voiceName'] is String ? map['voiceName'] as String : null,
      voiceMark: map['voiceMark'] is String ? map['voiceMark'] as String : null,
      replyToId: map['replyToId'] is String ? map['replyToId'] as String : null,
    );
  }
}

/// Frontend-only local reply persistence. This is a prototype boundary, not
/// shared/realtime storage between users.
class CrashOutSpaceNotifier
    extends AsyncNotifier<Map<String, List<CrashOutSpaceReply>>> {
  static const _storageKey = 'ventvo_crash_out_space_replies';

  @override
  Future<Map<String, List<CrashOutSpaceReply>>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};

      final result = <String, List<CrashOutSpaceReply>>{};
      for (final entry in decoded.entries) {
        if (entry.key is! String || entry.value is! List) continue;
        result[entry.key as String] = [
          for (final item in (entry.value as List))
            if (item is Map<String, dynamic>)
              if (CrashOutSpaceReply.fromMap(item) case final reply?)
                reply,
        ];
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  String _key(String spaceId, String experienceId) =>
      '$spaceId::$experienceId';

  List<CrashOutSpaceReply> repliesFor(String spaceId, String experienceId) {
    final current = state.asData?.value ?? const {};
    return current[_key(spaceId, experienceId)] ?? const [];
  }

  Future<void> addReply({
    required String spaceId,
    required String experienceId,
    required CrashOutSpaceReply reply,
  }) async {
    if (spaceId.trim().isEmpty ||
        experienceId.trim().isEmpty ||
        reply.id.trim().isEmpty ||
        reply.experienceId != experienceId ||
        reply.content.trim().isEmpty) {
      return;
    }

    final current = state.asData?.value ?? const <String, List<CrashOutSpaceReply>>{};
    final key = _key(spaceId, experienceId);
    final existing = current[key] ?? const <CrashOutSpaceReply>[];
    if (existing.any((item) => item.id == reply.id)) return;

    final updated = <String, List<CrashOutSpaceReply>>{
      ...current,
      key: [...existing, reply],
    };
    state = AsyncData(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        for (final entry in updated.entries)
          entry.key: entry.value.map((item) => item.toMap()).toList(),
      }),
    );
  }

  Future<void> clearReplies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    state = const AsyncData({});
  }
}

final crashOutSpaceProvider = AsyncNotifierProvider<
    CrashOutSpaceNotifier, Map<String, List<CrashOutSpaceReply>>>(
  CrashOutSpaceNotifier.new,
);
