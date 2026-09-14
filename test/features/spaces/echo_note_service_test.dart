import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo.dart';
import 'package:ventvo/features/spaces/models/echo_note.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/spaces/services/echo_note_service.dart';
import 'package:ventvo/features/spaces/services/echo_note_storage.dart';

class _FakeEchoNoteStorage extends EchoNoteStorage {
  final List<EchoNote> notes = [];

  @override
  Future<List<EchoNote>> loadForEcho(String echoId) async {
    return notes.where((note) => note.echoId == echoId).toList();
  }

  @override
  Future<List<EchoNote>> loadForSpace(String spaceId) async {
    return notes.where((note) => note.spaceId == spaceId).toList();
  }

  @override
  Future<void> add(EchoNote note) async {
    notes.add(note);
  }
}

void main() {
  final discussion = Space(
    id: 'space-1',
    mode: SpaceMode.openDiscussion,
    originatingVentId: 'vent-1',
    creatorVoiceMark: '◇',
    createdAt: DateTime(2026, 1, 1),
  );

  final justListen = Space(
    id: 'space-2',
    mode: SpaceMode.justListen,
    originatingVentId: 'vent-2',
    creatorVoiceMark: '○',
    createdAt: DateTime(2026, 1, 1),
  );

  final echo = Echo(
    id: 'echo-1',
    spaceId: discussion.id,
    ventId: discussion.originatingVentId,
    voiceMark: '△',
    content: 'I felt this too.',
    createdAt: DateTime(2026, 1, 2),
  );

  late _FakeEchoNoteStorage storage;
  late EchoNoteService service;

  setUp(() {
    storage = _FakeEchoNoteStorage();
    service = EchoNoteService(storage: storage);
  });

  test('rejects Echo Notes in Just Listen spaces', () async {
    final note = await service.leaveEchoNote(
      space: justListen,
      echo: echo,
      content: 'This brought something back for me.',
      voiceMark: '∿',
    );

    expect(note, isNull);
    expect(storage.notes, isEmpty);
  });

  test('rejects an Echo from another Space', () async {
    final note = await service.leaveEchoNote(
      space: discussion,
      echo: Echo(
        id: 'echo-2',
        spaceId: 'another-space',
        ventId: 'vent-2',
        voiceMark: '≈',
        content: 'Not part of this Space.',
        createdAt: DateTime(2026, 1, 2),
      ),
      content: 'This should not attach here.',
      voiceMark: '∿',
    );

    expect(note, isNull);
    expect(storage.notes, isEmpty);
  });

  test('rejects empty Echo Note content', () async {
    final note = await service.leaveEchoNote(
      space: discussion,
      echo: echo,
      content: '   ',
      voiceMark: '∿',
    );

    expect(note, isNull);
    expect(storage.notes, isEmpty);
  });

  test('creates and persists a valid Echo Note on the Echo', () async {
    final note = await service.leaveEchoNote(
      space: discussion,
      echo: echo,
      content: '  This reminded me of my own experience.  ',
      voiceMark: '∿',
    );

    expect(note, isNotNull);
    expect(note!.echoId, echo.id);
    expect(note.spaceId, discussion.id);
    expect(note.ventId, echo.ventId);
    expect(note.voiceMark, '∿');
    expect(note.content, 'This reminded me of my own experience.');
    expect(storage.notes, hasLength(1));
  });

  test('loads notes for a specific Echo', () async {
    storage.notes.addAll([
      EchoNote(
        id: 'note-1',
        echoId: echo.id,
        spaceId: discussion.id,
        ventId: echo.ventId,
        voiceMark: '✦',
        content: 'A related experience.',
        createdAt: DateTime(2026, 1, 3),
      ),
      EchoNote(
        id: 'note-2',
        echoId: 'other-echo',
        spaceId: discussion.id,
        ventId: echo.ventId,
        voiceMark: '◇',
        content: 'Another reflection.',
        createdAt: DateTime(2026, 1, 4),
      ),
    ]);

    final notes = await service.loadForEcho(echo.id);

    expect(notes, hasLength(1));
    expect(notes.single.id, 'note-1');
  });
}
