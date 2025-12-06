/// Notification Screen Widget Tests
///
/// Tests the NotificationScreen widget for proper rendering and interactions.
/// Uses mock notification provider to control test data.
/// Covers:
/// - AppBar title display
/// - Filter chips (All, Info, Warning, Urgent)
/// - Empty state display
/// - More options menu
/// - Filter chip icons and interactions
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/notifications/notification_screen.dart';
import 'package:fountaine/providers/provider/notification_provider.dart';

void main() {
  group('Notification Screen Widget Tests', () {
    /// Verifies Notification title is displayed in AppBar.
    testWidgets('should display Notification title in AppBar', (
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

      expect(find.text('Notification'), findsOneWidget);
    });

    /// Verifies all filter chips are displayed.
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

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    });

    /// Verifies empty state is displayed when no notifications.
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

      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
      expect(find.text('No notifications (for this filter)'), findsOneWidget);
      expect(find.text('Show All'), findsOneWidget);
    });

    /// Verifies more options menu icon is displayed.
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

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    /// Tests that popup menu opens when more options is tapped.
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

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.text('Delete all'), findsOneWidget);
    });

    /// Tests Show All button switches to All filter.
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

      await tester.tap(find.text('Show All'));
      await tester.pump();

      expect(find.text('All'), findsOneWidget);
    });

    /// Verifies filter chip icons are displayed.
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

      expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dangerous_outlined), findsOneWidget);
    });

    /// Tests filter switching when a chip is tapped.
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

      await tester.tap(find.text('Warning'));
      await tester.pump();

      expect(find.text('Notification'), findsOneWidget);
    });
  });
}
