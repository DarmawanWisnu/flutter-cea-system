/// Settings Screen Widget Tests
///
/// Tests the SettingsScreen widget for proper rendering of settings options.
/// Uses mock auth providers to avoid Firebase dependencies.
/// Covers:
/// - AppBar elements (back button, title)
/// - Account settings section
/// - Legal section
/// - Logout functionality
/// - Version display
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fountaine/features/settings/settings_screen.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/test_overflow_handler.dart';
import '../helpers/mock_providers.dart';

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
    ...createUrlOverrides(),
  ];
}

void main() {
  group('Settings Screen Widget Tests', () {
    /// Helper function to pump SettingsScreen with proper viewport and overrides.
    Future<void> pumpSettingsScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        ProviderScope(
          overrides: createAuthOverrides(),
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
    }

    /// Verifies Settings title is displayed.
    testWidgets('should display Settings title', (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Settings'), findsOneWidget);
    });

    /// Verifies back button is present.
    testWidgets('should display back button', (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Verifies Account Setting section header is displayed.
    testWidgets('should display Account Setting section', (
      WidgetTester tester,
    ) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Account Setting'), findsOneWidget);
    });

    /// Verifies account setting tile labels are displayed.
    testWidgets('should display account setting tiles', (
      WidgetTester tester,
    ) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Change language'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    /// Verifies Legal section header is displayed.
    testWidgets('should display Legal section', (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Legal'), findsOneWidget);
    });

    /// Verifies legal tile labels are displayed.
    testWidgets('should display legal tiles', (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Terms and Condition'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
    });

    /// Verifies Logout button is displayed.
    testWidgets('should display Logout button', (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Logout'), findsOneWidget);
    });

    /// Verifies version text is displayed.
    testWidgets('should display version text', (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    /// Verifies View button in account header is displayed.
    testWidgets('should display View button in account header', (
      WidgetTester tester,
    ) async {
      await pumpSettingsScreen(tester);
      expect(find.text('View'), findsOneWidget);
    });

    /// Verifies setting tile icons are displayed.
    testWidgets('should display setting tile icons', (
      WidgetTester tester,
    ) async {
      await pumpSettingsScreen(tester);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });
  });
}
