/// Forgot Password Screen Widget Tests
///
/// Tests the ForgotPasswordScreen widget for proper rendering and form validation.
/// Covers:
/// - AppBar title display
/// - Form elements (email input, buttons)
/// - Header icon and text
/// - Button state based on email validity
/// - Info tip display
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/auth/forgot_password_screen.dart';

void main() {
  group('Forgot Password Screen Widget Tests', () {
    /// Verifies Forgot Password title is displayed in AppBar.
    testWidgets('should display Forgot Password title in AppBar', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Forgot Password'), findsOneWidget);
    });

    /// Verifies Indonesian header text is displayed.
    testWidgets('should display Lupa Password header text', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Lupa Password?'), findsOneWidget);
    });

    /// Verifies email input field with hint text is displayed.
    testWidgets('should display email input field', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('contoh: kamu@domain.com'), findsOneWidget);
    });

    /// Verifies reset link button is displayed.
    testWidgets('should display Kirim Link Reset button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Kirim Link Reset'), findsOneWidget);
    });

    /// Verifies back to login button is displayed.
    testWidgets('should display Kembali ke Login button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Kembali ke Login'), findsOneWidget);
    });

    /// Verifies lock icon is displayed in header.
    testWidgets('should display lock icon in header', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    /// Verifies email icon is displayed in form field.
    testWidgets('should display email icon in form field', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    /// Verifies tip text is displayed.
    testWidgets('should display tip text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('Tip:'), findsOneWidget);
    });

    /// Verifies link validity info text is displayed.
    testWidgets('should display info text about link validity', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Link berlaku 24 jam'), findsOneWidget);
    });

    /// Tests that submit button is disabled when email is empty.
    testWidgets('should have disabled button when email is empty', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Kirim Link Reset'),
      );

      expect(button.onPressed, isNull);
    });

    /// Tests that submit button is enabled when valid email is entered.
    testWidgets('should enable button when valid email is entered', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Kirim Link Reset'),
      );

      expect(button.onPressed, isNotNull);
    });

    /// Verifies email field accepts user input.
    testWidgets('should accept valid email input', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pump();

      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'user@domain.com');
      await tester.pump();

      expect(find.text('user@domain.com'), findsOneWidget);
    });
  });
}
