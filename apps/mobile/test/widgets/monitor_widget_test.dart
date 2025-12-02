import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/monitor/monitor_screen.dart';
import 'package:fountaine/providers/provider/monitor_provider.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import 'package:fountaine/domain/telemetry.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Monitor Screen Widget Tests', () {
    testWidgets('should display monitor screen title',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock the API kits list provider
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Monitor'), findsOneWidget);
    });

    testWidgets('should display all sensor gauges',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - All sensor types should be displayed
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('PPM'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);
    });

    testWidgets('should display Your Kit section',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Your Kit'), findsOneWidget);
    });

    testWidgets('should display Mode & Control section',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mode & Control'), findsOneWidget);
      expect(find.text('AUTO'), findsOneWidget);
      expect(find.text('MANUAL'), findsOneWidget);
    });

    testWidgets('should display manual control buttons when in manual mode',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Switch to manual mode
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Assert - Manual control buttons should be visible
      expect(find.text('PH UP'), findsOneWidget);
      expect(find.text('PH DOWN'), findsOneWidget);
      expect(find.text('NUTRIENT'), findsOneWidget);
      expect(find.text('REFILL'), findsOneWidget);
    });

    testWidgets('should hide manual control buttons when in auto mode',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First switch to manual to show buttons
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Verify buttons are visible
      expect(find.text('PH UP'), findsOneWidget);

      // Act - Switch to auto mode
      final autoButton = find.text('AUTO');
      await tester.tap(autoButton);
      await tester.pumpAndSettle();

      // Assert - Manual control buttons should be hidden
      expect(find.text('PH UP'), findsNothing);
      expect(find.text('PH DOWN'), findsNothing);
      expect(find.text('NUTRIENT'), findsNothing);
      expect(find.text('REFILL'), findsNothing);
    });

    testWidgets('should toggle between auto and manual modes',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert - Toggle to manual
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();
      expect(find.text('PH UP'), findsOneWidget);

      // Act & Assert - Toggle back to auto
      final autoButton = find.text('AUTO');
      await tester.tap(autoButton);
      await tester.pumpAndSettle();
      expect(find.text('PH UP'), findsNothing);
    });

    testWidgets('should display kit dropdown',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiKitsListProvider.overrideWith((ref) async {
              return [
                {'id': 'test-kit-001', 'name': 'Test Kit 1'},
                {'id': 'test-kit-002', 'name': 'Test Kit 2'},
              ];
            }),
          ],
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Dropdown should be present
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });
  });
}
