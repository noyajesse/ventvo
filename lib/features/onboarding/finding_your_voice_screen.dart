import 'package:flutter/material.dart';

import '../../core/theme/ventvo_colors.dart';
import '../../core/theme/ventvo_mark.dart';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    // ------------------------------------------------------------
    // Ventvo mark
    // ------------------------------------------------------------

    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.28,
        curve: Curves.easeOut,
      ),
    );

    _markScale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.42,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Title
    // ------------------------------------------------------------

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.20,
        0.52,
        curve: Curves.easeOut,
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.20,
          0.56,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Subtitle
    // ------------------------------------------------------------

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.36,
        0.68,
        curve: Curves.easeOut,
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.36,
          0.72,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Button
    // ------------------------------------------------------------

    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.62,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // Continue to Voice Reveal
  // --------------------------------------------------------------

  void _continue() {
    const voiceSystem = VentvoVoiceSystem();

    final seed = voiceSystem.createInitialSeed();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 650,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 450,
        ),
        pageBuilder: (_, _, _) => VoiceRevealScreen(
          seed: seed,
        ),
        transitionsBuilder: (
          _,
          animation,
          _,
          child,
        ) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: Stack(
        children: [
          // ==========================================================
          // Atmospheric background
          // ==========================================================

          Positioned(
            top: -190,
            right: -150,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VentvoColors.primary.withValues(
                    alpha: 0.045,
                  ),
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
                  color: VentvoColors.secondary.withValues(
                    alpha: 0.025,
                  ),
                ),
              ),
            ),
          ),

          // ==========================================================
          // Content
          // ==========================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Column(
                children: [
                  const Spacer(
                    flex: 2,
                  ),

                  // --------------------------------------------------
                  // Ventvo mark
                  // --------------------------------------------------

                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: const VentvoMark(
                        size: 78,
                      ),
                    ),
                  ),

                  const SizedBox(height: 38),

                  // --------------------------------------------------
                  // Main title
                  // --------------------------------------------------

                  FadeTransition(
                    opacity: _titleFade,
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

                  // --------------------------------------------------
                  // Supporting message
                  // --------------------------------------------------

                  FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 330,
                        ),
                        child: Text(
                          'You don’t have to define yourself '
                          'before you begin.',
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

                  // --------------------------------------------------
                  // Reassurance
                  // --------------------------------------------------

                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      'Your voice can grow with you.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: VentvoColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const Spacer(
                    flex: 2,
                  ),

                  // --------------------------------------------------
                  // Continue
                  // --------------------------------------------------

                  FadeTransition(
                    opacity: _buttonFade,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VentvoColors.buttonBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Continue',
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