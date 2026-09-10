enum ResonanceSignalType {
  semantic,
  experiential,
  intent,
  context,
  relationship,
  diversity,
  privacy,
  safety,
  repetition,
}

class ResonanceSignal {
  final ResonanceSignalType type;
  final String key;
  final double strength;

  const ResonanceSignal({
    required this.type,
    required this.key,
    required this.strength,
  });

  ResonanceSignal copyWith({
    ResonanceSignalType? type,
    String? key,
    double? strength,
  }) {
    return ResonanceSignal(
      type: type ?? this.type,
      key: key ?? this.key,
      strength: strength ?? this.strength,
    );
  }
}
