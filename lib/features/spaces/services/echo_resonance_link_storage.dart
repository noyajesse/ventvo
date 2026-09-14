import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/echo_resonance_link.dart';

class EchoResonanceLinkStorage {
  static const _linksKey = 'ventvo_echo_resonance_links';

  Future<EchoResonanceLink?> loadForEcho(String echoId) async {
    final links = await _loadAll();
    for (final link in links) {
      if (link.echoId == echoId) return link;
    }
    return null;
  }

  Future<void> save(EchoResonanceLink link) async {
    final links = await _loadAll();
    final index = links.indexWhere((item) => item.echoId == link.echoId);

    if (index == -1) {
      links.add(link);
    } else {
      links[index] = link;
    }

    await _saveAll(links);
  }

  Future<List<EchoResonanceLink>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_linksKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fromMap)
          .whereType<EchoResonanceLink>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<EchoResonanceLink> links) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _linksKey,
      jsonEncode(links.map(_toMap).toList()),
    );
  }

  Map<String, dynamic> _toMap(EchoResonanceLink link) {
    return {
      'echoId': link.echoId,
      'connectionId': link.connectionId,
      'createdAt': link.createdAt.toIso8601String(),
    };
  }

  EchoResonanceLink? _fromMap(Map<String, dynamic> map) {
    final echoId = map['echoId'];
    final connectionId = map['connectionId'];
    final createdAt = map['createdAt'];

    if (echoId is! String ||
        connectionId is! String ||
        createdAt is! String ||
        echoId.trim().isEmpty ||
        connectionId.trim().isEmpty) {
      return null;
    }

    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) return null;

    return EchoResonanceLink(
      echoId: echoId,
      connectionId: connectionId,
      createdAt: parsedCreatedAt,
    );
  }
}
