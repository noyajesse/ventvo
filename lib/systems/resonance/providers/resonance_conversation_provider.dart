import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/local_resonance_conversation_repository.dart';
import '../repositories/resonance_conversation_repository.dart';
import '../services/resonance_conversation_service.dart';

final resonanceConversationRepositoryProvider =
    Provider<ResonanceConversationRepository>((ref) {
  return LocalResonanceConversationRepository();
});

final resonanceConversationServiceProvider =
    Provider<ResonanceConversationService>((ref) {
  return ResonanceConversationService(
    repository: ref.watch(resonanceConversationRepositoryProvider),
  );
});
