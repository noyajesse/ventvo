import '../../spaces/models/echo.dart';
import '../../spaces/models/echo_note.dart';
import '../../spaces/models/space.dart';
import '../../ventvo_voice/models/vent.dart';

enum ResonanceMapExperienceType { vent, echo }

class ResonanceMapExperience {
  final String id;
  final ResonanceMapExperienceType type;
  final String voiceMark;
  final String content;
  final Space? space;
  final Vent? vent;
  final Echo? echo;
  final List<EchoNote> echoNotes;

  const ResonanceMapExperience({
    required this.id,
    required this.type,
    required this.voiceMark,
    required this.content,
    required this.space,
    required this.vent,
    required this.echo,
    this.echoNotes = const [],
  });

  bool get isEcho => type == ResonanceMapExperienceType.echo;
}
