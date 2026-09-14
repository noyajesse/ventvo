import '../models/echo.dart';
import '../models/echo_note.dart';
import '../models/space.dart';
import 'echo_note_storage.dart';

class EchoNoteService {
  final EchoNoteStorage storage;

  const EchoNoteService({required this.storage});

  Future<List<EchoNote>> loadForEcho(String echoId) {
    return storage.loadForEcho(echoId);
  }

  Future<List<EchoNote>> loadForSpace(String spaceId) {
    return storage.loadForSpace(spaceId);
  }

  Future<EchoNote?> leaveEchoNote({
    required Space space,
    required Echo echo,
    required String content,
    required String voiceMark,
  }) async {
    if (!space.isOpenDiscussion) return null;
    if (echo.spaceId != space.id) return null;

    final text = content.trim();
    if (text.isEmpty) return null;

    final note = EchoNote(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      echoId: echo.id,
      spaceId: space.id,
      ventId: echo.ventId ?? space.originatingVentId,
      voiceMark: voiceMark,
      content: text,
      createdAt: DateTime.now(),
    );

    await storage.add(note);
    return note;
  }
}
