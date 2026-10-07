import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String supabaseUrl = 'https://blqesxwxmytbuoenpuio.supabase.co';
const String supabaseAnonKey = 'sb_publishable_Voc57bB0GGDvtAnTPpRi4A_HEeMIaWw';

/// Optional: Google Web Client ID from Google Cloud Console for Native 1-Tap Google Sign-In
/// Example: '123456789-abcdef.apps.googleusercontent.com'
const String? googleWebClientId = null;

class AuthService {
  AuthService(this._prefs);
  final SharedPreferences _prefs;

  String? _lastDevOtp;
  String? get lastDevOtp => kDebugMode ? _lastDevOtp : null;

  User? get currentUser {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isGuestUser => _prefs.getBool('is_guest_user') ?? false;

  bool get isAuthenticated => currentUser != null || isGuestUser;

  Future<void> continueAsGuest() async {
    await _prefs.setBool('is_guest_user', true);
  }

  Stream<AuthState> get authStateChanges {
    try {
      return Supabase.instance.client.auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Explicit login - no guest bypass
    await _prefs.setBool('is_guest_user', false);
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user != null) {
      await syncUserToDatabase(
        userId: response.user!.id,
        email: email.trim(),
        name: response.user!.userMetadata?['full_name'] as String?,
      );
    }

    return response;
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    await _prefs.setBool('is_guest_user', false);
    final trimmedName = name?.trim();
    final metaData = <String, dynamic>{};
    if (trimmedName != null && trimmedName.isNotEmpty) {
      metaData['full_name'] = trimmedName;
      metaData['name'] = trimmedName;
    }

    final response = await Supabase.instance.client.auth.signUp(
      email: email.trim(),
      password: password,
      data: metaData.isNotEmpty ? metaData : null,
    );

    if (response.user != null) {
      await syncUserToDatabase(
        userId: response.user!.id,
        email: email.trim(),
        name: trimmedName,
      );
    }

    return response;
  }

  /// Direct Google Sign-In: Native Google Account Picker with In-App OAuth Fallback
  Future<AuthResponse?> signInWithGoogle({String? webClientId}) async {
    await _prefs.setBool('is_guest_user', false);
    final effectiveClientId = webClientId ?? googleWebClientId;

    // 1. Try Native Google Sign-In (one-tap account selector)
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: effectiveClientId,
        scopes: const ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;
        final String? accessToken = googleAuth.accessToken;

        if (idToken != null) {
          final response = await Supabase.instance.client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

          if (response.user != null) {
            await syncUserToDatabase(
              userId: response.user!.id,
              email: response.user!.email ?? googleUser.email,
              name: response.user!.userMetadata?['full_name'] as String? ?? googleUser.displayName,
            );
          }
          return response;
        }
      } else {
        // User dismissed native sign-in dialog
        return null;
      }
    } catch (e) {
      debugPrint('Native Google Sign-In note: $e, launching in-app OAuth fallback...');
    }

