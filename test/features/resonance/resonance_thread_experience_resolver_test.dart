import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/resonance/models/resonance_thread_experience.dart';
import 'package:ventvo/features/resonance/services/resonance_thread_experience_resolver.dart';
import 'package:ventvo/features/spaces/models/echo.dart';
import 'package:ventvo/features/spaces/models/echo_note.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/spaces/models/space_response.dart';
import 'package:ventvo/features/spaces/services/echo_note_service.dart';
import 'package:ventvo/features/spaces/services/echo_note_storage.dart';
import 'package:ventvo/features/spaces/services/echo_service.dart';
import 'package:ventvo/features/spaces/services/space_response_storage.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';

class _FakeResponseStorage extends SpaceResponseStorage {
  final List<SpaceResponse> responses;

  _FakeResponseStorage(this.responses);

  @override
  Future<List<SpaceResponse>> loadForSpace(String spaceId) async {
    return responses.where((item) => item.spaceId == spaceId).toList();
  }
}

class _FakeEchoNoteStorage extends EchoNoteStorage {
  final List<EchoNote> notes;

  _FakeEchoNoteStorage(this.notes);

  @override
  Future<List<EchoNote>> loadForEcho(String echoId) async {
    return notes.where((note) => note.echoId == echoId).toList();
  }

  @override
  Future<List<EchoNote>> loadForSpace(String spaceId) async {
    return notes.where((note) => note.spaceId == spaceId).toList();
  }
}

void main() {
  test('resolves Vent and Echo experiences with Echo Notes', () async {
    final space = Space(
      id: 'space-1',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'vent-1',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final vent = Vent(
      id: 'vent-1',
      content: 'I have been feeling less alone lately.',
      spaceId: space.id,
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final echo = Echo(
      id: 'echo-1',
      spaceId: space.id,
      ventId: vent.id,
      voiceMark: '△',
      content: 'I went through something similar.',
      createdAt: DateTime(2026, 1, 2),
    );

    final note = EchoNote(
      id: 'note-1',
      echoId: echo.id,
      spaceId: space.id,
      ventId: vent.id,
      voiceMark: '✦',
      content: 'This brought back a memory for me.',
      createdAt: DateTime(2026, 1, 3),
    );

    final resolver = ResonanceThreadExperienceResolver(
      echoService: EchoService(
        storage: _FakeResponseStorage([
          SpaceResponse(
            id: echo.id,
            spaceId: echo.spaceId,
            ventId: echo.ventId,
            voiceMark: echo.voiceMark,
            content: echo.content,
            createdAt: echo.createdAt,
          ),
        ]),
      ),
      echoNoteService: EchoNoteService(
        storage: _FakeEchoNoteStorage([note]),
      ),
    );

    final thread = ResonanceThread.create(
      id: 'thread-1',
      originatingExperienceId: vent.id,
      experienceIds: [vent.id, 'echo:${echo.id}'],
      voiceMarks: ['◇', '△'],
      createdAt: DateTime(2026, 1, 4),
    );

    final resolved = await resolver.resolve(
      thread: thread,
      ventsById: {vent.id: vent},
      spacesById: {space.id: space},
    );

    expect(resolved, hasLength(2));
    expect(resolved[0].type, ResonanceThreadExperienceType.vent);
    expect(resolved[1].type, ResonanceThreadExperienceType.echo);
    expect(resolved[1].content, echo.content);
    expect(resolved[1].echoNotes, hasLength(1));
    expect(resolved[1].echoNotes.single.content, note.content);
  });
}
