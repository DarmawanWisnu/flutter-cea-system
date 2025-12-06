/// Profile Screen Widget Tests
///
/// Tests the ProfileScreen widget for proper rendering of user profile info.
/// Uses mock auth and API providers to avoid Firebase and network dependencies.
/// Covers:
/// - AppBar elements (back button, title)
/// - User avatar and profile info
/// - Edit Profile and Logout buttons
/// - Info tiles (User ID, Email, Kit Name, Kit ID)
/// - Active status badge
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/profile/profile_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/test_overflow_handler.dart';

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

/// Creates wrapper with ProviderScope for testing ProfileScreen.
Widget wrapProfileForTest(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  /// Creates test overrides combining auth and API providers.
  createTestOverrides() {
    return <Override>[
      apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
      apiKitsListProvider.overrideWith((ref) async {
        return [
          {'id': 'test-kit-001', 'name': 'Test Kit 1'},
        ];
      }),
      ...createAuthOverrides(),
    ];
  }

  group('Profile Screen Widget Tests', () {
    /// Warmup test to initialize Flutter test environment.
    testWidgets('warmup', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(true, isTrue);
    });

    /// Verifies back button is present.
    testWidgets('should display back button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Verifies Profile title is displayed.
    testWidgets('should display Profile title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.text('Profile'), findsWidgets);
    });

    /// Verifies user avatar icon is displayed.
    testWidgets('should display user avatar icon', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.byIcon(Icons.person), findsWidgets);
    });

    /// Verifies Edit Profile button is displayed.
    testWidgets('should display Edit Profile button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    /// Verifies Logout button is displayed.
    testWidgets('should display Logout button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.text('Logout'), findsOneWidget);
    });

    /// Verifies info tile labels are displayed.
    testWidgets('should display info tile labels', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Kit Name'), findsOneWidget);
      expect(find.text('Kit ID'), findsOneWidget);
    });

    /// Verifies info tile icons are displayed.
    testWidgets('should display info tile icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.view_in_ar_outlined), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2_outlined), findsOneWidget);
    });

    /// Verifies ACTIVE status badge is displayed.
    testWidgets('should display ACTIVE badge', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
    });

    /// Verifies edit icon on Edit Profile button is displayed.
    testWidgets('should display edit icon on Edit Profile button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        wrapProfileForTest(const ProfileScreen(), createTestOverrides()),
      );

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });
  });
}
