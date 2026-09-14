import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/echo_note_service.dart';
import '../services/echo_note_storage.dart';

final echoNoteServiceProvider = Provider<EchoNoteService>((ref) {
  return EchoNoteService(
    storage: EchoNoteStorage(),
  );
});
