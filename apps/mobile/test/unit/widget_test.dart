/// Basic Widget Tests
///
/// Example tests demonstrating Flutter widget testing patterns.
/// These serve as templates for understanding test structure.
/// Covers:
/// - Basic widget display verification
/// - Button tap interaction testing
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Verifies a basic widget renders text correctly.
  testWidgets('Basic widget test example', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Flutter CEA System'))),
      ),
    );

    expect(find.text('Flutter CEA System'), findsOneWidget);
  });

  /// Demonstrates button tap testing pattern.
  testWidgets('Button tap test example', (WidgetTester tester) async {
    int counter = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => counter++,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      ),
    );

    final button = find.text('Tap Me');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pump();

    expect(counter, 1);
  });
}
