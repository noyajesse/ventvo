import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import '../repositories/resonance_map_repository.dart';

/// Map-specific capability boundary.
///
/// This deliberately stays separate from [ResonanceEngine] so core Resonance
/// test doubles and services do not need to implement Map operations.
abstract class ResonanceMapEngine {
  Future<void> saveMap(ResonanceMap map);

  Future<ResonanceMap?> getMap(String mapId);

  Future<List<ResonanceMap>> getMapsForExperience(String experienceId);

  Future<List<ResonanceMap>> getMaps();

  Future<List<ResonanceConnection>> getConnectionsInvolving(String id);
}

class LocalResonanceMapEngine implements ResonanceMapEngine {
  final ResonanceMapRepository mapRepository;
  final Future<List<ResonanceConnection>> Function(String id)
      getConnectionsInvolvingCallback;

  const LocalResonanceMapEngine({
    required this.mapRepository,
    required this.getConnectionsInvolvingCallback,
  });

  @override
  Future<void> saveMap(ResonanceMap map) => mapRepository.saveMap(map);

  @override
  Future<ResonanceMap?> getMap(String mapId) => mapRepository.getMap(mapId);

  @override
  Future<List<ResonanceMap>> getMapsForExperience(String experienceId) =>
      mapRepository.getMapsForExperience(experienceId);

  @override
  Future<List<ResonanceMap>> getMaps() => mapRepository.getMaps();

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) =>
      getConnectionsInvolvingCallback(id);
}
