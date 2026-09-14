import '../../../systems/resonance/models/resonance_profile.dart';
import '../../../systems/resonance/services/echo_note_resonance_service.dart';
import '../models/echo_note.dart';
import 'echo_resonance_link_service.dart';

/// Enriches an existing Echo Resonance relationship with an Echo Note.
///
/// Echo Notes never create a second connection. The parent Echo resolves to
/// the canonical connection, while this service extracts the Note's signals
/// through the shared Resonance profile system.
class EchoNoteResonanceEnrichmentService {
  final EchoResonanceLinkService linkService;
  final EchoNoteResonanceService noteResonanceService;

  const EchoNoteResonanceEnrichmentService({
    required this.linkService,
    this.noteResonanceService = const EchoNoteResonanceService(),
  });

  Future<EchoNoteResonanceEnrichment?> enrich(EchoNote note) async {
    final link = await linkService.getForEcho(note.echoId);
    if (link == null) return null;

    final profile = noteResonanceService.profileFor(note);
    return EchoNoteResonanceEnrichment(
      echoId: note.echoId,
      connectionId: link.connectionId,
      profile: profile,
    );
  }
}

class EchoNoteResonanceEnrichment {
  final String echoId;
  final String connectionId;
  final ResonanceProfile profile;

  const EchoNoteResonanceEnrichment({
    required this.echoId,
    required this.connectionId,
    required this.profile,
  });
}
