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

  // Serialize mutations so simultaneous replies cannot overwrite one another.
  Future<void> _mutationQueue = Future<void>.value();

  Future<T> _runMutation<T>(Future<T> Function() mutation) {
    final result = _mutationQueue.then((_) => mutation());
    // A failed write must not block later attempts.
    _mutationQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

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
        final replies = <CrashOutSpaceReply>[];
        for (final item in entry.value as List) {
          if (item is Map<String, dynamic>) {
            final reply = CrashOutSpaceReply.fromMap(item);
            if (reply != null) replies.add(reply);
          }
        }
        result[entry.key as String] = replies;
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, List<CrashOutSpaceReply>>> _currentReplies() async {
    final current = state.asData?.value;
    if (current != null) return current;
    return future;
  }

  String _key(String spaceId, String experienceId) =>
      '$spaceId::$experienceId';

  List<CrashOutSpaceReply> repliesFor(String spaceId, String experienceId) {
    final current =
        state.asData?.value ?? const <String, List<CrashOutSpaceReply>>{};
    return current[_key(spaceId, experienceId)] ?? const [];
  }

  Future<bool> _persist(
    Map<String, List<CrashOutSpaceReply>> replies,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _storageKey,
      jsonEncode({
        for (final entry in replies.entries)
          entry.key: entry.value.map((item) => item.toMap()).toList(),
      }),
    );
    if (!saved) return false;
    state = AsyncData(replies);
    return true;
  }

  /// Adds missing fictional preview replies without replacing local replies.
  /// The UI discloses that these examples are not real user activity.
  Future<void> ensurePrototypeReplies({
    required String spaceId,
    required List<CrashOutSpaceReply> prototypes,
  }) {
    if (spaceId.trim().isEmpty || prototypes.isEmpty) {
      return Future<void>.value();
    }

    return _runMutation(() async {
      final current = await _currentReplies();
      final updated = <String, List<CrashOutSpaceReply>>{
        for (final entry in current.entries) entry.key: [...entry.value],
      };
      var changed = false;

      for (final reply in prototypes) {
        if (reply.id.trim().isEmpty ||
            reply.experienceId.trim().isEmpty ||
            reply.content.trim().isEmpty) {
          continue;
        }
        final key = _key(spaceId, reply.experienceId);
        final existing = updated[key] ?? const <CrashOutSpaceReply>[];
        if (existing.any((item) => item.id == reply.id)) continue;
        updated[key] = [...existing, reply];
        changed = true;
      }

      if (!changed) return;
      if (!await _persist(updated)) {
        throw StateError('Failed to persist Crash Out Space replies locally.');
      }
    });
  }

  Future<bool> addReply({
    required String spaceId,
    required String experienceId,
    required CrashOutSpaceReply reply,
  }) {
    return _runMutation(() async {
      if (spaceId.trim().isEmpty ||
          experienceId.trim().isEmpty ||
          reply.id.trim().isEmpty ||
          reply.experienceId != experienceId ||
          reply.content.trim().isEmpty) {
        return false;
      }

      // Wait for initial storage loading before taking a snapshot.
      final current = await _currentReplies();
      final key = _key(spaceId, experienceId);
      final existing = current[key] ?? const <CrashOutSpaceReply>[];

      // Continued replies must point to a reply on this same experience.
      final replyToId = reply.replyToId;
      if (replyToId != null &&
          !existing.any((item) => item.id == replyToId)) {
        return false;
      }
      if (existing.any((item) => item.id == reply.id)) return false;

      final updated = <String, List<CrashOutSpaceReply>>{
        ...current,
        key: [...existing, reply],
      };
      return _persist(updated);
    });
  }

  Future<void> clearReplies() {
    return _runMutation(() async {
      await _currentReplies();
      final prefs = await SharedPreferences.getInstance();
      final existed = prefs.containsKey(_storageKey);
      final removed = await prefs.remove(_storageKey);
      if (existed && !removed) {
        throw StateError('Failed to clear Crash Out Space replies locally.');
      }
      state = const AsyncData(<String, List<CrashOutSpaceReply>>{});
    });
  }
}

final crashOutSpaceProvider = AsyncNotifierProvider<
    CrashOutSpaceNotifier, Map<String, List<CrashOutSpaceReply>>>(
  CrashOutSpaceNotifier.new,
);
