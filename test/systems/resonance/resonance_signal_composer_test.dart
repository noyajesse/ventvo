import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/services/resonance_signal_composer.dart';

void main() {
  const composer = ResonanceSignalComposer();

  test('groups signals into their semantic roles', () {
    const signals = [
      ResonanceSignal(
        type: ResonanceSignalType.experiential,
        key: 'connection_difficulty',
        strength: 1,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.semantic,
        key: 'university',
        strength: 0.8,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.intent,
        key: 'just_listen',
        strength: 1,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.privacy,
        key: 'private',
        strength: 1,
      ),
    ];

    final profile = composer.compose(signals);

    expect(profile.signals, hasLength(4));
    expect(profile.experiences.single.key, 'connection_difficulty');
    expect(profile.contexts.single.key, 'university');
    expect(profile.intents.single.key, 'just_listen');
    expect(profile.relationships, isEmpty);
    expect(profile.isPrivate, isTrue);
  });

  test('composes experience with context and intent', () {
    const signals = [
      ResonanceSignal(
        type: ResonanceSignalType.experiential,
        key: 'connection_difficulty',
        strength: 1,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.semantic,
        key: 'university',
        strength: 0.8,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.intent,
        key: 'just_listen',
        strength: 1,
      ),
    ];

    final profile = composer.compose(signals);

    final compositionKeys = profile.compositions.map((item) => item.key).toSet();

    expect(
      compositionKeys,
      contains('connection_difficulty_in_university'),
    );
    expect(
      compositionKeys,
      contains('connection_difficulty_with_just_listen'),
    );
  });

  test('combined strength stays bounded between zero and one', () {
    const signals = [
      ResonanceSignal(
        type: ResonanceSignalType.experiential,
        key: 'burnout',
        strength: 1,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.semantic,
        key: 'work',
        strength: 0.8,
      ),
    ];

    final profile = composer.compose(signals);

    expect(profile.compositions.single.strength, 0.9);
  });

  test('safety constraints remain separate from human experience', () {
    const signals = [
      ResonanceSignal(
        type: ResonanceSignalType.experiential,
        key: 'burnout',
        strength: 1,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.safety,
        key: 'restricted',
        strength: 1,
      ),
    ];

    final profile = composer.compose(signals);

    expect(profile.experiences.single.key, 'burnout');
    expect(profile.constraints.single.key, 'restricted');
    expect(profile.isSafetyRestricted, isTrue);
    expect(profile.compositions, isEmpty);
  });
}
