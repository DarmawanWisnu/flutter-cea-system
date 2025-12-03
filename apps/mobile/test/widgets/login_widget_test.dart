import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fountaine/features/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Login Screen Widget Tests', () {
    testWidgets('should display all login screen elements', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Assert
      expect(find.text('Hello Again!'), findsOneWidget);
      expect(find.text("Welcome Back You've Been Missed!"), findsOneWidget);
    });

    testWidgets('should navigate to forgot password screen', (
      WidgetTester tester,
    ) async {
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

    testWidgets('should accept valid email and password input', (
      WidgetTester tester,
    ) async {
      // Arrange
      await TestHelpers.pumpAndSettleWidget(
        tester,
        TestHelpers.wrapWithProviders(const LoginScreen()),
      );

      // Act - Enter valid credentials
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Assert - Fields should contain the entered text
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
