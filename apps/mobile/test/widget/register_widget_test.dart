/// Register Screen Widget Tests
///
/// Tests the RegisterScreen widget for proper rendering and user interactions.
/// Covers:
/// - UI element display (title, form fields, buttons)
/// - Password visibility toggle functionality
/// - Form input validation
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/auth/register_screen.dart';

import '../helpers/test_overflow_handler.dart';

void main() {
  group('Register Screen Widget Tests', () {
    /// Helper function to pump the RegisterScreen with proper viewport sizing.
    Future<void> pumpRegisterScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        const ProviderScope(
          child: MaterialApp(home: RegisterScreen()),
        ),
      );
    }

    /// Verifies the main title is displayed.
    testWidgets('should display Create Account title', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);
      expect(find.text('Create Account'), findsOneWidget);
    });

    /// Verifies back navigation button is present.
    testWidgets('should display back button', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Verifies subtitle text is displayed.
    testWidgets('should display subtitle text', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      expect(find.text("Let's Create Account Together"), findsOneWidget);
    });

    /// Verifies name field label is displayed.
    testWidgets('should display Your Name field label', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);
      expect(find.text('Your Name'), findsOneWidget);
    });

    /// Verifies email field label is displayed.
    testWidgets('should display Email Address field label', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);
      expect(find.text('Email Address'), findsOneWidget);
    });

    /// Verifies password field label is displayed.
    testWidgets('should display Password field label', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);
      expect(find.text('Password'), findsOneWidget);
    });

    /// Verifies location field label is displayed.
    testWidgets('should display Location field label', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);
      expect(find.text('Location'), findsOneWidget);
    });

    /// Verifies sign up button is displayed.
    testWidgets('should display Sign Up button', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    /// Verifies Google sign-in button is displayed.
    testWidgets('should display Google Sign-in button', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);
      expect(find.text('Sign in with google'), findsOneWidget);
    });

    /// Verifies password visibility toggle icon is displayed.
    testWidgets('should display password visibility toggle', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    /// Tests that tapping visibility toggle changes the icon.
    testWidgets('should toggle password visibility when tapped', (
      WidgetTester tester,
    ) async {
      await pumpRegisterScreen(tester);

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    /// Verifies form fields accept user input.
    testWidgets('should accept valid input', (WidgetTester tester) async {
      await pumpRegisterScreen(tester);

      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.pump();

      expect(find.text('John Doe'), findsOneWidget);
    });
  });
}
