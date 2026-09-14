import '../models/echo.dart';
import '../models/space.dart';
import '../models/space_response.dart';
import 'echo_response_resonance_service.dart';
import 'space_response_storage.dart';

class EchoService {
  final SpaceResponseStorage storage;
  final EchoResponseResonanceService? responseResonanceService;

  const EchoService({
    required this.storage,
    this.responseResonanceService,
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
    final echo = _toEcho(response);

    final resonanceService = responseResonanceService;
    if (resonanceService != null) {
      await resonanceService.connectEcho(
        space: space,
        echo: echo,
        sourceExperienceId: 'vent:${space.originatingVentId}',
      );
    }

    return echo;
  }

  Echo _toEcho(SpaceResponse response) {
    return Echo(
      id: response.id,
      spaceId: response.spaceId,
      ventId: response.ventId,
      voiceMark: response.voiceMark,
      content: response.content,
      createdAt: response.createdAt,
    );
  }
}
