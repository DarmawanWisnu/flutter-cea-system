/// Notification Flow Integration Tests
///
/// End-to-end tests covering notification screen interactions.
/// Tests use mock notification provider to control test state.
/// Covers:
/// - Notification screen display with filter chips
/// - Filter switching between All, Info, Warning, Urgent
/// - More options menu interactions
/// - Mark all read and delete all functionality
/// - Empty state handling
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/notifications/notification_screen.dart';
import 'package:fountaine/providers/provider/notification_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Flow Integration Tests', () {
    /// Verifies notification screen displays with filter chips.
    testWidgets('should display notification screen with filter chips', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    });

    /// Tests filter switching when Warning chip is tapped.
    testWidgets('should switch filter when chip tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Warning'));
      await tester.pumpAndSettle();

      expect(find.text('Notification'), findsOneWidget);
    });

    /// Tests switching to Urgent filter.
    testWidgets('should switch to Urgent filter', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Urgent'));
      await tester.pumpAndSettle();

      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    });

    /// Tests switching to All filter after selecting another.
    testWidgets('should switch to All filter', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Warning'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Notification'), findsOneWidget);
    });

    /// Tests opening more options menu.
    testWidgets('should open more options menu', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.text('Delete all'), findsOneWidget);
    });

    /// Tests Mark all read menu action.
    testWidgets('should mark all as read from menu', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(find.text('All marked as read'), findsOneWidget);
    });

    /// Tests delete all confirmation dialog display.
    testWidgets('should show delete all confirmation dialog', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete all'));
      await tester.pumpAndSettle();

      expect(find.text('Delete all notifications?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    /// Tests canceling delete all action.
    testWidgets('should cancel delete all when Cancel tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete all'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete all notifications?'), findsNothing);
      expect(find.text('Notification'), findsOneWidget);
    });

    /// Verifies empty state with Show All button.
    testWidgets('should display empty state and Show All button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notifications (for this filter)'), findsOneWidget);
      expect(find.text('Show All'), findsOneWidget);
    });

    /// Tests Show All button functionality.
    testWidgets('should tap Show All button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show All'));
      await tester.pumpAndSettle();

      expect(find.text('Notification'), findsOneWidget);
    });
  });
}
