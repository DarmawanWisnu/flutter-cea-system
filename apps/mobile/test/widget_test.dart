import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test example', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Flutter CEA System'))),
      ),
    );

    // Verify the widget displays correctly
    expect(find.text('Flutter CEA System'), findsOneWidget);
  });

  testWidgets('Button tap test example', (WidgetTester tester) async {
    int counter = 0;

    // Build a widget with a button
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

    // Find and tap the button
    final button = find.text('Tap Me');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pump();

    // Verify the action occurred
    expect(counter, 1);
  });
}
