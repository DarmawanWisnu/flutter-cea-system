import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/notifications/notification_screen.dart';
import 'package:fountaine/providers/provider/notification_provider.dart';

/// This test suite covers notification interaction flows.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Flow Integration Tests', () {
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

      // Verify filter chips are displayed
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    });

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

      // Tap Warning filter chip
      await tester.tap(find.text('Warning'));
      await tester.pumpAndSettle();

      // Should still show the notification screen
      expect(find.text('Notification'), findsOneWidget);
    });

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

      // Tap Urgent filter chip
      await tester.tap(find.text('Urgent'));
      await tester.pumpAndSettle();

      // Screen should update
      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    });

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

      // First switch to Warning
      await tester.tap(find.text('Warning'));
      await tester.pumpAndSettle();

      // Then switch to All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Screen should update
      expect(find.text('Notification'), findsOneWidget);
    });

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

      // Tap more options button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Menu items should appear
      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.text('Delete all'), findsOneWidget);
    });

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

      // Tap more options button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap Mark all read
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('All marked as read'), findsOneWidget);
    });

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

      // Tap more options button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap Delete all
      await tester.tap(find.text('Delete all'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete all notifications?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

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

      // Tap more options button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap Delete all
      await tester.tap(find.text('Delete all'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should close, screen should still be visible
      expect(find.text('Delete all notifications?'), findsNothing);
      expect(find.text('Notification'), findsOneWidget);
    });

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

      // Empty state should be visible
      expect(find.text('No notifications (for this filter)'), findsOneWidget);
      expect(find.text('Show All'), findsOneWidget);
    });

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

      // Tap Show All button
      await tester.tap(find.text('Show All'));
      await tester.pumpAndSettle();

      // Should still show the notification screen
      expect(find.text('Notification'), findsOneWidget);
    });
  });
}
