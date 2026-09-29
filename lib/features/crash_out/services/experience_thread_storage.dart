import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/experience_thread.dart';

class ExperienceThreadStorage {
  static const _key = 'ventvo_experience_threads';

  Future<List<ExperienceThread>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromMap)
          .whereType<ExperienceThread>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<ExperienceThread> threads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(threads.map(_toMap).toList()),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Map<String, dynamic> _toMap(ExperienceThread thread) {
    return {
      'id': thread.id,
      'originCrashOutId': thread.originCrashOutId,
      'createdAt': thread.createdAt.toIso8601String(),
      'contributions': [
        for (final contribution in thread.contributions)
          {
            'id': contribution.id,
            'threadId': contribution.threadId,
            'content': contribution.content,
            'type': contribution.type.name,
            'createdAt': contribution.createdAt.toIso8601String(),
            'replyToId': contribution.replyToId,
            'sourceExperienceId': contribution.sourceExperienceId,
            'voiceName': contribution.voiceName,
            'voiceMark': contribution.voiceMark,
          },
      ],
    };
  }

  ExperienceThread? _fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final originCrashOutId = map['originCrashOutId'];
    final createdAt = map['createdAt'];
    final rawContributions = map['contributions'];

    if (id is! String ||
        id.trim().isEmpty ||
        originCrashOutId is! String ||
        originCrashOutId.trim().isEmpty ||
        createdAt is! String ||
        rawContributions is! List) {
      return null;
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) return null;

    final contributions = <ExperienceContribution>[];

    for (final item in rawContributions.whereType<Map<String, dynamic>>()) {
      final contribution = _contributionFromMap(
        item,
        expectedThreadId: id,
      );
      if (contribution != null) contributions.add(contribution);
    }

    return ExperienceThread(
      id: id,
      originCrashOutId: originCrashOutId,
      contributions: contributions,
      createdAt: parsedCreatedAt,
    );
  }

  ExperienceContribution? _contributionFromMap(
    Map<String, dynamic> map, {
    required String expectedThreadId,
  }) {
    final id = map['id'];
    final threadId = map['threadId'];
    final content = map['content'];
    final type = map['type'];
    final createdAt = map['createdAt'];

    if (id is! String ||
        id.trim().isEmpty ||
        threadId is! String ||
        threadId != expectedThreadId ||
        content is! String ||
        content.trim().isEmpty ||
        type is! String ||
        createdAt is! String) {
      return null;
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) return null;

    final contributionType = ExperienceContributionType.values.firstWhere(
      (item) => item.name == type,
      orElse: () => ExperienceContributionType.response,
    );

    final replyToId = map['replyToId'];
    final sourceExperienceId = map['sourceExperienceId'];
    final voiceName = map['voiceName'];
    final voiceMark = map['voiceMark'];

    return ExperienceContribution(
      id: id,
      threadId: threadId,
      content: content,
      type: contributionType,
      createdAt: parsedCreatedAt,
      replyToId: replyToId is String ? replyToId : null,
      sourceExperienceId:
          sourceExperienceId is String ? sourceExperienceId : null,
      voiceName: voiceName is String ? voiceName : null,
      voiceMark: voiceMark is String ? voiceMark : null,
    );
  }
}
