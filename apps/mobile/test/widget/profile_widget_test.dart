import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/profile/profile_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

void main() {
  // Create test overrides
  createTestOverrides() {
    return [
      apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
      apiKitsListProvider.overrideWith((ref) async {
        return [
          {'id': 'test-kit-001', 'name': 'Test Kit 1'},
        ];
      }),
    ];
  }




  group('Profile Screen Widget Tests', () {
    testWidgets('should display Profile title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should display back button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display user avatar icon', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('should display Edit Profile button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('should display Logout button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should display info tile labels', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Kit Name'), findsOneWidget);
      expect(find.text('Kit ID'), findsOneWidget);
    });

    testWidgets('should display info tile icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.view_in_ar_outlined), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2_outlined), findsOneWidget);
    });

    testWidgets('should display ACTIVE badge', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('should display edit icon on Edit Profile button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });
  });
}
