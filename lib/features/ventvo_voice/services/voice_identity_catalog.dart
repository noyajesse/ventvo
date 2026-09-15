import '../models/voice_mark.dart';

class VoiceIdentityCatalog {
  const VoiceIdentityCatalog._();

  static const marks = <VoiceMark>[
    VoiceMark(id: 'quiet_point', symbol: '◇', family: VoiceMarkFamily.quiet),
    VoiceMark(id: 'open_circle', symbol: '○', family: VoiceMarkFamily.open),
    VoiceMark(id: 'grounded_triangle', symbol: '△', family: VoiceMarkFamily.grounded),
    VoiceMark(id: 'luminous_star', symbol: '✦', family: VoiceMarkFamily.luminous),
    VoiceMark(id: 'flow', symbol: '≈', family: VoiceMarkFamily.flowing),
    VoiceMark(id: 'current', symbol: '∿', family: VoiceMarkFamily.flowing),
    VoiceMark(id: 'unfinished_circle', symbol: '◌', family: VoiceMarkFamily.unfinished),
    VoiceMark(id: 'soft_light', symbol: '✧', family: VoiceMarkFamily.luminous),
  ];

  static const names = <String>[
    'Still Between',
    'After Rain',
    'Quiet Signal',
    'Half Awake',
    'Northbound',
    'Soft Static',
    'Unsaid',
    'Second Light',
    'Somewhere Within',
    'Open Sky',
    'Between Lines',
    'Late Bloom',
    'Low Tide',
    'First Light',
    'Drifting North',
    'Small Orbit',
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
}
