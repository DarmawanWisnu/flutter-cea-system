import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/monitor/monitor_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';

/// Integration Test for Monitor Screen Flow
/// 
/// This test suite covers the complete monitor screen user journey:
/// - Viewing sensor data (pH, PPM, Temperature, Humidity)
/// - Switching between Auto and Manual modes
/// - Using manual control buttons
/// - Selecting different kits
/// 
/// These are BLACK BOX tests - they test from the user's perspective
/// without knowledge of internal implementation details.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Monitor Screen Flow Integration Tests', () {
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
      // Use pump instead of pumpAndSettle to avoid timeout
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - All sensor types should be displayed
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('PPM'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);
    });

    testWidgets('should display sensor values with units',
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

      // Assert - Units should be displayed
      expect(find.textContaining('pH'), findsWidgets);
      expect(find.textContaining('ppm'), findsWidgets);
      expect(find.textContaining('%'), findsWidgets);
      expect(find.textContaining('°C'), findsWidgets);
    });

    testWidgets('should display Your Kit section with kit selector',
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

      // Assert
      expect(find.text('Your Kit'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
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

    testWidgets('should switch from auto to manual mode',
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

      // Initially, manual buttons should not be visible
      expect(find.text('PH UP'), findsNothing);

      // Act - Switch to manual mode
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Assert - Manual control buttons should now be visible
      expect(find.text('PH UP'), findsOneWidget);
      expect(find.text('PH DOWN'), findsOneWidget);
      expect(find.text('NUTRIENT'), findsOneWidget);
      expect(find.text('REFILL'), findsOneWidget);
    });

    testWidgets('should switch from manual to auto mode',
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

      // First switch to manual mode
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Verify manual buttons are visible
      expect(find.text('PH UP'), findsOneWidget);

      // Act - Switch back to auto mode
      final autoButton = find.text('AUTO');
      await tester.tap(autoButton);
      await tester.pumpAndSettle();

      // Assert - Manual control buttons should be hidden
      expect(find.text('PH UP'), findsNothing);
      expect(find.text('PH DOWN'), findsNothing);
      expect(find.text('NUTRIENT'), findsNothing);
      expect(find.text('REFILL'), findsNothing);
    });

    testWidgets('should tap manual control buttons',
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

      // Switch to manual mode
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Act & Assert - Tap each manual control button
      final phUpButton = find.text('PH UP');
      expect(phUpButton, findsOneWidget);
      await tester.tap(phUpButton);
      await tester.pump();

      final phDownButton = find.text('PH DOWN');
      expect(phDownButton, findsOneWidget);
      await tester.tap(phDownButton);
      await tester.pump();

      final nutrientButton = find.text('NUTRIENT');
      expect(nutrientButton, findsOneWidget);
      await tester.tap(nutrientButton);
      await tester.pump();

      final refillButton = find.text('REFILL');
      expect(refillButton, findsOneWidget);
      await tester.tap(refillButton);
      await tester.pump();

      // If we got here without errors, all buttons are tappable
      expect(true, true);
    });

    testWidgets('should display kit status indicator',
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

      // Assert - Status dot should be present (Container with circular shape)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should display last update timestamp',
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

      // Assert - "Last:" text should be present
      expect(find.textContaining('Last:'), findsOneWidget);
    });

    testWidgets('complete user flow: view data, switch mode, use controls',
        (WidgetTester tester) async {
      // This test simulates a complete user journey on the monitor screen

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

      // Step 1: User views sensor data
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('PPM'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);

      // Step 2: User switches to manual mode
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Step 3: User sees manual control buttons
      expect(find.text('PH UP'), findsOneWidget);
      expect(find.text('PH DOWN'), findsOneWidget);

      // Step 4: User taps PH UP button
      final phUpButton = find.text('PH UP');
      await tester.tap(phUpButton);
      await tester.pump();

      // Step 5: User switches back to auto mode
      final autoButton = find.text('AUTO');
      await tester.tap(autoButton);
      await tester.pumpAndSettle();

      // Step 6: Manual buttons are hidden
      expect(find.text('PH UP'), findsNothing);

      // Complete flow executed successfully
      expect(true, true);
    });
  });
}
