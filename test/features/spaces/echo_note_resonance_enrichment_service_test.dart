import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo_note.dart';
import 'package:ventvo/features/spaces/models/echo_resonance_link.dart';
import 'package:ventvo/features/spaces/services/echo_note_resonance_enrichment_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_service.dart';
import 'package:ventvo/features/spaces/services/echo_resonance_link_storage.dart';

class _FakeLinkStorage extends EchoResonanceLinkStorage {
  EchoResonanceLink? link;

  @override
  Future<EchoResonanceLink?> loadForEcho(String echoId) async {
    return link?.echoId == echoId ? link : null;
  }

  @override
  Future<void> save(EchoResonanceLink value) async {
    link = value;
  }
}

void main() {
  test('enriches an Echo Note through its existing Echo connection', () async {
    final storage = _FakeLinkStorage();
    final linkService = EchoResonanceLinkService(storage: storage);
    final enrichmentService = EchoNoteResonanceEnrichmentService(
      linkService: linkService,
    );

    await linkService.linkEcho(
      echoId: 'echo-1',
      connectionId: 'vent-1_echo-1',
    );

    final note = EchoNote(
      id: 'note-1',
      echoId: 'echo-1',
      spaceId: 'space-1',
      ventId: 'vent-1',
      voiceMark: '△',
      content: 'I felt this too. It reminded me of my own experience.',
      createdAt: DateTime(2026, 1, 2),
    );

    final enrichment = await enrichmentService.enrich(note);

    expect(enrichment, isNotNull);
    expect(enrichment!.echoId, 'echo-1');
    expect(enrichment.connectionId, 'vent-1_echo-1');
    expect(
      enrichment.profile.relationships.any(
        (signal) => signal.key == 'echo_note',
      ),
      isTrue,
    );
    expect(
      enrichment.profile.experiences.map((signal) => signal.key),
      containsAll(['shared_experience', 'personal_reflection']),
    );
  });

  test('does not invent a connection when the Echo is not linked', () async {
    final enrichmentService = EchoNoteResonanceEnrichmentService(
      linkService: EchoResonanceLinkService(storage: _FakeLinkStorage()),
    );

    final note = EchoNote(
      id: 'note-1',
      echoId: 'unlinked-echo',
      spaceId: 'space-1',
      ventId: 'vent-1',
      voiceMark: '△',
      content: 'Same here.',
      createdAt: DateTime(2026, 1, 2),
    );

    final enrichment = await enrichmentService.enrich(note);

    expect(enrichment, isNull);
  });
}
