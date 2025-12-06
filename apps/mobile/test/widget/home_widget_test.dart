/// Home Screen Widget Tests
///
/// Tests the HomeScreen widget for proper rendering of main dashboard elements.
/// Covers:
/// - Weather card display
/// - Location information
/// - Feature grid display
/// - Bottom navigation bar
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fountaine/features/home/home_screen.dart';

import '../helpers/test_overflow_handler.dart';

void main() {
  group('Home Screen Widget Tests', () {
    /// Verifies weather card displays temperature.
    testWidgets('should display weather card with temperature', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.text('23°C'), findsOneWidget);
    });

    /// Verifies location text is displayed.
    testWidgets('should display location text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.text('Tangerang, Banten'), findsWidgets);
    });

    /// Verifies All Features section title is displayed.
    testWidgets('should display All Features section title', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.text('All Features'), findsOneWidget);
    });

    /// Verifies feature cards are displayed including Monitoring.
    testWidgets('should display feature cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.text('Monitoring'), findsOneWidget);
    });

    /// Verifies Notification feature card is displayed.
    testWidgets('should display feature card content', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.text('Notification'), findsOneWidget);
    });

    /// Verifies bottom navigation bar icons are displayed.
    testWidgets('should display bottom navigation bar', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    /// Verifies Your location header text is displayed.
    testWidgets('should display Your location text in header', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.text('Your location'), findsOneWidget);
    });

    /// Verifies GridView widget is used for feature layout.
    testWidgets('should have GridView', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(wrapForTest(const HomeScreen()));

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
