import 'package:shared_preferences/shared_preferences.dart';

import '../models/ventvo_voice.dart';

class VentvoVoiceStorage {
  static const _voiceIdKey = 'ventvo_voice_id';
  static const _seedIdKey = 'ventvo_voice_seed_id';
  static const _expressionKey = 'ventvo_voice_expression';
  static const _resonanceKey = 'ventvo_voice_resonance';
  static const _markKey = 'ventvo_voice_mark';
  static const _nameKey = 'ventvo_voice_name';
  static const _createdAtKey = 'ventvo_voice_created_at';

  Future<VentvoVoice?> load() async {
    final prefs = await SharedPreferences.getInstance();

    final createdAtValue = prefs.getString(_createdAtKey);
    if (createdAtValue == null) {
      return null;
    }

    final createdAt = DateTime.tryParse(createdAtValue);
    if (createdAt == null) {
      return null;
    }

    return VentvoVoice(
      voiceId: prefs.getString(_voiceIdKey),
      seedId: prefs.getString(_seedIdKey),
      expression: prefs.getString(_expressionKey),
      resonance: prefs.getString(_resonanceKey),
      mark: prefs.getString(_markKey),
      name: prefs.getString(_nameKey),
      createdAt: createdAt,
    );
  }

  Future<void> save(VentvoVoice voice) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      _setNullableString(prefs, _voiceIdKey, voice.voiceId),
      _setNullableString(prefs, _seedIdKey, voice.seedId),
      _setNullableString(prefs, _expressionKey, voice.expression),
      _setNullableString(prefs, _resonanceKey, voice.resonance),
      _setNullableString(prefs, _markKey, voice.mark),
      _setNullableString(prefs, _nameKey, voice.name),
      prefs.setString(_createdAtKey, voice.createdAt.toIso8601String()),
    ]);
  }

  Future<bool> _setNullableString(
    SharedPreferences prefs,
    String key,
    String? value,
  ) {
    if (value == null) {
      return prefs.remove(key);
    }

    return prefs.setString(key, value);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(_voiceIdKey),
      prefs.remove(_seedIdKey),
      prefs.remove(_expressionKey),
      prefs.remove(_resonanceKey),
      prefs.remove(_markKey),
      prefs.remove(_nameKey),
      prefs.remove(_createdAtKey),
    ]);
  }
}
