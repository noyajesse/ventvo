import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/providers/echo_note_provider.dart';
import '../../spaces/providers/echo_provider.dart';
import '../services/resonance_thread_experience_resolver.dart';

final resonanceThreadExperienceResolverProvider =
    Provider<ResonanceThreadExperienceResolver>((ref) {
  return ResonanceThreadExperienceResolver(
    echoService: ref.watch(echoServiceProvider),
    echoNoteService: ref.watch(echoNoteServiceProvider),
  );
});
