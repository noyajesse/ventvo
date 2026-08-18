import 'package:flutter/material.dart';

import '../../core/theme/ventvo_colors.dart';
import '../../core/theme/ventvo_mark.dart';
import '../onboarding/finding_your_voice_screen.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({
    super.key,
    this.startInSignInMode = false,
  });

  final bool startInSignInMode;

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _buttonFade;

  bool _isSignIn = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _isSignIn = widget.startInSignInMode;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    // Main content
    // ------------------------------------------------------------

    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.18,
        0.65,
        curve: Curves.easeOut,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.18,
          0.68,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ------------------------------------------------------------
    // Primary button
    // ------------------------------------------------------------

    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.55,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==============================================================
  // Authentication mode
  // ==============================================================

  void _toggleMode() {
    setState(() {
      _isSignIn = !_isSignIn;
      _formKey.currentState?.reset();
    });
  }

  // ==============================================================
  // Continue
  // ==============================================================

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ============================================================
    // TEMPORARY DEVELOPMENT FLOW
    //
    // We do not have the real authentication backend connected
    // yet, so Create Account temporarily takes us directly to
    // Finding Your Voice.
    //
    // This will later be replaced by the real account creation
    // process after Supabase/Firebase authentication is connected.
    // ============================================================

    if (!_isSignIn) {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(
            milliseconds: 500,
          ),
          reverseTransitionDuration: const Duration(
            milliseconds: 350,
          ),
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              const FindingYourVoiceScreen(),
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
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // Temporary sign-in placeholder
    // ------------------------------------------------------------

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sign in will be connected soon.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==============================================================
  // Validation
  // ==============================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email address';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Enter your password';
    }

    if (!_isSignIn && password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // ==============================================================
  // Input decoration
  // ==============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: VentvoColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: VentvoColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: VentvoColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: VentvoColors.primary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: VentvoColors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: VentvoColors.error,
          width: 1.4,
        ),
      ),
    );
  }

  // ==============================================================
  // Forgot password
  // ==============================================================

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset will be connected soon.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==============================================================
  // Build
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ==========================================================
          // Atmospheric glows
          // ==========================================================

          Positioned(
            top: -180,
            right: -140,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VentvoColors.primary.withValues(
                    alpha: 0.055,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -210,
            left: -160,
            child: IgnorePointer(
              child: Container(
                width: 430,
                height: 430,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VentvoColors.secondary.withValues(
                    alpha: 0.035,
                  ),
                ),
              ),
            ),
          ),

          // ==========================================================
          // Main content
          // ==========================================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                28,
                12,
                28,
                32,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ==================================================
                  // Ventvo mark
                  // ==================================================

                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: const VentvoMark(
                        size: 68,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // Heading + form
                  // ==================================================

                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            transitionBuilder: (
                              child,
                              animation,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              _isSignIn
                                  ? 'Welcome back.'
                                  : 'Create your account.',
                              key: ValueKey(
                                _isSignIn,
                              ),
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            transitionBuilder: (
                              child,
                              animation,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              _isSignIn
                                  ? 'Your space is waiting for you.'
                                  : 'Make space for what you feel.',
                              key: ValueKey(
                                'subtitle_$_isSignIn',
                              ),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: VentvoColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ==================================================
                          // Form
                          // ==================================================

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Email',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: VentvoColors.textSecondary,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _emailController,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  textInputAction:
                                      TextInputAction.next,
                                  autocorrect: false,
                                  validator: _validateEmail,
                                  decoration: _inputDecoration(
                                    hintText: 'you@example.com',
                                    icon: Icons.mail_outline_rounded,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  'Password',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: VentvoColors.textSecondary,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction:
                                      TextInputAction.done,
                                  validator: _validatePassword,
                                  onFieldSubmitted: (_) {
                                    _continue();
                                  },
                                  decoration: _inputDecoration(
                                    hintText: 'Your password',
                                    icon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword =
                                              !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                ),

                                if (_isSignIn) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _forgotPassword,
                                      child: const Text(
                                        'Forgot password?',
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 28),

                                // ==================================================
                                // Primary button
                                // ==================================================

                                FadeTransition(
                                  opacity: _buttonFade,
                                  child: SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _continue,
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
                                      child: Text(
                                        _isSignIn
                                            ? 'Sign In'
                                            : 'Create Account',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // Switch mode
                          // ==================================================

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignIn
                                    ? "Don't have an account?"
                                    : 'Already have an account?',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: VentvoColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleMode,
                                child: Text(
                                  _isSignIn
                                      ? 'Create one'
                                      : 'Sign in',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}