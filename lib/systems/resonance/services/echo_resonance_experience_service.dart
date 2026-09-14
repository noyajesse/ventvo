import '../../../features/spaces/models/echo.dart';

/// Resolves the internal Resonance experience identity represented by an Echo.
///
/// An Echo is itself an experience in the Resonance graph. Its identity is
/// namespaced so it cannot be confused with a Vent, Space, or Voice ID.
/// This is an internal identifier and must never be exposed as user identity.
class EchoResonanceExperienceService {
  const EchoResonanceExperienceService();

  String? experienceIdFor(Echo echo) {
    final echoId = echo.id.trim();
    if (echoId.isEmpty) return null;
    return 'echo:$echoId';
  }
}
