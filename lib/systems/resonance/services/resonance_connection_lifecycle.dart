import '../models/resonance_connection.dart';

/// Defines the valid state transitions for a Resonance connection.
///
/// Keeping these rules in the Resonance domain prevents UI or feature code
/// from changing connection state arbitrarily.
class ResonanceConnectionLifecycle {
  const ResonanceConnectionLifecycle();

  bool canTransition(
    ResonanceConnectionState from,
    ResonanceConnectionState to,
  ) {
    if (from == to) return false;

    switch (from) {
      case ResonanceConnectionState.suggested:
        return to == ResonanceConnectionState.accepted ||
            to == ResonanceConnectionState.closed ||
            to == ResonanceConnectionState.blocked;
      case ResonanceConnectionState.accepted:
        return to == ResonanceConnectionState.active ||
            to == ResonanceConnectionState.closed ||
            to == ResonanceConnectionState.blocked;
      case ResonanceConnectionState.active:
        return to == ResonanceConnectionState.closed ||
            to == ResonanceConnectionState.blocked;
      case ResonanceConnectionState.closed:
      case ResonanceConnectionState.blocked:
        return false;
    }
  }
}
