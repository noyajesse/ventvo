import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/ventvo_colors.dart';
import '../../core/voice/ventvo_voice.dart' as voice_core;
import '../../core/voice/ventvo_voice_seed.dart';
import '../ventvo_voice/models/ventvo_voice.dart' as voice_model;
import '../ventvo_voice/providers/voice_provider.dart';
import '../ventvo_voice/screens/voice_space_screen.dart';

class VoiceRevealScreen extends ConsumerStatefulWidget {
  const VoiceRevealScreen({
    super.key,
    required this.seed,
  });

  final VentvoVoiceSeed seed;

  @override
  ConsumerState<VoiceRevealScreen> createState() => _VoiceRevealScreenState();
}

class _VoiceRevealScreenState extends ConsumerState<VoiceRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _ambientFade;
  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _voiceFade;
  late final Animation<Offset> _voiceSlide;
  late final Animation<double> _messageFade;
  late final Animation<Offset> _messageSlide;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _ambientFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
    );
    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOutBack),
      ),
    );
    _voiceFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.62, curve: Curves.easeOut),
    );
    _voiceSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.66, curve: Curves.easeOutCubic),
      ),
    );
    _messageFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.78, curve: Curves.easeOut),
    );
    _messageSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.80, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  voice_core.VentvoVoice get _foundation => widget.seed.currentFoundation;

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

  Future<void> _enterVentvo() async {
    final voice = voice_model.VentvoVoice(
      voiceId: DateTime.now().microsecondsSinceEpoch.toString(),
      name: widget.seed.name,
      mark: widget.seed.mark,
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _ambientFade,
            child: Stack(
              children: [
                Positioned(
                  top: -170,
                  left: -150,
                  child: IgnorePointer(
                    child: Container(
                      width: 430,
                      height: 430,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _voiceColor.withValues(alpha: 0.045),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -200,
                  right: -160,
                  child: IgnorePointer(
                    child: Container(
                      width: 440,
                      height: 440,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VentvoColors.secondary.withValues(alpha: 0.025),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Hero(
                    tag: 'ventvo-voice-reveal-mark',
                    child: FadeTransition(
                      opacity: _markFade,
                      child: ScaleTransition(
                        scale: _markScale,
                        child: _VoiceMark(
                          symbol: widget.seed.mark,
                          color: _voiceColor,
                          size: 126,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 46),
                  FadeTransition(
                    opacity: _voiceFade,
                    child: SlideTransition(
                      position: _voiceSlide,
                      child: Text(
                        'YOUR VOICE',
                        textAlign: TextAlign.center,
                        style: textTheme.labelLarge?.copyWith(
                          color: VentvoColors.textMuted,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: _voiceFade,
                    child: SlideTransition(
                      position: _voiceSlide,
                      child: Text(
                        widget.seed.name,
                        textAlign: TextAlign.center,
                        style: textTheme.displaySmall?.copyWith(
                          color: _voiceColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _messageFade,
                    child: SlideTransition(
                      position: _messageSlide,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Text(
                          _voiceEssence,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: VentvoColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _messageFade,
                    child: Text(
                      'It can grow with you.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: VentvoColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: _buttonFade,
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
