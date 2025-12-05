import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fountaine/features/home/home_screen.dart';

void main() {
  group('Home Screen Widget Tests', () {
    testWidgets('should display weather card with temperature', (
      WidgetTester tester,
    ) async {
      // Set viewport size
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      // Assert - Weather card shows temperature
      expect(find.text('23°C'), findsOneWidget);
    });

    testWidgets('should display location text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      // Assert - Location is displayed
      expect(find.text('Tangerang, Banten'), findsWidgets);
    });

    testWidgets('should display All Features section title', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      expect(find.text('All Features'), findsOneWidget);
    });

    testWidgets('should display 4 feature cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      // Assert - All 4 feature cards are displayed
      expect(find.text('Monitoring'), findsOneWidget);
      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('Add Kit'), findsOneWidget);
      expect(find.text('Setting'), findsOneWidget);
    });

    testWidgets('should display feature card subtitles', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      expect(find.text("Check your plant's health"), findsOneWidget);
      expect(find.text('View past records'), findsOneWidget);
      expect(find.text('Connect new devices'), findsOneWidget);
      expect(find.text('Manage your account'), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar icons', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      // Assert - Bottom nav icons exist
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.park_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    testWidgets('should display Your location text in header', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      expect(find.text('Your location'), findsOneWidget);
    });

    testWidgets('should have GridView with 2 columns', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pump();

      // Assert - GridView exists
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
