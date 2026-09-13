import '../models/resonance_map.dart';

/// Storage boundary for Resonance Maps.
///
/// Map persistence is kept separate from the general Resonance repository
/// contract so features that do not use Maps do not have to implement Map
/// operations in their test doubles or alternate repositories.
abstract class ResonanceMapRepository {
  Future<void> saveMap(ResonanceMap map);

  Future<ResonanceMap?> getMap(String mapId);

  Future<List<ResonanceMap>> getMapsForExperience(String experienceId);

  Future<List<ResonanceMap>> getMaps();
}
