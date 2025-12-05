import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fountaine/features/home/home_screen.dart';
import 'package:fountaine/features/add_kit/add_kit_screen.dart';
import 'package:fountaine/features/settings/settings_screen.dart';
import 'package:fountaine/features/history/history_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

/// This test suite covers navigation flows from the home screen.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Flow Integration Tests', () {
    testWidgets('should display home screen with all features', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.pumpAndSettle();

      // Verify all feature cards are displayed
      expect(find.text('Monitoring'), findsOneWidget);
      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('Add Kit'), findsOneWidget);
      expect(find.text('Setting'), findsOneWidget);
    });

    testWidgets('should navigate to Add Kit screen when Add Kit tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/add_kit': (context) => const AddKitScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Add Kit card
      await tester.tap(find.text('Add Kit'));
      await tester.pumpAndSettle();

      // Should navigate to add kit screen
      expect(find.text('Add Kit'), findsWidgets);
      expect(find.text('Kit Name'), findsOneWidget);
    });

    testWidgets('should navigate to Settings screen when Setting tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Setting card
      await tester.tap(find.text('Setting'));
      await tester.pumpAndSettle();

      // Should navigate to settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account Setting'), findsOneWidget);
    });

    testWidgets('should navigate to History screen when Notification tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
            currentKitIdProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/history': (context) => const HistoryScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Notification card
      await tester.tap(find.text('Notification'));
      await tester.pumpAndSettle();

      // Should navigate to history screen
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('should navigate via bottom nav bar icons', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap person icon in bottom nav (should go to settings)
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Should navigate to settings screen
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should navigate to Add Kit when QR button tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/add_kit': (context) => const AddKitScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap QR code button in center of bottom nav
      await tester.tap(find.byIcon(Icons.qr_code_2));
      await tester.pumpAndSettle();

      // Should navigate to add kit screen
      expect(find.text('Add Kit'), findsWidgets);
    });
  });
}
