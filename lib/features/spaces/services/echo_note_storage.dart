import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/echo_note.dart';

class EchoNoteStorage {
  static const _notesKey = 'ventvo_echo_notes';

  Future<List<EchoNote>> loadForEcho(String echoId) async {
    final notes = await _loadAll();
    return notes.where((note) => note.echoId == echoId).toList();
  }

  Future<List<EchoNote>> loadForSpace(String spaceId) async {
    final notes = await _loadAll();
    return notes.where((note) => note.spaceId == spaceId).toList();
  }

  Future<void> add(EchoNote note) async {
    final notes = await _loadAll();
    notes.add(note);
    await _saveAll(notes);
  }

  Future<List<EchoNote>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromMap)
          .whereType<EchoNote>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<EchoNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notesKey,
      jsonEncode(notes.map(_toMap).toList()),
    );
  }

  Map<String, dynamic> _toMap(EchoNote note) {
    return {
      'id': note.id,
      'echoId': note.echoId,
      'spaceId': note.spaceId,
      'ventId': note.ventId,
      'voiceMark': note.voiceMark,
      'content': note.content,
      'createdAt': note.createdAt.toIso8601String(),
    };
  }

  EchoNote? _fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final echoId = map['echoId'];
    final spaceId = map['spaceId'];
    final ventId = map['ventId'];
    final voiceMark = map['voiceMark'];
    final content = map['content'];
    final createdAt = map['createdAt'];

    if (id is! String ||
        echoId is! String ||
        spaceId is! String ||
        (ventId != null && ventId is! String) ||
        voiceMark is! String ||
        content is! String ||
        createdAt is! String) {
      return null;
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) return null;

    return EchoNote(
      id: id,
      echoId: echoId,
      spaceId: spaceId,
      ventId: ventId as String?,
      voiceMark: voiceMark,
      content: content,
      createdAt: parsedCreatedAt,
    );
  }
}
