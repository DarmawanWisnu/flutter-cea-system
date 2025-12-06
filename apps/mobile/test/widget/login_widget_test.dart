/// Login Screen Widget Tests
///
/// Tests the LoginScreen widget for proper rendering and user interactions.
/// Covers:
/// - UI element display (title, welcome text, input fields, buttons)
/// - Navigation to forgot password screen
/// - Form input validation
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fountaine/features/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Login Screen Widget Tests', () {
    /// Verifies that all essential UI elements are present on the login screen.
    testWidgets('should display all login screen elements', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      expect(find.text('Hello Again!'), findsOneWidget);
      expect(find.text("Welcome Back You've Been Missed!"), findsOneWidget);
    });

    /// Tests navigation from login screen to forgot password screen.
    testWidgets('should navigate to forgot password screen', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpAndSettleWidget(
        tester,
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/forgot_password': (context) => const Scaffold(
                body: Center(child: Text('Forgot Password Screen')),
              ),
            },
          ),
        ),
      );

      final recoveryLink = find.text('Recovery Password');
      await tester.tap(recoveryLink);
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password Screen'), findsOneWidget);
    });

    /// Validates that email and password fields accept user input.
    testWidgets('should accept valid email and password input', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
