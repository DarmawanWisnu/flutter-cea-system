/// Add Kit Screen Widget Tests
///
/// Tests the AddKitScreen widget for proper rendering and form validation.
/// Covers:
/// - AppBar elements (back button, title)
/// - Form fields (Kit Name, Kit ID)
/// - Save Kit button
/// - Form validation errors
/// - Input acceptance
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/add_kit/add_kit_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

void main() {
  /// Creates API provider overrides for test isolation.
  createTestOverrides() {
    return [
      apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
    ];
  }

  group('Add Kit Screen Widget Tests', () {
    /// Verifies Add Kit title is displayed.
    testWidgets('should display Add Kit title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Add Kit'), findsOneWidget);
    });

    /// Verifies subtitle text is displayed.
    testWidgets('should display subtitle text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      expect(
        find.text('Add your hydroponic kit to start monitoring.'),
        findsOneWidget,
      );
    });

    /// Verifies Kit Name input field with hint is displayed.
    testWidgets('should display Kit Name input field', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Kit Name'), findsOneWidget);
      expect(
        find.text('e.g. Hydroponic Monitoring System'),
        findsOneWidget,
      );
    });

    /// Verifies Kit ID input field with hint is displayed.
    testWidgets('should display Kit ID input field', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Kit ID'), findsOneWidget);
      expect(find.text('e.g. SUF-UINJKT-HM-F2000'), findsOneWidget);
    });

    /// Verifies Save Kit button with icon is displayed.
    testWidgets('should display Save Kit button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Save Kit'), findsOneWidget);
      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
    });

    /// Verifies back button is displayed.
    testWidgets('should display back button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Tests validation error when Kit Name is empty.
    testWidgets('should validate empty Kit Name on submit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Save Kit'));
      await tester.pump();

      expect(find.text('Nama kit wajib diisi'), findsOneWidget);
    });

    /// Tests validation error when Kit ID is empty.
    testWidgets('should validate empty Kit ID on submit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Kit');

      await tester.tap(find.text('Save Kit'));
      await tester.pump();

      expect(find.text('ID Kit wajib diisi'), findsOneWidget);
    });

    /// Tests validation error when Kit ID is too short.
    testWidgets('should validate short Kit ID on submit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      final nameField = find.byType(TextFormField).first;
      final idField = find.byType(TextFormField).at(1);
      await tester.enterText(nameField, 'Test Kit');
      await tester.enterText(idField, 'AB');

      await tester.tap(find.text('Save Kit'));
      await tester.pump();

      expect(find.text('ID Kit terlalu pendek'), findsOneWidget);
    });

    /// Verifies form fields accept valid user input.
    testWidgets('should accept valid input', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: AddKitScreen()),
        ),
      );
      await tester.pump();

      final nameField = find.byType(TextFormField).first;
      final idField = find.byType(TextFormField).at(1);
      await tester.enterText(nameField, 'My Hydroponic Kit');
      await tester.enterText(idField, 'SUF-TEST-001');
      await tester.pump();

      expect(find.text('My Hydroponic Kit'), findsOneWidget);
      expect(find.text('SUF-TEST-001'), findsOneWidget);
    });
  });
}
