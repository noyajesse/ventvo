import '../../spaces/models/echo_note.dart';
import '../../spaces/models/space.dart';

import '../../ventvo_voice/models/vent.dart';
import '../../spaces/models/echo.dart';

enum ResonanceThreadExperienceType {
  vent,
  echo,
}

class ResonanceThreadExperience {
  final String id;
  final ResonanceThreadExperienceType type;
  final String voiceMark;
  final String content;
  final Space? space;
  final Vent? vent;
  final Echo? echo;
  final List<EchoNote> echoNotes;

  const ResonanceThreadExperience({
    required this.id,
    required this.type,
    required this.voiceMark,
    required this.content,
    required this.space,
    required this.vent,
    required this.echo,
    this.echoNotes = const [],
  });

  bool get isEcho => type == ResonanceThreadExperienceType.echo;
}
