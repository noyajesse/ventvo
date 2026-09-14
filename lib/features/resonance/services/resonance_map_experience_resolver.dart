import '../../spaces/models/echo.dart';
import '../../spaces/models/space.dart';
import '../../spaces/services/echo_note_service.dart';
import '../../spaces/services/echo_service.dart';
import '../../ventvo_voice/models/vent.dart';
import '../models/resonance_map_experience.dart';

class ResonanceMapExperienceResolver {
  final EchoService echoService;
  final EchoNoteService echoNoteService;

  const ResonanceMapExperienceResolver({
    required this.echoService,
    required this.echoNoteService,
  });

  Future<List<ResonanceMapExperience>> resolve({
    required List<String> experienceIds,
    required Map<String, Vent> ventsById,
    required Map<String, Space> spacesById,
  }) async {
    final echoesByExperienceId = <String, Echo>{};
    final notesByEchoId = <String, List<dynamic>>{};

    for (final space in spacesById.values) {
      final echoes = await echoService.loadForSpace(space.id);
      for (final echo in echoes) {
        echoesByExperienceId['echo:${echo.id}'] = echo;
        notesByEchoId[echo.id] = await echoNoteService.loadForEcho(echo.id);
      }
    }

    final resolved = <ResonanceMapExperience>[];

    for (final experienceId in experienceIds) {
      final vent = ventsById[experienceId];
      if (vent != null) {
        resolved.add(
          ResonanceMapExperience(
            id: vent.id,
            type: ResonanceMapExperienceType.vent,
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
          ResonanceMapExperience(
            id: echo.id,
            type: ResonanceMapExperienceType.echo,
            voiceMark: echo.voiceMark,
            content: echo.content,
            space: spacesById[echo.spaceId],
            vent: null,
            echo: echo,
            echoNotes: List.unmodifiable(notesByEchoId[echo.id] ?? const []),
          ),
        );
      }
    }

    return List.unmodifiable(resolved);
  }
}
