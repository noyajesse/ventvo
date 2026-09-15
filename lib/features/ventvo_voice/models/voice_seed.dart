import 'voice_mark.dart';

enum VoiceSeedConcept {
  expression,
  resonance,
  becoming,
  heard,
  experience,
  recognition,
  silence,
  imprint,
  perspective,
}

class VoiceSeed {
  final String id;
  final String word;
  final VoiceMark mark;
  final VoiceSeedConcept concept;
  final String essence;
  final String meaning;
  final String feeling;
  final String productConnection;

  const VoiceSeed({
    required this.id,
    required this.word,
    required this.mark,
    required this.concept,
    required this.essence,
    required this.meaning,
    required this.feeling,
    required this.productConnection,
  });
}
