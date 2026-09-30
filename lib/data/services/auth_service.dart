import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String supabaseUrl = 'https://xejhgfyeichkibepgjii.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlamhnZnllaWNoa2liZXBnamlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM3OTEzNzQsImV4cCI6MjA5OTM2NzM3NH0.3uyqB2-1-W9rMmt5sovfbSzLB7sGtK0tlRgmZwspbH4';

class AuthService {
  AuthService(this._prefs);
  final SharedPreferences _prefs;

  User? get currentUser {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isAuthenticated => currentUser != null;

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
      await _syncUserToDatabase(
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
    // Explicit signup - save to Supabase database
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
      await _syncUserToDatabase(
        userId: response.user!.id,
        email: email.trim(),
        name: trimmedName,
      );
    }

    return response;
  }

  Future<void> sendPasswordReset(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> _syncUserToDatabase({
    required String userId,
    required String email,
    String? name,
  }) async {
    try {
      // Safely upsert into Supabase profiles database table
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      });
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
