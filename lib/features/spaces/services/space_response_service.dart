import '../models/space.dart';
import '../models/space_response.dart';
import 'space_response_storage.dart';

class SpaceResponseService {
  final SpaceResponseStorage storage;

  const SpaceResponseService({required this.storage});

  Future<List<SpaceResponse>> loadVisible(String spaceId) async {
    final responses = await storage.loadForSpace(spaceId);
    return responses
        .where((response) => !response.isMoment && !response.isHeard)
        .toList();
  }

  Future<SpaceResponse?> addPerspective({
    required Space space,
    required String content,
    required String voiceMark,
  }) async {
    if (!space.isOpenDiscussion) return null;

    final text = content.trim();
    if (text.isEmpty) return null;

    final response = SpaceResponse(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      spaceId: space.id,
      ventId: space.originatingVentId,
      voiceMark: voiceMark,
      content: text,
      createdAt: DateTime.now(),
    );

    await storage.add(response);
    return response;
  }
}
