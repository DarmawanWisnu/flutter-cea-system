/// Home Flow Integration Tests
///
/// End-to-end tests covering navigation flows from the home screen.
/// Tests use mock auth and API providers to avoid Firebase and network dependencies.
/// Covers:
/// - Home screen display with all features
/// - Navigation to Add Kit screen via QR button
/// - Navigation to Settings screen via person icon
/// - Navigation to History screen
/// - Bottom navigation bar functionality
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fountaine/features/home/home_screen.dart';
import 'package:fountaine/features/add_kit/add_kit_screen.dart';
import 'package:fountaine/features/settings/settings_screen.dart';
import 'package:fountaine/features/history/history_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mock AuthService that doesn't require Firebase initialization.
class MockAuthService extends AuthService {
  MockAuthService() : super(FakeFirebaseAuth());

  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;
}

/// Fake FirebaseAuth implementation for testing.
class FakeFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Creates auth provider overrides for test isolation.
List<Override> createAuthOverrides() {
  return [
    authServiceProvider.overrideWith((ref) => MockAuthService()),
    authProvider.overrideWith((ref) {
      final service = ref.read(authServiceProvider);
      return AuthNotifier(service);
    }),
  ];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Flow Integration Tests', () {
    /// Verifies home screen displays all key features.
    testWidgets('should display home screen with all features', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
            currentKitIdProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/monitor': (context) => const Scaffold(body: Text('Monitor')),
              '/history': (context) => const HistoryScreen(),
              '/addkit': (context) => const AddKitScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('All Features'), findsOneWidget);
    });

    /// Tests navigation to Add Kit screen via QR button.
    testWidgets('should navigate to Add Kit screen when QR tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {'/addkit': (context) => const AddKitScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.qr_code_2));
      await tester.pumpAndSettle();

      expect(find.text('Add Kit'), findsWidgets);
      expect(find.text('Kit Name'), findsOneWidget);
    });

    /// Tests navigation to Settings screen via person icon.
    testWidgets('should navigate to Settings screen when person icon tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [...createAuthOverrides()],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {'/settings': (context) => const SettingsScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account Setting'), findsOneWidget);
    });

    /// Tests navigation to History screen via Notification card.
    testWidgets('should navigate to History screen when Notification tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
            currentKitIdProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {'/history': (context) => const HistoryScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notification'));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });

    /// Tests bottom navigation bar navigation.
    testWidgets('should navigate via bottom nav bar icons', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
            ...createAuthOverrides(),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {'/settings': (context) => const SettingsScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    /// Tests QR button navigation to Add Kit screen.
    testWidgets('should navigate to Add Kit when QR button tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {'/addkit': (context) => const AddKitScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.qr_code_2));
      await tester.pumpAndSettle();

      expect(find.text('Add Kit'), findsWidgets);
    });
  });
}
