import '../../../features/spaces/models/echo_note.dart';
import '../models/resonance_profile.dart';
import 'echo_note_resonance_signal_generator.dart';
import 'resonance_signal_composer.dart';

/// Application-facing Resonance boundary for Echo Notes.
///
/// The generator extracts deterministic signals and the shared composer turns
/// those signals into the same ResonanceProfile used by the rest of Ventvo.
/// Echo Notes therefore enrich the existing Resonance system without creating
/// a parallel profile or candidate model.
class EchoNoteResonanceService {
  final EchoNoteResonanceSignalGenerator signalGenerator;
  final ResonanceSignalComposer composer;

  const EchoNoteResonanceService({
    this.signalGenerator = const EchoNoteResonanceSignalGenerator(),
    this.composer = const ResonanceSignalComposer(),
  });

  ResonanceProfile profileFor(EchoNote note) {
    final signals = signalGenerator.generate(note: note);
    return composer.compose(signals);
  }
}
