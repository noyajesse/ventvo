import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/echo_note_resonance_enrichment_service.dart';
import '../services/echo_note_service.dart';
import '../services/echo_note_storage.dart';
import 'echo_provider.dart';

final echoNoteServiceProvider = Provider<EchoNoteService>((ref) {
  return EchoNoteService(
    storage: EchoNoteStorage(),
  );
});

final echoNoteResonanceEnrichmentServiceProvider =
    Provider<EchoNoteResonanceEnrichmentService>((ref) {
  return EchoNoteResonanceEnrichmentService(
    linkService: ref.watch(echoResonanceLinkServiceProvider),
  );
});
