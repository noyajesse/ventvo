enum VoiceMarkFamily {
  quiet,
  open,
  grounded,
  luminous,
  flowing,
  unfinished,
}

class VoiceMark {
  final String id;
  final String symbol;
  final VoiceMarkFamily family;

  const VoiceMark({
    required this.id,
    required this.symbol,
    required this.family,
  });
}
