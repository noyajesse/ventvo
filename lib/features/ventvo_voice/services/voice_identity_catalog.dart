import '../models/voice_mark.dart';
import '../models/voice_seed.dart';

class VoiceIdentityCatalog {
  const VoiceIdentityCatalog._();

  static const marks = <VoiceMark>[
    VoiceMark(id: 'vaelor', symbol: '◇', family: VoiceMarkFamily.quiet),
    VoiceMark(id: 'nyven', symbol: '∿', family: VoiceMarkFamily.flowing),
    VoiceMark(id: 'auren', symbol: '✦', family: VoiceMarkFamily.luminous),
    VoiceMark(id: 'senya', symbol: '○', family: VoiceMarkFamily.open),
    VoiceMark(id: 'orvan', symbol: '△', family: VoiceMarkFamily.grounded),
    VoiceMark(id: 'elvae', symbol: '≈', family: VoiceMarkFamily.flowing),
    VoiceMark(id: 'nareth', symbol: '◌', family: VoiceMarkFamily.quiet),
    VoiceMark(id: 'veyra', symbol: '✧', family: VoiceMarkFamily.luminous),
    VoiceMark(id: 'kaven', symbol: '⟡', family: VoiceMarkFamily.open),
  ];

  static const seeds = <VoiceSeed>[
    VoiceSeed(
      id: 'vaelor',
      word: 'VAELOR',
      mark: VoiceMark(id: 'vaelor', symbol: '◇', family: VoiceMarkFamily.quiet),
      concept: VoiceSeedConcept.expression,
      essence: 'Expression',
      meaning: 'Giving an inner thought form.',
      feeling: 'I need somewhere to put this.',
      productConnection: 'Vent',
    ),
    VoiceSeed(
      id: 'nyven',
      word: 'NYVEN',
      mark: VoiceMark(id: 'nyven', symbol: '∿', family: VoiceMarkFamily.flowing),
      concept: VoiceSeedConcept.resonance,
      essence: 'Resonance',
      meaning: 'Recognizing yourself in another experience.',
      feeling: 'Someone else feels this too.',
      productConnection: 'Resonance',
    ),
    VoiceSeed(
      id: 'auren',
      word: 'AUREN',
      mark: VoiceMark(id: 'auren', symbol: '✦', family: VoiceMarkFamily.luminous),
      concept: VoiceSeedConcept.becoming,
      essence: 'Becoming',
      meaning: 'Changing through what you experience.',
      feeling: "I'm not who I was.",
      productConnection: 'Evolution',
    ),
    VoiceSeed(
      id: 'senya',
      word: 'SENYA',
      mark: VoiceMark(id: 'senya', symbol: '○', family: VoiceMarkFamily.open),
      concept: VoiceSeedConcept.heard,
      essence: 'Being heard',
      meaning: 'Being heard without demanding anything back.',
      feeling: 'You do not have to fix this.',
      productConnection: 'Just Listen',
    ),
    VoiceSeed(
      id: 'orvan',
      word: 'ORVAN',
      mark: VoiceMark(id: 'orvan', symbol: '△', family: VoiceMarkFamily.grounded),
      concept: VoiceSeedConcept.experience,
      essence: 'Experience',
      meaning: 'A lived experience carried by a person.',
      feeling: "I've been through this.",
      productConnection: 'Experience',
    ),
    VoiceSeed(
      id: 'elvae',
      word: 'ELVAE',
      mark: VoiceMark(id: 'elvae', symbol: '≈', family: VoiceMarkFamily.flowing),
      concept: VoiceSeedConcept.recognition,
      essence: 'Recognition',
      meaning: 'The point where two experiences recognize each other.',
      feeling: 'Wait... you understand.',
      productConnection: 'Resonance',
    ),
    VoiceSeed(
      id: 'nareth',
      word: 'NARETH',
      mark: VoiceMark(id: 'nareth', symbol: '◌', family: VoiceMarkFamily.quiet),
      concept: VoiceSeedConcept.silence,
      essence: 'Silence',
      meaning: 'The space between what is said and what is answered.',
      feeling: 'Let this breathe.',
      productConnection: 'Listening',
    ),
    VoiceSeed(
      id: 'veyra',
      word: 'VEYRA',
      mark: VoiceMark(id: 'veyra', symbol: '✧', family: VoiceMarkFamily.luminous),
      concept: VoiceSeedConcept.imprint,
      essence: 'Imprint',
      meaning: 'The trace an experience leaves behind.',
      feeling: 'This changed something in me.',
      productConnection: 'Memory / Evolution',
    ),
    VoiceSeed(
      id: 'kaven',
      word: 'KAVEN',
      mark: VoiceMark(id: 'kaven', symbol: '⟡', family: VoiceMarkFamily.open),
      concept: VoiceSeedConcept.perspective,
      essence: 'Perspective',
      meaning: 'The meeting point between different perspectives.',
      feeling: 'I do not see it your way, but I see you.',
      productConnection: 'Open Discussion',
    ),
  ];

  static const names = <String>[
    'VAELOR',
    'NYVEN',
    'AUREN',
    'SENYA',
    'ORVAN',
    'ELVAE',
    'NARETH',
    'VEYRA',
    'KAVEN',
  ];

  static VoiceMark markById(String id) {
    return marks.firstWhere(
      (mark) => mark.id == id,
      orElse: () => marks.first,
    );
  }

  static VoiceMark markBySymbol(String symbol) {
    return marks.firstWhere(
      (mark) => mark.symbol == symbol,
      orElse: () => marks.first,
    );
  }

  static VoiceSeed seedById(String id) {
    return seeds.firstWhere(
      (seed) => seed.id == id,
      orElse: () => seeds.first,
    );
  }

  static VoiceSeed seedByWord(String word) {
    return seeds.firstWhere(
      (seed) => seed.word == word,
      orElse: () => seeds.first,
    );
  }
}
