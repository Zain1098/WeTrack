import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/auth_service.dart';
import '../app_providers.dart';
import '../main_navigation_shell.dart';
import '../settings/pin_lock_screen.dart';
import '../onboarding/onboarding_screen.dart';

enum AuthScreenMode {
  login,
  signUp,
  forgotPassword,
  otpVerification,
  newPassword,
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.initialMode = AuthScreenMode.login,
    this.onSuccess,
  });

  final AuthScreenMode initialMode;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key, this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      initialMode: AuthScreenMode.signUp,
      onSuccess: onSuccess,
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.onSuccess});
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      initialMode: AuthScreenMode.forgotPassword,
      onSuccess: onSuccess,
    );
  }
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late AuthScreenMode _mode;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  // 8-Digit OTP Controllers & Focus Nodes (matching Supabase's 8-digit tokens)
  final List<TextEditingController> _otpControllers =
      List.generate(8, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(8, (_) => FocusNode());

  // Resend Countdown Timer
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;
  String? _devOtpNotice;

  // Track if OTP verification is for recovery (forgot password) or signup
  bool _isRecoveryOtp = false;
  bool _isSignUpOtp = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn && mounted) {
          _navigateToNextScreen();
        }
      });
    } catch (_) {}
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    if (widget.onSuccess != null) {
      widget.onSuccess!();
      return;
    }
    ref.invalidate(userProfileProvider);
    final repo = ref.read(localStorageRepositoryProvider);
    final profile = ref.read(userProfileProvider);
    final isLocked = repo.getPinCode() != null;

    if (isLocked) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PinLockScreen()),
        (route) => false,
      );
    } else if (!profile.hasCompletedOnboarding) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onComplete: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                (route) => false,
              );
            },
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        (route) => false,
      );
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isLoading = true);
    final auth = ref.read(authServiceProvider);
    await auth.continueAsGuest();
    if (mounted) {
      setState(() => _isLoading = false);
      _navigateToNextScreen();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _switchMode(AuthScreenMode newMode) {
    setState(() {
      _mode = newMode;
      _errorMessage = null;
      _successMessage = null;
      _devOtpNotice = null;
    });

    if (newMode == AuthScreenMode.otpVerification) {
      _startResendTimer();
      // Clear OTP inputs
      for (final c in _otpControllers) {
        c.clear();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_otpFocusNodes[0].canRequestFocus) {
          _otpFocusNodes[0].requestFocus();
        }
      });
    } else {
      _resendTimer?.cancel();
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
          _resendCountdown = 0;
        });
      }
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      if (_isRecoveryOtp) {
        await auth.sendPasswordReset(email);
      } else if (_isSignUpOtp) {
        await auth.resendSignupOtp(email);
      } else {
        await auth.sendEmailOtp(email: email);
      }

      _startResendTimer();
      final devCode = auth.lastDevOtp;
      setState(() {
        _successMessage = 'A new verification code has been sent to $email';
        if (devCode != null) {
          _devOtpNotice = 'Test Code: $devCode (Configure SMTP in Supabase for inbox delivery)';
        }
      });
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Could not resend code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (_mode == AuthScreenMode.otpVerification) {
      await _verifyOtp();
      return;
    }

    if (_mode == AuthScreenMode.newPassword) {
      await _saveNewPassword();
      return;
    }

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    // Forgot Password Trigger -> Send OTP
    if (_mode == AuthScreenMode.forgotPassword) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });
      try {
        final auth = ref.read(authServiceProvider);
        await auth.sendPasswordReset(email);
        _isRecoveryOtp = true;
        _isSignUpOtp = false;
        _switchMode(AuthScreenMode.otpVerification);
        final devCode = auth.lastDevOtp;
        setState(() {
          _successMessage = 'Password reset code sent to $email';
          if (devCode != null) {
            _devOtpNotice = 'Test Code: $devCode (Configure SMTP in Supabase for direct email)';
          }
        });
      } on AuthException catch (e) {
        if (e.message.toLowerCase().contains('rate limit')) {
          setState(() => _errorMessage = 'Too many requests. Please wait a few moments before requesting a new code.');
        } else {
          setState(() => _errorMessage = e.message);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Unable to send recovery code. Please check your email address and connection.';
        });
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters long.');
      return;
    }

    // Sign Up Flow
    if (_mode == AuthScreenMode.signUp) {
      if (confirmPassword.isEmpty) {
        setState(() => _errorMessage = 'Please confirm your password.');
        return;
      }
      if (password != confirmPassword) {
        setState(() => _errorMessage = 'Passwords do not match.');
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      try {
        final auth = ref.read(authServiceProvider);

        // Initiate sign up
        final response = await auth.signUpWithEmail(
          email: email,
          password: password,
          name: name.isNotEmpty ? name : null,
        );

        if (name.isNotEmpty) {
          await ref.read(userProfileProvider.notifier).updateProfile(name: name);
        }

        // Check if user is already confirmed (if Confirm Email is OFF in Supabase)
        if (response.session != null) {
          if (mounted) {
            if (widget.onSuccess != null) {
              widget.onSuccess!();
            } else {
              ref.invalidate(userProfileProvider);
            }
          }
          return;
        }

        // If email confirmation is required, show OTP screen
        // Note: Supabase signUpWithEmail already dispatches the Confirm Signup OTP!
        _isSignUpOtp = true;
        _isRecoveryOtp = false;
        _switchMode(AuthScreenMode.otpVerification);
        _startResendTimer();
        final devCode = auth.lastDevOtp;
        setState(() {
          _successMessage = 'Verification code sent to $email';
          if (devCode != null) {
            _devOtpNotice = 'Test Code: $devCode (Configure SMTP in Supabase for direct email)';
          }
        });
      } on AuthException catch (e) {
        if (e.message.toLowerCase().contains('already registered') ||
            e.statusCode == '422') {
          setState(() => _errorMessage = 'This email is already registered. Please log in instead.');
        } else if (e.message.toLowerCase().contains('rate limit')) {
          setState(() => _errorMessage = 'Too many attempts. Please wait a moment before trying again.');
        } else {
          setState(() => _errorMessage = e.message);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Could not complete registration. Please check your details and connection.';
        });
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    // Standard Login
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithEmail(
        email: email,
        password: password,
      );

      if (mounted) {
        _navigateToNextScreen();
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        final auth = ref.read(authServiceProvider);
        await auth.sendEmailOtp(email: email);
        _isRecoveryOtp = false;
        _switchMode(AuthScreenMode.otpVerification);
        final devCode = auth.lastDevOtp;
        setState(() {
          _errorMessage = 'Please verify your email code below to continue.';
          if (devCode != null) {
            _devOtpNotice = 'Test Code: $devCode';
          }
        });
      } else if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.statusCode == '400') {
        setState(() => _errorMessage = 'Incorrect email or password. Please check your credentials.');
      } else {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Unable to log in. Please check your credentials and internet connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otpCode = _otpControllers.map((c) => c.text.trim()).join();

    if (otpCode.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);

      if (_isRecoveryOtp) {
        // Recovery OTP verified -> proceed to set new password
        _switchMode(AuthScreenMode.newPassword);
        setState(() {
          _successMessage = 'Code verified! Now set your new password.';
        });
      } else {
        // Sign up / email verification
        await auth.verifyEmailOtp(
          email: email,
          token: otpCode,
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
          isSignUp: _isSignUpOtp,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account verified successfully! Welcome to WeTrack.'),
              backgroundColor: const Color(0xFF9E8CE7),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );

          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            if (_nameController.text.trim().isNotEmpty) {
              await ref.read(userProfileProvider.notifier).updateProfile(
                    name: _nameController.text.trim(),
                  );
            }
            if (!mounted) return;
            ref.invalidate(userProfileProvider);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigationShell()),
              (route) => false,
            );
          }
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid or expired code. Please enter the latest code received.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNewPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final otpCode = _otpControllers.map((c) => c.text.trim()).join();

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters long.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.verifyRecoveryOtp(
        email: email,
        token: otpCode,
        newPassword: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password updated successfully! Logged in.'),
            backgroundColor: const Color(0xFF9E8CE7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );

        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          ref.invalidate(userProfileProvider);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationShell()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      // User pasted whole code or auto-fill triggered!
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 8 && i < digits.length; i++) {
        _otpControllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        final lastIdx = digits.length <= 8 ? digits.length - 1 : 7;
        _otpFocusNodes[lastIdx].unfocus();
        _verifyOtp();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 7) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
        _verifyOtp();
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final response = await auth.signInWithGoogle();

      if (mounted) {
        if (response?.user != null || auth.isAuthenticated) {
          ref.invalidate(userProfileProvider);
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigationShell()),
              (route) => false,
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign-in could not be completed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithFacebook();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Facebook sign-in could not be completed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSocialTap(String provider) {
    if (provider == 'Google') {
      _handleGoogleSignIn();
      return;
    }
    if (provider == 'Facebook') {
      _handleFacebookSignIn();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login is coming soon! Please use Google, Facebook, or Email.'),
        backgroundColor: const Color(0xFF9E8CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCCFEF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image with Clouds & Potted Plants
          Positioned.fill(
            child: Image.asset(
              'UI/login screen background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFDCCFEF),
              ),
            ),
          ),

          // 2. Main Content inside SafeArea
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _buildOuterClayCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The Large Off-White Pastel Clay Frame
  Widget _buildOuterClayCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FE),
        borderRadius: BorderRadius.circular(38),
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
        boxShadow: [
          // Soft outer clay purple ambient shadow
          BoxShadow(
            color: const Color(0xFF5A448E).withValues(alpha: 0.18),
            blurRadius: 36,
            offset: const Offset(0, 16),
            spreadRadius: 2,
          ),
          // White top-left specular highlight
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            blurRadius: 12,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 22),

          // Cute Pink Heart at Top Center (from lllove.svg)
          _buildHeartHeader(),

          const SizedBox(height: 8),

          // Title with 3D Golden-Yellow Rays
          _buildSparksTitle(),

          const SizedBox(height: 4),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _getSubtitleText(),
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF867D9C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Baby Mascot seamlessly leaning onto the Inner Form Card
          _buildMascotAndFormSection(),
        ],
      ),
    );
  }

  /// Top Pink Clay Heart (from lllove.svg)
  Widget _buildHeartHeader() {
    return Center(
      child: SvgPicture.asset(
        'UI/lllove.svg',
        width: 28,
        height: 28,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const Icon(
          Icons.favorite_rounded,
          color: Color(0xFFFF85A1),
          size: 26,
        ),
      ),
    );
  }

  /// Title with 3D Golden Sparks on Left & Right
  Widget _buildSparksTitle() {
    final title = _getTitleText();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left 3D Golden Rays
        const CustomPaint(
          size: Size(20, 22),
          painter: _ClayRaysPainter(isLeft: true),
        ),
        const SizedBox(width: 6),

        // Main Title
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5D4E96),
              letterSpacing: 0.2,
            ),
          ),
        ),

        const SizedBox(width: 6),
        // Right 3D Golden Rays
        const CustomPaint(
          size: Size(20, 22),
          painter: _ClayRaysPainter(isLeft: false),
        ),
      ],
    );
  }

  String _getTitleText() {
    switch (_mode) {
      case AuthScreenMode.login:
        return 'Welcome Back';
      case AuthScreenMode.signUp:
        return 'Create Account';
      case AuthScreenMode.forgotPassword:
        return 'Reset Password';
      case AuthScreenMode.otpVerification:
        return 'Verify Code';
      case AuthScreenMode.newPassword:
        return 'New Password';
    }
  }

  String _getSubtitleText() {
    switch (_mode) {
      case AuthScreenMode.login:
        return 'Login to continue your journey';
      case AuthScreenMode.signUp:
        return 'Sign up to start your journey';
      case AuthScreenMode.forgotPassword:
        return 'Enter your email to receive a recovery code';
      case AuthScreenMode.otpVerification:
        return 'Enter the 6-digit code sent to\n${_emailController.text.trim()}';
      case AuthScreenMode.newPassword:
        return 'Create a secure new password for your account';
    }
  }

  /// Baby Mascot resting elbows and hands directly on the white form card
  Widget _buildMascotAndFormSection() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // 1. The Inner White Clay Form Card
        Padding(
          padding: const EdgeInsets.only(top: 104), // Leaves space for baby peeking
          child: _buildInnerFormCard(),
        ),

        // 2. Baby Cutout sitting directly over the top of the form card
        Positioned(
          top: 0,
          child: Image.asset(
            'UI/login_screen_Character-removebg-preview.png',
            width: 172,
            height: 116,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(height: 100),
          ),
        ),
      ],
    );
  }

  /// Inner Clay Form Card containing fields, buttons, and social options
  Widget _buildInnerFormCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFF3EDF9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A448E).withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Developer / Test Code Notice (so user is never blocked before SMTP configuration)
          if (_devOtpNotice != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E7FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD6BCFA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: Color(0xFF7E60BF), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _devOtpNotice!,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF5A3E96),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Error Message Banner
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB3C1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFD6336C), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFFC2255C),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success Message Banner
          if (_successMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDFBF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF9AE6B4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Color(0xFF228B22), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF228B22),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // MODE: OTP VERIFICATION
          if (_mode == AuthScreenMode.otpVerification) ...[
            _buildOtpInputBoxes(),
            const SizedBox(height: 14),
            _buildResendRow(),
            const SizedBox(height: 18),
            _buildClayActionButton(),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: () => _switchMode(AuthScreenMode.signUp),
                child: Text(
                  'Change Email or Back',
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    color: const Color(0xFF725EB8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ]
          // MODE: SET NEW PASSWORD
          else if (_mode == AuthScreenMode.newPassword) ...[
            _buildClayInputField(
              controller: _passwordController,
              hint: 'New Password',
              badgeIcon: Icons.lock_rounded,
              isPassword: true,
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            const SizedBox(height: 12),
            _buildClayInputField(
              controller: _confirmPasswordController,
              hint: 'Confirm New Password',
              badgeIcon: Icons.lock_rounded,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            const SizedBox(height: 18),
            _buildClayActionButton(),
          ]
          // MODES: LOGIN, SIGN UP, FORGOT PASSWORD
          else ...[
            // Sign Up: Full Name Field
            if (_mode == AuthScreenMode.signUp) ...[
              _buildClayInputField(
                controller: _nameController,
                hint: 'Full Name',
                badgeIcon: Icons.person_rounded,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 12),
            ],

            // Email Field
            _buildClayInputField(
              controller: _emailController,
              hint: _mode == AuthScreenMode.login ? 'Email or Username' : 'Email Address',
              badgeIcon: _mode == AuthScreenMode.login ? Icons.person_rounded : Icons.mail_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // Password Field (Login & Sign Up)
            if (_mode != AuthScreenMode.forgotPassword) ...[
              _buildClayInputField(
                controller: _passwordController,
                hint: 'Password',
                badgeIcon: Icons.lock_rounded,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ],

            // Sign Up: Confirm Password Field
            if (_mode == AuthScreenMode.signUp) ...[
              const SizedBox(height: 12),
              _buildClayInputField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                badgeIcon: Icons.lock_rounded,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ],

            // Forgot Password link (in Login mode)
            if (_mode == AuthScreenMode.login) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _switchMode(AuthScreenMode.forgotPassword),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        color: const Color(0xFF725EB8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),

            // Primary Pastel Clay Button
            _buildClayActionButton(),

            // Divider and Social Logins (in Login & Sign Up modes)
            if (_mode != AuthScreenMode.forgotPassword) ...[
              const SizedBox(height: 16),

              // "─── or continue with ───"
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE8E2F0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'or continue with',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF9E96AC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE8E2F0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3 Round Social Clay Discs: Google, Apple, Facebook
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    provider: 'Google',
                    child: _buildGoogleGIcon(),
                  ),
                  const SizedBox(width: 16),
                  _buildSocialButton(
                    provider: 'Apple',
                    child: const Icon(
                      Icons.apple_rounded,
                      color: Color(0xFF1D1B20),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildSocialButton(
                    provider: 'Facebook',
                    child: const Icon(
                      Icons.facebook_rounded,
                      color: Color(0xFF1877F2),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            // Bottom Toggle Text
            _buildBottomToggleLink(),

            // Guest / Offline Mode Option
            if (_mode == AuthScreenMode.login || _mode == AuthScreenMode.signUp) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _continueAsGuest,
                  icon: const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF7E60BF)),
                  label: Text(
                    'Continue as Guest (Offline Mode)',
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7E60BF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 8-Digit Pastel Clay OTP Input Boxes with Auto-Fill & Auto-Advance
  Widget _buildOtpInputBoxes() {
    return AutofillGroup(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(8, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 34,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _otpFocusNodes[index].hasFocus
                      ? const Color(0xFF9E8CE7)
                      : const Color(0xFFEAE3F2),
                  width: _otpFocusNodes[index].hasFocus ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _otpFocusNodes[index].hasFocus
                        ? const Color(0xFF9E8CE7).withValues(alpha: 0.25)
                        : const Color(0xFF5A448E).withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        _otpControllers[index].text.isEmpty &&
                        index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5D4E96),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(8),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => _onOtpChanged(index, val),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Resend Code Row with Countdown
  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: const Color(0xFF867D9C),
          ),
        ),
        GestureDetector(
          onTap: _canResend ? _resendOtp : null,
          child: Text(
            _canResend ? 'Resend' : 'Resend in ${_resendCountdown}s',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _canResend ? const Color(0xFF725EB8) : const Color(0xFFA197B4),
            ),
          ),
        ),
      ],
    );
  }

  /// Soft Pastel Clay Input Field with Purple Circular Icon Badge
  Widget _buildClayInputField({
    required TextEditingController controller,
    required String hint,
    required IconData badgeIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1F8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEBE5F2),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Left Purple Clay Circular Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF9E8CE7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9E8CE7).withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              badgeIcon,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),

          // Input Text Field
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscureText : false,
              keyboardType: keyboardType,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF2C2738),
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hint,
                hintStyle: GoogleFonts.nunito(
                  fontSize: 13.5,
                  color: const Color(0xFFA199B0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Password Visibility Toggle Suffix
          if (isPassword)
            IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF9288A5),
                size: 20,
              ),
              splashRadius: 20,
              onPressed: onToggleVisibility,
            ),
        ],
      ),
    );
  }

  /// 3D Clay Purple Button with Soft Drop Shadow
  Widget _buildClayActionButton() {
    String buttonText;
    switch (_mode) {
      case AuthScreenMode.login:
        buttonText = 'Login';
        break;
      case AuthScreenMode.signUp:
        buttonText = 'Sign Up';
        break;
      case AuthScreenMode.forgotPassword:
        buttonText = 'Send Reset Code';
        break;
      case AuthScreenMode.otpVerification:
        buttonText = 'Verify & Continue';
        break;
      case AuthScreenMode.newPassword:
        buttonText = 'Update Password';
        break;
    }

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF9E8CE7),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          // Prominent soft clay shadow below button
          BoxShadow(
            color: const Color(0xFF9E8CE7).withValues(alpha: 0.5),
            offset: const Offset(0, 7),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          // Top specular highlight
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            offset: const Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: _isLoading ? null : _submit,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.6,
                    ),
                  )
                : Text(
                    buttonText,
                    style: GoogleFonts.nunito(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Round Clay Social Button
  Widget _buildSocialButton({
    required String provider,
    required Widget child,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFEDE7F5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A448E).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onSocialTap(provider),
          child: Center(child: child),
        ),
      ),
    );
  }

  /// Multi-color Google G Icon
  Widget _buildGoogleGIcon() {
    return Text(
      'G',
      style: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: const Color(0xFFEA4335), // Google Red
      ),
    );
  }

  /// Bottom Mode Toggle Link
  Widget _buildBottomToggleLink() {
    String prefix;
    String action;
    VoidCallback onTap;

    switch (_mode) {
      case AuthScreenMode.login:
        prefix = "Don't have an account? ";
        action = "Sign Up";
        onTap = () => _switchMode(AuthScreenMode.signUp);
        break;
      case AuthScreenMode.signUp:
        prefix = "Already have an account? ";
        action = "Log In";
        onTap = () => _switchMode(AuthScreenMode.login);
        break;
      case AuthScreenMode.forgotPassword:
        prefix = "Remember your password? ";
        action = "Log In";
        onTap = () => _switchMode(AuthScreenMode.login);
        break;
      case AuthScreenMode.otpVerification:
      case AuthScreenMode.newPassword:
        prefix = "Back to ";
        action = "Log In";
        onTap = () => _switchMode(AuthScreenMode.login);
        break;
    }

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: RichText(
            text: TextSpan(
              text: prefix,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF7E768E),
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: action,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF725EB8),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter for the cute 3D golden-yellow rays on either side of the title
class _ClayRaysPainter extends CustomPainter {
  const _ClayRaysPainter({required this.isLeft});
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF9C73D) // Warm golden clay yellow
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    if (isLeft) {
      canvas.drawLine(
        Offset(cx + 6, cy - 6),
        Offset(cx - 6, cy - 10),
        paint,
      );
      canvas.drawLine(
        Offset(cx + 8, cy),
        Offset(cx - 8, cy),
        paint,
      );
      canvas.drawLine(
        Offset(cx + 6, cy + 6),
        Offset(cx - 6, cy + 10),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(cx - 6, cy - 6),
        Offset(cx + 6, cy - 10),
        paint,
      );
      canvas.drawLine(
        Offset(cx - 8, cy),
        Offset(cx + 8, cy),
        paint,
      );
      canvas.drawLine(
        Offset(cx - 6, cy + 6),
        Offset(cx + 6, cy + 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClayRaysPainter oldDelegate) =>
      oldDelegate.isLeft != isLeft;
}
