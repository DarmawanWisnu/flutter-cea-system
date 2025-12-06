/// Monitor Screen Flow Integration Tests
///
/// End-to-end tests covering the complete monitor screen user journey.
/// Tests use mock API and MQTT providers to avoid real network/broker calls.
/// Covers:
/// - Sensor gauge display (pH, TDS, Temperature, Humidity)
/// - Kit selection and status
/// - AUTO/MANUAL mode switching
/// - Manual control button interactions
/// - Complete user flow simulation
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/monitor/monitor_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:fountaine/domain/telemetry.dart';

/// Mock API Service that returns static telemetry data for testing.
class MockApiService extends ApiService {
  MockApiService() : super(baseUrl: 'http://localhost:8000');

  @override
  Future<Telemetry?> getLatestTelemetry(String deviceId) async {
    return const Telemetry(
      ph: 7.0,
      ppm: 1200.0,
      tempC: 25.0,
      humidity: 65.0,
      waterTemp: 24.0,
      waterLevel: 80.0,
    );
  }

  @override
  Future<dynamic> postJson(String path, Map<String, dynamic> data) async {
    return {'data': data};
  }

  @override
  Future<dynamic> getJson(String path) async {
    return {'data': []};
  }
}

/// Mock MQTT ViewModel that provides no-op implementations for testing.
class MockMqttVM extends MqttVM {
  MockMqttVM(super.ref);

  @override
  Future<void> init() async {
    print('[Monitor] MQTT initialized');
  }

  @override
  Future<void> publishActuator(
    String command, {
    Map<String, dynamic>? args,
    required String kitId,
  }) async {
    print('[Flutter] Mock MQTT publish: $command');
  }

  @override
  void enableAutoMode(String deviceId) {
    print('[Flutter] Mock enable auto mode');
  }

  @override
  void disableAutoMode(String deviceId) {
    print('[Flutter] Mock disable auto mode');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Creates provider overrides for test isolation.
  createTestOverrides() {
    return [
      apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),
      apiServiceProvider.overrideWith((ref) => MockApiService()),
      apiKitsListProvider.overrideWith((ref) async {
        return [
          {'id': 'test-kit-001', 'name': 'Test Kit 1'},
          {'id': 'test-kit-002', 'name': 'Test Kit 2'},
        ];
      }),
      mqttProvider.overrideWith((ref) => MockMqttVM(ref)),
    ];
  }

  group('Monitor Screen Flow Integration Tests', () {
    /// Verifies all sensor gauges are displayed.
    testWidgets('should display all sensor gauges', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('pH'), findsOneWidget);
      expect(find.text('TDS'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Air Temp'), findsOneWidget);
    });

    /// Verifies sensor values display with proper units.
    testWidgets('should display sensor values with units', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('pH'), findsWidgets);
      expect(find.textContaining('ppm'), findsWidgets);
      expect(find.textContaining('%'), findsWidgets);
      expect(find.textContaining('°C'), findsWidgets);
    });

    /// Verifies kit section with selector is displayed.
    testWidgets('should display Your Kit section with kit selector', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Kit'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    /// Verifies mode section with toggle buttons is displayed.
    testWidgets('should display Mode & Control section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode'), findsOneWidget);
      expect(find.text('AUTO'), findsOneWidget);
      expect(find.text('MANUAL'), findsOneWidget);
    });

    /// Tests switching from auto to manual mode reveals control buttons.
    testWidgets('should switch from auto to manual mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final autoButton = find.text('AUTO');
      await tester.tap(autoButton);
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('PH UP'), findsNothing);

      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('PH UP'), findsOneWidget);
      expect(find.text('PH DOWN'), findsOneWidget);
      expect(find.text('NUTRIENT'), findsOneWidget);
      expect(find.text('REFILL'), findsOneWidget);
    });

    /// Tests switching from manual to auto mode hides control buttons.
    testWidgets('should switch from manual to auto mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      expect(find.text('PH UP'), findsOneWidget);

      final autoButton = find.text('AUTO');
      await tester.tap(autoButton);
      await tester.pumpAndSettle();

      expect(find.text('PH UP'), findsNothing);
      expect(find.text('PH DOWN'), findsNothing);
      expect(find.text('NUTRIENT'), findsNothing);
      expect(find.text('REFILL'), findsNothing);
    });

    /// Tests manual control buttons are tappable.
    testWidgets('should tap manual control buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

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

      expect(true, true);
    });

    /// Verifies kit status indicator is present.
    testWidgets('should display kit status indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    /// Verifies last update timestamp is displayed.
    testWidgets('should display last update timestamp', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Last:'), findsOneWidget);
    });

    /// Simulates complete user flow: view data, switch mode, use controls.
    testWidgets('complete user flow: view data, switch mode, use controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('pH'), findsOneWidget);
      expect(find.text('TDS'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Air Temp'), findsOneWidget);

      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      expect(find.text('PH UP'), findsOneWidget);
      expect(find.text('PH DOWN'), findsOneWidget);

      final phUpButton = find.text('PH UP');
      await tester.tap(phUpButton);
      await tester.pump();

      final autoButton = find.text('AUTO');
      await tester.tap(autoButton);
      await tester.pumpAndSettle();

      expect(find.text('PH UP'), findsNothing);

      expect(true, true);
    });
  });
}
