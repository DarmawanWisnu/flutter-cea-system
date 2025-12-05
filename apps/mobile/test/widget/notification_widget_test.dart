import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/notifications/notification_screen.dart';
import 'package:fountaine/providers/provider/notification_provider.dart';

void main() {
  group('Notification Screen Widget Tests', () {
    testWidgets('should display Notification title in AppBar', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override with empty list state
            notificationListProvider.overrideWith((ref) {
              ref.keepAlive();
              return NotificationListNotifier(ref);
            }),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Notification'), findsOneWidget);
    });

    testWidgets('should display filter chips', (WidgetTester tester) async {
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
      await tester.pump();

      // All filter chips should be visible
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    });

    testWidgets('should display empty state when no notifications', (
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
      await tester.pump();

      // Empty state elements
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
      expect(find.text('No notifications (for this filter)'), findsOneWidget);
      expect(find.text('Show All'), findsOneWidget);
    });

    testWidgets('should display more options menu', (
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
      await tester.pump();

      // More options icon
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should open popup menu when more options tapped', (
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
      await tester.pump();

      // Tap more options
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Menu items should appear
      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.text('Delete all'), findsOneWidget);
    });

    testWidgets('should switch to All filter when Show All tapped', (
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
      await tester.pump();

      // Tap Show All button
      await tester.tap(find.text('Show All'));
      await tester.pump();

      // Should still show the filter chips
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('should display filter chip icons', (
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
      await tester.pump();

      // Filter chip icons
      expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dangerous_outlined), findsOneWidget);
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
      await tester.pump();

      // Tap Warning filter
      await tester.tap(find.text('Warning'));
      await tester.pump();

      // Should still show the notification screen
      expect(find.text('Notification'), findsOneWidget);
    });
  });
}