    // 2. OAuth Fallback: Uses inAppBrowserView for seamless deep link return to the app
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.wetrack://login-callback',
      authScreenLaunchMode: LaunchMode.inAppBrowserView,
    );
    return null;
  }

  /// Direct Facebook Sign-In via Supabase OAuth
  Future<void> signInWithFacebook() async {
    await _prefs.setBool('is_guest_user', false);
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: kIsWeb ? null : 'io.supabase.wetrack://login-callback',
      authScreenLaunchMode: LaunchMode.inAppBrowserView,
    );
  }

  /// Sends Email OTP (via Supabase or fallback dev OTP if SMTP not configured)
  Future<void> sendEmailOtp({
    required String email,
    bool shouldCreateUser = true,
  }) async {
    if (kDebugMode) {
      final randomCode = (10000000 + Random().nextInt(90000000)).toString();
      _lastDevOtp = randomCode;
    } else {
      _lastDevOtp = null;
    }

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: shouldCreateUser,
      );
    } catch (e) {
      debugPrint('Supabase signInWithOtp note: $e');
    }
  }

  /// Resends Signup verification OTP
  Future<void> resendSignupOtp(String email) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
    } catch (e) {
      debugPrint('Resend signup OTP error: $e, falling back to signInWithOtp');
      await sendEmailOtp(email: email);
    }
  }

  /// Verifies OTP code for user registration / login
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
    String? name,
    bool isSignUp = false,
  }) async {
    await _prefs.setBool('is_guest_user', false);
    final cleanToken = token.trim();

    // Check if matching dev/fallback OTP (strictly debug mode only)
    if (kDebugMode && _lastDevOtp != null && cleanToken == _lastDevOtp) {
      final user = currentUser;
      if (user != null) {
        await syncUserToDatabase(
          userId: user.id,
          email: email.trim(),
          name: name,
        );
      }
      return AuthResponse(session: Supabase.instance.client.auth.currentSession, user: user);
    }

    // 1. If this was initiated from Sign Up, verify signup OTP first
    if (isSignUp) {
      try {
        final response = await Supabase.instance.client.auth.verifyOTP(
          email: email.trim(),
          token: cleanToken,
          type: OtpType.signup,
        );
        if (response.user != null) {
          await syncUserToDatabase(
            userId: response.user!.id,
            email: email.trim(),
            name: name ?? response.user!.userMetadata?['full_name'] as String?,
          );
        }
        return response;
      } on AuthException catch (e) {
        debugPrint('verifyOTP signup failed (${e.message}), attempting OtpType.email fallback...');
      }
    }

    // 2. Attempt OtpType.email verification
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: email.trim(),
        token: cleanToken,
        type: OtpType.email,
      );

      if (response.user != null) {
        await syncUserToDatabase(
          userId: response.user!.id,
          email: email.trim(),
          name: name ?? response.user!.userMetadata?['full_name'] as String?,
        );
      }
      return response;
    } catch (_) {
      // 3. Fallback to OtpType.signup
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: email.trim(),
        token: cleanToken,
        type: OtpType.signup,
      );

      if (response.user != null) {
        await syncUserToDatabase(
          userId: response.user!.id,
          email: email.trim(),
          name: name ?? response.user!.userMetadata?['full_name'] as String?,
        );
      }
      return response;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (kDebugMode) {
      final randomCode = (10000000 + Random().nextInt(90000000)).toString();
      _lastDevOtp = randomCode;
    } else {
      _lastDevOtp = null;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      debugPrint('Supabase resetPasswordForEmail note: $e');
    }
  }

  Future<AuthResponse> verifyRecoveryOtp({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final cleanToken = token.trim();

    if (kDebugMode && _lastDevOtp != null && cleanToken == _lastDevOtp) {
      // Dev OTP accepted (debug mode only)
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      } catch (_) {}
      return AuthResponse(session: Supabase.instance.client.auth.currentSession, user: currentUser);
    }

    final response = await Supabase.instance.client.auth.verifyOTP(
      email: email.trim(),
      token: cleanToken,
      type: OtpType.recovery,
    );

    if (response.user != null) {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    }

    return response;
  }

  Future<void> syncUserToDatabase({
    required String userId,
    required String email,
    String? name,
    String? avatarUrl,
    int? age,
    String? maritalStatus,
    double? heightCm,
    double? weightKg,
    String? goal,
  }) async {
    try {
      final payload = <String, dynamic>{
        'id': userId,
        'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;
      if (age != null) payload['age'] = age;
      if (maritalStatus != null) payload['marital_status'] = maritalStatus;
      if (heightCm != null) payload['height_cm'] = heightCm;
      if (weightKg != null) payload['weight_kg'] = weightKg;
      if (goal != null) payload['goal'] = goal;

      await Supabase.instance.client.from('profiles').upsert(payload);
    } catch (e) {
      debugPrint('Note: Supabase profiles sync skipped ($e)');
    }
  }

  Future<void> signOut() async {
    await _prefs.setBool('is_guest_user', false);
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('SignOut exception: $e');
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('authServiceProvider must be overridden in main.dart');
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
