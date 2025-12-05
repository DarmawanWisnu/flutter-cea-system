import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/auth/forgot_password_screen.dart';

void main() {
  group('Forgot Password Screen Widget Tests', () {
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
      expect(
        find.textContaining('Tip:'),
        findsOneWidget,
      );
    });

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

      expect(
        find.textContaining('Link berlaku 24 jam'),
        findsOneWidget,
      );
    });

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

      // Find the ElevatedButton
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Kirim Link Reset'),
      );

      // Button should be disabled when email is empty
      expect(button.onPressed, isNull);
    });

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

      // Enter valid email
      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Find the ElevatedButton
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Kirim Link Reset'),
      );

      // Button should be enabled when valid email is entered
      expect(button.onPressed, isNotNull);
    });

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

      // Enter valid email
      final emailField = find.byType(TextFormField);
      await tester.enterText(emailField, 'user@domain.com');
      await tester.pump();

      expect(find.text('user@domain.com'), findsOneWidget);
    });
  });
}
