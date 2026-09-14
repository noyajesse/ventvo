import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/providers/resonance_provider.dart';
import '../services/echo_resonance_connection_service.dart';
import '../services/echo_resonance_link_service.dart';
import '../services/echo_resonance_link_storage.dart';
import '../services/echo_response_resonance_service.dart';
import '../services/echo_service.dart';
import '../services/space_response_storage.dart';

final echoServiceProvider = Provider<EchoService>((ref) {
  return EchoService(
    storage: SpaceResponseStorage(),
  );
});

final echoResonanceLinkStorageProvider =
    Provider<EchoResonanceLinkStorage>((ref) {
  return EchoResonanceLinkStorage();
});

final echoResonanceLinkServiceProvider =
    Provider<EchoResonanceLinkService>((ref) {
  return EchoResonanceLinkService(
    storage: ref.watch(echoResonanceLinkStorageProvider),
  );
});

final echoResonanceConnectionServiceProvider =
    Provider<EchoResonanceConnectionService>((ref) {
  return EchoResonanceConnectionService(
    engine: ref.watch(resonanceEngineProvider),
    linkService: ref.watch(echoResonanceLinkServiceProvider),
  );
});

final echoResponseResonanceServiceProvider =
    Provider<EchoResponseResonanceService>((ref) {
  return EchoResponseResonanceService(
    engine: ref.watch(resonanceEngineProvider),
    connectionService: ref.watch(resonanceConnectionServiceProvider),
    echoConnectionService: ref.watch(
      echoResonanceConnectionServiceProvider,
    ),
  );
});
