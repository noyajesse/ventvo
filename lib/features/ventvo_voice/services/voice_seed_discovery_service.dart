import '../models/ventvo_voice.dart';
import '../models/voice_seed.dart';
import 'voice_identity_catalog.dart';

/// Determines a Voice Seed from the signals Ventvo already has.
///
/// Discovery is deterministic and explainable. It does not invent a
/// personality from thin air: an existing Seed name wins, otherwise the
/// current mark, resonance, and expression provide lightweight signals.
/// With no signals yet, VAELOR is the canonical first Seed.
class VoiceSeedDiscoveryService {
  const VoiceSeedDiscoveryService();

  VoiceSeed discover(VentvoVoice voice) {
    final existingSeed = _seedFromName(voice.name);
    if (existingSeed != null) return existingSeed;

    final scores = <String, int>{
      for (final seed in VoiceIdentityCatalog.seeds) seed.id: 0,
    };

    _scoreMark(scores, voice.mark);
    _scoreText(scores, voice.resonance, _resonanceSignals);
    _scoreText(scores, voice.expression, _expressionSignals);

    final best = VoiceIdentityCatalog.seeds.reduce((current, candidate) {
      final currentScore = scores[current.id] ?? 0;
      final candidateScore = scores[candidate.id] ?? 0;
      return candidateScore > currentScore ? candidate : current;
    });

    if ((scores[best.id] ?? 0) == 0) {
      return VoiceIdentityCatalog.seedById('vaelor');
    }

    return best;
  }

  VoiceSeed? _seedFromName(String? name) {
    if (name == null || name.trim().isEmpty) return null;

    for (final seed in VoiceIdentityCatalog.seeds) {
      if (seed.word.toLowerCase() == name.trim().toLowerCase()) {
        return seed;
      }
    }
    return null;
  }

  void _scoreMark(Map<String, int> scores, String? mark) {
    if (mark == null || mark.trim().isEmpty) return;

    for (final seed in VoiceIdentityCatalog.seeds) {
      if (seed.mark.symbol == mark.trim()) {
        scores[seed.id] = (scores[seed.id] ?? 0) + 4;
      }
    }
  }

  void _scoreText(
    Map<String, int> scores,
    String? value,
    Map<String, List<String>> signals,
  ) {
    if (value == null || value.trim().isEmpty) return;

    final normalized = value.trim().toLowerCase();
    for (final entry in signals.entries) {
      for (final signal in entry.value) {
        if (normalized.contains(signal)) {
          scores[entry.key] = (scores[entry.key] ?? 0) + 2;
        }
      }
    }
  }

  static const _resonanceSignals = <String, List<String>>{
    'vaelor': ['depth', 'reflection', 'thought', 'expression'],
    'nyven': ['flow', 'connection', 'resonance'],
    'auren': ['spark', 'change', 'growth', 'becoming'],
    'senya': ['stillness', 'heard', 'listen', 'listening'],
    'orvan': ['depth', 'experience', 'grounded', 'lived'],
    'elvae': ['flow', 'recognition', 'understanding'],
    'nareth': ['stillness', 'silence', 'quiet', 'space'],
    'veyra': ['horizon', 'memory', 'change', 'trace'],
    'kaven': ['horizon', 'perspective', 'discussion', 'different'],
  };

  static const _expressionSignals = <String, List<String>>{
    'vaelor': ['say', 'express', 'thought', 'put this', 'need somewhere'],
    'nyven': ['same', 'connect', 'understand', 'resonate'],
    'auren': ['change', 'growing', 'becoming', 'different'],
    'senya': ['listen', 'heard', 'without advice', 'do not fix'],
    'orvan': ['experience', 'been through', 'lived', 'happened'],
    'elvae': ['understand', 'recognize', 'same feeling'],
    'nareth': ['quiet', 'silence', 'breathe', 'pause'],
    'veyra': ['remember', 'changed me', 'left behind', 'memory'],
    'kaven': ['perspective', 'different view', 'disagree', 'discussion'],
  };
}
