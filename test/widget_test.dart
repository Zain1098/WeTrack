import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetrack/data/repositories/local_storage_repository.dart';
import 'package:wetrack/data/services/auth_service.dart';
import 'package:wetrack/features/app_providers.dart';
import 'package:wetrack/main.dart';

void main() {
  testWidgets('WeTrack app initializes and renders title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'is_guest_user': true});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalStorageRepository(prefs);
    final auth = AuthService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(repo),
          authServiceProvider.overrideWithValue(auth),
        ],
        child: const WeTrackApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify unauthenticated user lands on the Login screen
    expect(find.textContaining('Welcome Back'), findsWidgets);
  });
}
