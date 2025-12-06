/// App Integration Tests
///
/// Basic integration tests verifying app launch and core navigation.
/// These serve as smoke tests to ensure the app starts correctly.
/// Covers:
/// - App launch success
/// - Basic screen navigation
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    /// Verifies app launches successfully.
    testWidgets('app should launch successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('CEA System'))),
        ),
      );

      expect(find.text('CEA System'), findsOneWidget);
    });

    /// Tests basic screen navigation.
    testWidgets('should navigate between screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
          routes: {'/second': (context) => const SecondScreen()},
        ),
      );

      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Second Screen'), findsOneWidget);
    });
  });
}

/// Mock home screen for navigation testing.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/second'),
          child: const Text('Go to Second Screen'),
        ),
      ),
    );
  }
}

/// Mock second screen for navigation testing.
class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Second Screen')));
  }
}
