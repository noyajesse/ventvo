import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo_resonance_link.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_storage.dart';

class FakeEchoResonanceLinkStorage extends EchoResonanceLinkStorage {
  EchoResonanceLink? link;

  @override
  Future<EchoResonanceLink?> loadForEcho(String echoId) async {
    if (link?.echoId == echoId) return link;
    return null;
  }

  @override
  Future<void> save(EchoResonanceLink value) async {
    link = value;
  }
}

void main() {
  test('linkEcho creates a link without creating a Resonance connection', () async {
    final storage = FakeEchoResonanceLinkStorage();
    final service = EchoResonanceLinkService(storage: storage);

    final link = await service.linkEcho(
      echoId: ' echo-1 ',
      connectionId: ' connection-1 ',
    );

    expect(link, isNotNull);
    expect(link!.echoId, 'echo-1');
    expect(link.connectionId, 'connection-1');
    expect(storage.link, same(link));
  });

  test('blank identifiers are rejected', () async {
    final storage = FakeEchoResonanceLinkStorage();
    final service = EchoResonanceLinkService(storage: storage);

    expect(
      await service.linkEcho(echoId: ' ', connectionId: 'connection-1'),
      isNull,
    );
    expect(
      await service.linkEcho(echoId: 'echo-1', connectionId: ' '),
      isNull,
    );
  });

  test('getForEcho returns the existing link', () async {
    final storage = FakeEchoResonanceLinkStorage();
    final service = EchoResonanceLinkService(storage: storage);

    await service.linkEcho(
      echoId: 'echo-1',
      connectionId: 'connection-1',
    );

    final result = await service.getForEcho('echo-1');

    expect(result?.connectionId, 'connection-1');
  });

  test('getForEcho ignores a blank Echo id', () async {
    final storage = FakeEchoResonanceLinkStorage();
    final service = EchoResonanceLinkService(storage: storage);

    expect(await service.getForEcho(' '), isNull);
  });
}
