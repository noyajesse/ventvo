import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/echo_service.dart';
import '../services/space_response_storage.dart';

final echoServiceProvider = Provider<EchoService>((ref) {
  return EchoService(
    storage: SpaceResponseStorage(),
  );
});
