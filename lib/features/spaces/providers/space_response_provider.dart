import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/space_response_service.dart';
import '../services/space_response_storage.dart';

final spaceResponseServiceProvider = Provider<SpaceResponseService>((ref) {
  return SpaceResponseService(
    storage: SpaceResponseStorage(),
  );
});
