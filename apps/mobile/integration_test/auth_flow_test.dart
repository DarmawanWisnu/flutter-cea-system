/// Authentication Flow Integration Tests
///
/// End-to-end tests covering the complete authentication user journey.
/// Tests run with real widget interactions to verify full flow functionality.
/// Covers:
/// - Login screen display and elements
/// - Email and password validation
/// - Password visibility toggle
/// - Navigation to registration and forgot password screens
/// - Valid credential input acceptance
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/auth/login_screen.dart';
import 'package:fountaine/features/auth/register_screen.dart';
import 'package:fountaine/features/auth/forgot_password_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    /// Verifies login screen displays all required UI elements.
    testWidgets('should display login screen with all elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const LoginScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello Again!'), findsOneWidget);
      expect(find.text("Welcome Back You've Been Missed!"), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Recovery Password'), findsOneWidget);
    });

    /// Tests email validation error on empty email submit.
    testWidgets('should validate email field on login attempt', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const LoginScreen())),
      );
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      expect(find.text('Email cannot be empty'), findsOneWidget);
    });

    /// Tests password validation error on empty password submit.
    testWidgets('should validate password field on login attempt', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const LoginScreen())),
      );
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      expect(find.text('Password cannot be empty'), findsOneWidget);
    });

    /// Tests email format validation.
    testWidgets('should validate email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const LoginScreen())),
      );
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    /// Tests password visibility toggle functionality.
    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const LoginScreen())),
      );
      await tester.pumpAndSettle();

      final visibilityOffIcon = find.byIcon(Icons.visibility_off);
      expect(visibilityOffIcon, findsOneWidget);

      await tester.tap(visibilityOffIcon);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    /// Tests navigation to registration screen via Sign Up link.
    testWidgets('should navigate to registration screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {'/register': (context) => const RegisterScreen()},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final richTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Sign Up For Free'),
      );

      final renderBox = tester.renderObject(richTextFinder) as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      await tester.tapAt(
        Offset(position.dx + size.width * 0.7, position.dy + size.height / 2),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    /// Tests navigation to forgot password screen.
    testWidgets('should navigate to forgot password screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/forgot_password': (context) => const ForgotPasswordScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final recoveryLink = find.text('Recovery Password');
      await tester.tap(recoveryLink);
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsOneWidget);
    });

    /// Tests that valid credentials are accepted in form fields.
    testWidgets('should accept valid login credentials input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const LoginScreen())),
      );
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'SecurePassword123');
      await tester.pump();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('SecurePassword123'), findsOneWidget);
    });
  });
}
