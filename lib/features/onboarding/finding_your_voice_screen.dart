import 'package:flutter/material.dart';

import '../../core/theme/ventvo_colors.dart';
import '../../core/theme/ventvo_mark.dart';
import '../../core/voice/ventvo_voice_seed.dart';
import '../../core/voice/ventvo_voice_system.dart';
import 'voice_reveal_screen.dart';

class FindingYourVoiceScreen extends StatefulWidget {
  const FindingYourVoiceScreen({
    super.key,
  });

  @override
  State<FindingYourVoiceScreen> createState() =>
      _FindingYourVoiceScreenState();
}

class _FindingYourVoiceScreenState extends State<FindingYourVoiceScreen>
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

  VentvoVoiceSeed? _seed;
  bool _isForming = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _formingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
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
      curve: const Interval(0.0, 0.55, curve: Curves.easeInOut),
    );

    _formingScale = Tween<double>(begin: 0.86, end: 1.18).animate(
      CurvedAnimation(
        parent: _formingController,
        curve: const Interval(0.0, 0.72, curve: Curves.easeInOut),
      ),
    );

    _formingRotation = Tween<double>(begin: 0.0, end: 0.10).animate(
      CurvedAnimation(
        parent: _formingController,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _formingController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_isForming) return;

    const voiceSystem = VentvoVoiceSystem();
    final seed = voiceSystem.createInitialSeed();

    setState(() {
      _seed = seed;
      _isForming = true;
    });

    await _formingController.forward();

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => VoiceRevealScreen(seed: seed),
        transitionsBuilder: (_, animation, _, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );
        },
      ),
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
        return Opacity(
          opacity: _formingFade.value,
          child: Transform.rotate(
            angle: _formingRotation.value,
            child: Transform.scale(
              scale: _formingScale.value,
              child: _FormingVoiceMark(
                symbol: seed.mark,
                color: VentvoColors.primary,
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
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VentvoColors.primary.withValues(alpha: 0.045),
                ),
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
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    child: Hero(
                      key: ValueKey(_seed?.mark ?? 'ventvo-mark'),
                      tag: 'ventvo-voice-reveal-mark',
                      child: FadeTransition(
                        opacity: _markFade,
                        child: ScaleTransition(
                          scale: _markScale,
                          child: _buildMark(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  FadeTransition(
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
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _isForming
                        ? const AlwaysStoppedAnimation<double>(0)
                        : _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Text(
                          'You don’t have to define yourself before you begin.',
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
                    opacity: _isForming
                        ? const AlwaysStoppedAnimation<double>(0)
                        : _subtitleFade,
                    child: Text(
                      'Your voice can grow with you.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: VentvoColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: _isForming
                        ? const AlwaysStoppedAnimation<double>(0)
                        : _buttonFade,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isForming ? null : _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VentvoColors.buttonBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: VentvoColors.buttonBlue,
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          _isForming ? 'Forming your voice…' : 'Continue',
                          style: const TextStyle(
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

class _FormingVoiceMark extends StatelessWidget {
  const _FormingVoiceMark({
    required this.symbol,
    required this.color,
  });

  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.38),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 34,
            spreadRadius: 5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: TextStyle(
          color: color,
          fontSize: 48,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
