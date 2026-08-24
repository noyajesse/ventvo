import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/ventvo_colors.dart';
import '../../core/theme/ventvo_mark.dart';
import '../../core/voice/ventvo_voice.dart' as voice_core;
import '../../core/voice/ventvo_voice_seed.dart';
import '../../core/voice/ventvo_voice_system.dart';
import '../ventvo_voice/models/ventvo_voice.dart' as voice_model;
import '../ventvo_voice/providers/voice_provider.dart';
import '../ventvo_voice/screens/voice_space_screen.dart';

class FindingYourVoiceScreen extends ConsumerStatefulWidget {
  const FindingYourVoiceScreen({super.key});

  @override
  ConsumerState<FindingYourVoiceScreen> createState() =>
      _FindingYourVoiceScreenState();
}

class _FindingYourVoiceScreenState
    extends ConsumerState<FindingYourVoiceScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _formingController;

  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;
  late final Animation<double> _formingFade;
  late final Animation<double> _formingScale;
  late final Animation<double> _formingRotation;
  late final Animation<double> _revealFade;
  late final Animation<double> _revealScale;
  late final Animation<Offset> _revealSlide;
  late final Animation<double> _messageFade;
  late final Animation<Offset> _messageSlide;
  late final Animation<double> _enterButtonFade;

  VentvoVoiceSeed? _seed;
  bool _isForming = false;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _formingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOutBack),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.52, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.56, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.36, 0.68, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.36, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 1.0, curve: Curves.easeOut),
    );

    _formingFade = CurvedAnimation(
      parent: _formingController,
      curve: const Interval(0.0, 0.48, curve: Curves.easeInOut),
    );
    _formingScale = Tween<double>(begin: 0.86, end: 1.10).animate(
      CurvedAnimation(
        parent: _formingController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeInOut),
      ),
    );
    _formingRotation = Tween<double>(begin: 0.0, end: 0.08).animate(
      CurvedAnimation(
        parent: _formingController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeInOut),
      ),
    );

    _revealFade = CurvedAnimation(
      parent: _formingController,
      curve: const Interval(0.35, 0.68, curve: Curves.easeOut),
    );
    _revealScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _formingController,
        curve: const Interval(0.35, 0.72, curve: Curves.easeOutBack),
      ),
    );
    _revealSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formingController,
        curve: const Interval(0.35, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _messageFade = CurvedAnimation(
      parent: _formingController,
      curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
    );
    _messageSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formingController,
        curve: const Interval(0.55, 0.82, curve: Curves.easeOutCubic),
      ),
    );
    _enterButtonFade = CurvedAnimation(
      parent: _formingController,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _formingController.dispose();
    super.dispose();
  }

  voice_core.VentvoVoice get _foundation => _seed!.currentFoundation;

  String get _voiceEssence {
    switch (_foundation) {
      case voice_core.VentvoVoice.vaelor:
        return 'A voice that gives what is inside a place to exist.';
      case voice_core.VentvoVoice.nyven:
        return 'A voice that finds resonance in being heard.';
      case voice_core.VentvoVoice.auren:
        return 'A voice that grows and becomes through expression.';
    }
  }

  Color get _voiceColor {
    switch (_foundation) {
      case voice_core.VentvoVoice.vaelor:
        return VentvoColors.primary;
      case voice_core.VentvoVoice.nyven:
        return VentvoColors.secondary;
      case voice_core.VentvoVoice.auren:
        return VentvoColors.primary;
    }
  }

  Future<void> _beginFormation() async {
    if (_isForming || _isRevealed) return;

    const voiceSystem = VentvoVoiceSystem();
    final seed = voiceSystem.createInitialSeed();

    setState(() {
      _seed = seed;
      _isForming = true;
    });

    await _formingController.forward();

    if (!mounted) return;

    setState(() {
      _isRevealed = true;
    });
  }

  Future<void> _enterVentvo() async {
    final seed = _seed;
    if (seed == null) return;

    final voice = voice_model.VentvoVoice(
      voiceId: DateTime.now().microsecondsSinceEpoch.toString(),
      name: seed.name,
      mark: seed.mark,
      expression: _voiceEssence,
      resonance: _foundation.principle,
      createdAt: DateTime.now(),
    );

    await ref.read(ventvoVoiceProvider.notifier).setVoice(voice);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const VoiceSpaceScreen(),
      ),
      (route) => false,
    );
  }

  Widget _buildMark() {
    final seed = _seed;

    if (!_isForming || seed == null) {
      return const VentvoMark(size: 78);
    }

    return AnimatedBuilder(
      animation: _formingController,
      builder: (context, child) {
        final revealStarted = _formingController.value >= 0.35;
        return Opacity(
          opacity: revealStarted ? 1 : _formingFade.value,
          child: Transform.rotate(
            angle: revealStarted ? 0 : _formingRotation.value,
            child: Transform.scale(
              scale: revealStarted ? 1 : _formingScale.value,
              child: _VoiceMark(
                symbol: seed.mark,
                color: _voiceColor,
                size: 126,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -190,
            right: -150,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _formingController,
                builder: (context, child) {
                  final color = _seed == null
                      ? VentvoColors.primary
                      : _voiceColor;
                  return Container(
                    width: 420,
                    height: 420,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.045),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: -220,
            left: -170,
            child: IgnorePointer(
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VentvoColors.secondary.withValues(alpha: 0.025),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    child: _isForming
                        ? FadeTransition(
                            key: const ValueKey('formed-voice-mark'),
                            opacity: _revealFade,
                            child: ScaleTransition(
                              scale: _revealScale,
                              child: _buildMark(),
                            ),
                          )
                        : FadeTransition(
                            key: const ValueKey('finding-mark'),
                            opacity: _markFade,
                            child: ScaleTransition(
                              scale: _markScale,
                              child: const VentvoMark(size: 78),
                            ),
                          ),
                  ),
                  const SizedBox(height: 38),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: _isRevealed
                        ? FadeTransition(
                            key: const ValueKey('voice-identity'),
                            opacity: _revealFade,
                            child: SlideTransition(
                              position: _revealSlide,
                              child: Column(
                                children: [
                                  Text(
                                    'YOUR VOICE',
                                    textAlign: TextAlign.center,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: VentvoColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.8,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _seed!.name,
                                    textAlign: TextAlign.center,
                                    style: textTheme.displaySmall?.copyWith(
                                      color: _voiceColor,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : FadeTransition(
                            key: const ValueKey('finding-copy'),
                            opacity: _isForming
                                ? const AlwaysStoppedAnimation<double>(0)
                                : _titleFade,
                            child: SlideTransition(
                              position: _titleSlide,
                              child: Text(
                                'Finding your voice.',
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: _isRevealed
                        ? FadeTransition(
                            key: const ValueKey('voice-message'),
                            opacity: _messageFade,
                            child: SlideTransition(
                              position: _messageSlide,
                              child: Column(
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 330),
                                    child: Text(
                                      _voiceEssence,
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: VentvoColors.textSecondary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'It can grow with you.',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: VentvoColors.textMuted,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : FadeTransition(
                            key: const ValueKey('finding-subtitle'),
                            opacity: _isForming
                                ? const AlwaysStoppedAnimation<double>(0)
                                : _subtitleFade,
                            child: SlideTransition(
                              position: _subtitleSlide,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 330),
                                child: Column(
                                  children: [
                                    Text(
                                      'You don’t have to define yourself before you begin.',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: VentvoColors.textSecondary,
                                        height: 1.6,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Your voice can grow with you.',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: VentvoColors.textMuted,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  const Spacer(flex: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isRevealed
                        ? FadeTransition(
                            key: const ValueKey('enter-button'),
                            opacity: _enterButtonFade,
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _enterVentvo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VentvoColors.buttonBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Enter Ventvo',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : FadeTransition(
                            key: const ValueKey('continue-button'),
                            opacity: _isForming
                                ? const AlwaysStoppedAnimation<double>(0)
                                : _buttonFade,
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isForming ? null : _beginFormation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VentvoColors.buttonBlue,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      VentvoColors.buttonBlue,
                                  disabledForegroundColor: Colors.white70,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  _isForming
                                      ? 'Forming your voice…'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceMark extends StatelessWidget {
  const _VoiceMark({
    required this.symbol,
    required this.color,
    required this.size,
  });

  final String symbol;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: TextStyle(
          color: color,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
