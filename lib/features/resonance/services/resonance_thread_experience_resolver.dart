import '../../spaces/models/echo.dart';
import '../../spaces/models/echo_note.dart';
import '../../spaces/models/space.dart';
import '../../spaces/services/echo_note_service.dart';
import '../../spaces/services/echo_service.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../models/resonance_thread_experience.dart';

class ResonanceThreadExperienceResolver {
  final EchoService echoService;
  final EchoNoteService echoNoteService;

  const ResonanceThreadExperienceResolver({
    required this.echoService,
    required this.echoNoteService,
  });

  Future<List<ResonanceThreadExperience>> resolve({
    required ResonanceThread thread,
    required Map<String, Vent> ventsById,
    required Map<String, Space> spacesById,
  }) async {
    final echoesByExperienceId = <String, Echo>{};
    final notesByEchoId = <String, List<EchoNote>>{};

    for (final space in spacesById.values) {
      final echoes = await echoService.loadForSpace(space.id);
      for (final echo in echoes) {
        echoesByExperienceId['echo:${echo.id}'] = echo;
        notesByEchoId[echo.id] = await echoNoteService.loadForEcho(echo.id);
      }
    }

    final resolved = <ResonanceThreadExperience>[];

    for (final experienceId in thread.experienceIds) {
      final vent = ventsById[experienceId];
      if (vent != null) {
        resolved.add(
          ResonanceThreadExperience(
            id: vent.id,
            type: ResonanceThreadExperienceType.vent,
            voiceMark: vent.voiceMark,
            content: vent.content,
            space: spacesById[vent.spaceId],
            vent: vent,
            echo: null,
          ),
        );
        continue;
      }

      final echo = echoesByExperienceId[experienceId];
      if (echo != null) {
        resolved.add(
          ResonanceThreadExperience(
            id: echo.id,
            type: ResonanceThreadExperienceType.echo,
            voiceMark: echo.voiceMark,
            content: echo.content,
            space: spacesById[echo.spaceId],
            vent: null,
            echo: echo,
            echoNotes: notesByEchoId[echo.id] ?? const [],
          ),
        );
      }
    }

    return List.unmodifiable(resolved);
  }
}
