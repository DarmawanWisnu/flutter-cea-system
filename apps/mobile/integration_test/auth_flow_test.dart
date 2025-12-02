import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/auth/login_screen.dart';
import 'package:fountaine/features/auth/register_screen.dart';
import 'package:fountaine/features/auth/forgot_password_screen.dart';
import 'package:fountaine/features/home/home_screen.dart';

/// Integration Test for Authentication Flow
/// 
/// This test suite covers the complete authentication user journey:
/// - Login with valid/invalid credentials
/// - Navigation to registration
/// - Navigation to forgot password
/// - Form validation
/// 
/// These are BLACK BOX tests - they test from the user's perspective
/// without knowledge of internal implementation details.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('should display login screen with all elements',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Verify all UI elements are present
      expect(find.text('Hello Again!'), findsOneWidget);
      expect(find.text("Welcome Back You've Been Missed!"), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Recovery Password'), findsOneWidget);
      expect(find.text("Don't Have An Account? "), findsOneWidget);
    });

    testWidgets('should validate email field on login attempt',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Try to login without entering email
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Assert - Should show validation error
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should validate password field on login attempt',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Enter email but no password
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Assert - Should show password validation error
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should validate email format',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Enter invalid email format
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Assert - Should show email format error
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Find and tap the visibility toggle icon
      final visibilityOffIcon = find.byIcon(Icons.visibility_off);
      expect(visibilityOffIcon, findsOneWidget);
      
      await tester.tap(visibilityOffIcon);
      await tester.pumpAndSettle();

      // Assert - Icon should change to visibility (eye open)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('should navigate to registration screen',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/register': (context) => const RegisterScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap on "Sign Up For Free" link
      final signUpLink = find.text('Sign Up For Free');
      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      // Assert - Should navigate to register screen
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should navigate to forgot password screen',
        (WidgetTester tester) async {
      // Arrange
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

      // Act - Tap on "Recovery Password" link
      final recoveryLink = find.text('Recovery Password');
      await tester.tap(recoveryLink);
      await tester.pumpAndSettle();

      // Assert - Should navigate to forgot password screen
      expect(find.text('Forgot Password'), findsOneWidget);
    });

    testWidgets('should accept valid login credentials input',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Enter valid email and password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);
      
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'SecurePassword123');
      await tester.pump();

      // Assert - Fields should contain the entered values
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('SecurePassword123'), findsOneWidget);
    });

    testWidgets('should show loading indicator when signing in',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Enter valid credentials and tap sign in
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Assert - Should show loading indicator
      // Note: This will show briefly before error appears
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
