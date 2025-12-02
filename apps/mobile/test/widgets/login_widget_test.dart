import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fountaine/features/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Login Screen Widget Tests', () {
    testWidgets('should display all login screen elements',
        (WidgetTester tester) async {
      // Arrange & Act
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Assert
      expect(find.text('Hello Again!'), findsOneWidget);
      expect(find.text("Welcome Back You've Been Missed!"), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('should validate empty email field', (WidgetTester tester) async {
      // Arrange
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Act - Try to submit without entering email
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Assert - Should show validation error
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should validate invalid email format',
        (WidgetTester tester) async {
      // Arrange
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Act - Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Assert
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate empty password field',
        (WidgetTester tester) async {
      // Arrange
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Act - Enter email but not password
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Assert
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      // Arrange
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Find password field
      final passwordFields = find.byType(TextFormField);
      final passwordField = passwordFields.at(1);

      // Initially password should be obscured
      TextField textField = tester.widget(passwordField);
      expect(textField.obscureText, true);

      // Act - Tap visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Assert - Password should now be visible
      textField = tester.widget(passwordField);
      expect(textField.obscureText, false);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should navigate to register screen when tapped',
        (WidgetTester tester) async {
      // Arrange
      await TestHelpers.pumpAndSettleWidget(
        tester,
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/register': (context) => const Scaffold(
                    body: Center(child: Text('Register Screen')),
                  ),
            },
          ),
        ),
      );

      // Act - Tap on "Sign Up For Free" link
      final signUpLink = find.text('Sign Up For Free');
      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      // Assert - Should navigate to register screen
      expect(find.text('Register Screen'), findsOneWidget);
    });

    testWidgets('should navigate to forgot password screen',
        (WidgetTester tester) async {
      // Arrange
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

      // Act - Tap on "Recovery Password" link
      final recoveryLink = find.text('Recovery Password');
      await tester.tap(recoveryLink);
      await tester.pumpAndSettle();

      // Assert - Should navigate to forgot password screen
      expect(find.text('Forgot Password Screen'), findsOneWidget);
    });

    testWidgets('should accept valid email and password input',
        (WidgetTester tester) async {
      // Arrange
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Act - Enter valid credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Assert - Fields should contain the entered text
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
