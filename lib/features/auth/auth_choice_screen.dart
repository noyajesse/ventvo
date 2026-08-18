import 'package:flutter/material.dart';

import '../../core/theme/ventvo_colors.dart';
import '../../core/theme/ventvo_mark.dart';
import 'email_auth_screen.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<Offset> _headingSlide;
  late final Animation<double> _headingFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _googleFade;
  late final Animation<Offset> _googleSlide;
  late final Animation<double> _emailFade;
  late final Animation<Offset> _emailSlide;
  late final Animation<double> _signinFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    // ------------------------------------------------------------
    // Ventvo mark
    // ------------------------------------------------------------

    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.25,
        curve: Curves.easeOut,
      ),
    );

    _markScale = Tween<double>(
      begin: 0.78,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.38,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Heading
    // ------------------------------------------------------------

    _headingFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.18,
        0.48,
        curve: Curves.easeOut,
      ),
    );

    _headingSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.18,
          0.5,
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
        0.32,
        0.58,
        curve: Curves.easeOut,
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.32,
          0.62,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Google button
    // ------------------------------------------------------------

    _googleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.48,
        0.72,
        curve: Curves.easeOut,
      ),
    );

    _googleSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.48,
          0.76,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Email button
    // ------------------------------------------------------------

    _emailFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.56,
        0.8,
        curve: Curves.easeOut,
      ),
    );

    _emailSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.56,
          0.84,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Sign in
    // ------------------------------------------------------------

    _signinFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.72,
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

  // ==============================================================
  // Navigation
  // ==============================================================

  void _continueWithGoogle() {
    // Google authentication will be connected later.
  }

  void _continueWithEmail() {
    Navigator.of(context).push(
      _emailRoute(
        const EmailAuthScreen(),
      ),
    );
  }

  void _signIn() {
    Navigator.of(context).push(
      _emailRoute(
        const EmailAuthScreen(
          startInSignInMode: true,
        ),
      ),
    );
  }

  PageRouteBuilder<void> _emailRoute(
    Widget page,
  ) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) =>
          page,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
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
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // ==============================================================
  // UI
  // ==============================================================

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
            top: -170,
            right: -130,
            child: IgnorePointer(
              child: Container(
                width: 390,
                height: 390,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VentvoColors.primary.withValues(
                    alpha: 0.07,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -200,
            left: -150,
            child: IgnorePointer(
              child: Container(
                width: 430,
                height: 430,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VentvoColors.secondary.withValues(
                    alpha: 0.045,
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
                horizontal: 28,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ==================================================
                  // Ventvo mark
                  // ==================================================

                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: const VentvoMark(
                        size: 72,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // Heading
                  // ==================================================

                  FadeTransition(
                    opacity: _headingFade,
                    child: SlideTransition(
                      position: _headingSlide,
                      child: Text(
                        'Welcome to Ventvo',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // Subtitle
                  // ==================================================

                  FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        "You don't have to carry everything alone.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: VentvoColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  // ==================================================
                  // Google
                  // ==================================================

                  FadeTransition(
                    opacity: _googleFade,
                    child: SlideTransition(
                      position: _googleSlide,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _continueWithGoogle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                VentvoColors.textPrimary,
                            side: const BorderSide(
                              color: VentvoColors.border,
                            ),
                            backgroundColor:
                                VentvoColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // Email
                  // ==================================================

                  FadeTransition(
                    opacity: _emailFade,
                    child: SlideTransition(
                      position: _emailSlide,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _continueWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                VentvoColors.buttonBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Continue with Email',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // Existing account
                  // ==================================================

                  FadeTransition(
                    opacity: _signinFade,
                    child: TextButton(
                      onPressed: _signIn,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            VentvoColors.textSecondary,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Already have an account? ',
                            ),
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: VentvoColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}