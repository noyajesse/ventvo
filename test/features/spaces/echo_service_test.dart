import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/spaces/models/space_response.dart';
import 'package:ventvo/features/spaces/services/echo_service.dart';
import 'package:ventvo/features/spaces/services/space_response_storage.dart';

class _FakeSpaceResponseStorage extends SpaceResponseStorage {
  final List<SpaceResponse> responses = [];

  @override
  Future<List<SpaceResponse>> loadForSpace(String spaceId) async {
    return responses.where((response) => response.spaceId == spaceId).toList();
  }

  @override
  Future<void> add(SpaceResponse response) async {
    responses.add(response);
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

  late _FakeSpaceResponseStorage storage;
  late EchoService service;

  setUp(() {
    storage = _FakeSpaceResponseStorage();
    service = EchoService(storage: storage);
  });

  test('loads visible responses as Echoes', () async {
    storage.responses.addAll([
      SpaceResponse(
        id: 'echo-1',
        spaceId: discussion.id,
        ventId: discussion.originatingVentId,
        voiceMark: '△',
        content: 'I understand this feeling.',
        createdAt: DateTime(2026, 1, 2),
      ),
      SpaceResponse(
        id: 'moment-1',
        spaceId: discussion.id,
        ventId: discussion.originatingVentId,
        voiceMark: '✦',
        content: 'hidden moment',
        createdAt: DateTime(2026, 1, 2),
        isMoment: true,
      ),
      SpaceResponse(
        id: 'heard-1',
        spaceId: discussion.id,
        ventId: discussion.originatingVentId,
        voiceMark: '≈',
        content: 'already heard',
        createdAt: DateTime(2026, 1, 2),
        isHeard: true,
      ),
    ]);

    final echoes = await service.loadForSpace(discussion.id);

    expect(echoes, hasLength(1));
    expect(echoes.single.id, 'echo-1');
    expect(echoes.single.voiceMark, '△');
    expect(echoes.single.content, 'I understand this feeling.');
  });

  test('rejects Echoes in Just Listen spaces', () async {
    final echo = await service.leaveEcho(
      space: justListen,
      content: 'I hear you.',
      voiceMark: '△',
    );

    expect(echo, isNull);
    expect(storage.responses, isEmpty);
  });

  test('rejects empty Echo content', () async {
    final echo = await service.leaveEcho(
      space: discussion,
      content: '   ',
      voiceMark: '△',
    );

    expect(echo, isNull);
    expect(storage.responses, isEmpty);
  });

  test('rejects an Echo from the originating Voice', () async {
    final echo = await service.leaveEcho(
      space: discussion,
      content: 'I am responding to my own Moment.',
      voiceMark: '◇',
      authorVoiceId: 'voice-1',
      sourceVoiceId: 'voice-1',
    );

    expect(echo, isNull);
    expect(storage.responses, isEmpty);
  });

  test('creates and persists a valid Echo without creating Resonance', () async {
    final echo = await service.leaveEcho(
      space: discussion,
      content: '  This helped me feel less alone.  ',
      voiceMark: '∿',
      authorVoiceId: 'voice-2',
      sourceVoiceId: 'voice-1',
    );

    expect(echo, isNotNull);
    expect(echo!.spaceId, discussion.id);
    expect(echo.ventId, discussion.originatingVentId);
    expect(echo.voiceMark, '∿');
    expect(echo.authorVoiceId, 'voice-2');
    expect(echo.content, 'This helped me feel less alone.');
    expect(storage.responses, hasLength(1));
    expect(storage.responses.single.id, echo.id);
  });
}
