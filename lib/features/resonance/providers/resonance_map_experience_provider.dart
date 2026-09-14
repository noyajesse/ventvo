import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/providers/echo_note_provider.dart';
import '../../spaces/providers/echo_provider.dart';
import '../services/resonance_map_experience_resolver.dart';

final resonanceMapExperienceResolverProvider =
    Provider<ResonanceMapExperienceResolver>((ref) {
  return ResonanceMapExperienceResolver(
    echoService: ref.watch(echoServiceProvider),
    echoNoteService: ref.watch(echoNoteServiceProvider),
  );
});
