import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/clay_theme.dart';
import 'data/repositories/local_storage_repository.dart';
import 'data/models/user_profile.dart';
import 'data/services/auth_service.dart';
import 'features/app_providers.dart';
import 'features/auth/login_screen.dart';
import 'features/main_navigation_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final localRepo = LocalStorageRepository(prefs);
  final authService = AuthService(prefs);

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init note: ');
  }

  // Load existing profile or prepare initial default
  UserProfile? profile = localRepo.getUserProfile();
  if (profile == null) {
    profile = UserProfile.defaultProfile();
    await localRepo.saveUserProfile(profile);
  }

  runApp(
    ProviderScope(
      overrides: [
        localStorageRepositoryProvider.overrideWithValue(localRepo),
        authServiceProvider.overrideWithValue(authService),
      ],
      child: const WeTrackApp(),
    ),
  );
}

class WeTrackApp extends ConsumerWidget {
  const WeTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final isLocked = ref.watch(appLockProvider);
    final authService = ref.watch(authServiceProvider);
    ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'WeTrack',
      debugShowCheckedModeBanner: false,
      theme: ClayTheme.lightTheme,
      home: _resolveHome(isLocked, profile, authService),
    );
  }

  Widget _resolveHome(bool isLocked, UserProfile profile, AuthService authService) {
    if (!authService.isAuthenticated) {
      return const LoginScreen();
    }
    if (isLocked) {
      return const PinLockScreen();
    }
    if (!profile.hasCompletedOnboarding) {
      return OnboardingScreen(onComplete: () {});
    }
    return const MainNavigationShell();
  }
}
