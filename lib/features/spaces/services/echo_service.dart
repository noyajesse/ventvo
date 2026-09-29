import '../models/echo.dart';
import '../models/space.dart';
import '../models/space_response.dart';
import 'space_response_storage.dart';

/// Creates and loads Echoes.
///
/// An Echo is a response caused by encountering another person's Moment.
/// It must carry the responder's own experience or perspective rather than
/// acting as a generic comment. Echo creation does not create Resonance.
class EchoService {
  final SpaceResponseStorage storage;

  const EchoService({
    required this.storage,
  });

  Future<List<Echo>> loadForSpace(String spaceId) async {
    final responses = await storage.loadForSpace(spaceId);
    return responses
        .where((response) => !response.isMoment && !response.isHeard)
        .map(_toEcho)
        .toList();
  }

  Future<Echo?> leaveEcho({
    required Space space,
    required String content,
    required String voiceMark,
    String? authorVoiceId,
    String? sourceVoiceId,
  }) async {
    if (!space.isOpenDiscussion) return null;

    final text = content.trim();
    if (text.isEmpty) return null;

    // An Echo is a response from another Voice, not a second expression
    // from the Voice that created the originating Moment.
    if (authorVoiceId != null &&
        sourceVoiceId != null &&
        authorVoiceId == sourceVoiceId) {
      return null;
    }

    final response = SpaceResponse(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      spaceId: space.id,
      ventId: space.originatingVentId,
      voiceMark: voiceMark,
      authorVoiceId: authorVoiceId,
      content: text,
      createdAt: DateTime.now()
    );

    await storage.add(response);
    return _toEcho(response);
  }

  Echo _toEcho(SpaceResponse response) {
    return Echo(
      id: response.id,
      spaceId: response.spaceId,
      ventId: response.ventId,
      voiceMark: response.voiceMark,
      authorVoiceId: response.authorVoiceId,
      content: response.content
      createdAt: response.createdAt,
    );
  }

}
