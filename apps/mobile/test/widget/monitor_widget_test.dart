import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/monitor/monitor_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:fountaine/domain/telemetry.dart';

// Mock API Service for testing
class MockApiService extends ApiService {
  MockApiService() : super(baseUrl: 'http://localhost:8000');

  @override
  Future<Telemetry?> getLatestTelemetry(String deviceId) async {
    // Return mock telemetry data
    return const Telemetry(
      id: 1,
      ingestTime: 1234567890,
      ppm: 800.0,
      ph: 6.5,
      tempC: 25.0,
      humidity: 60.0,
      waterTemp: 22.0,
      waterLevel: 2.0,
    );
  }

  @override
  Future<dynamic> postJson(String path, Map<String, dynamic> data) async {
    // Return mock response for actuator events
    return {
      'data': {
        'phUp': data['phUp'] ?? 0,
        'phDown': data['phDown'] ?? 0,
        'nutrientAdd': data['nutrientAdd'] ?? 0,
        'valueS': data['valueS'] ?? 0,
        'manual': data['manual'] ?? 0,
        'auto': data['auto'] ?? 0,
        'refill': data['refill'] ?? 0,
      },
    };
  }

  @override
  Future<dynamic> getJson(String path) async {
    if (path.contains('/kits')) {
      return [
        {'id': 'test-kit-001', 'name': 'Test Kit 1'},
      ];
    }
    return {};
  }
}

// Mock MQTT ViewModel for testing
class MockMqttVM extends MqttVM {
  MockMqttVM(Ref ref) : super(ref);

  @override
  Future<void> init() async {
    // Mock initialization - do nothing
  }

  @override
  Future<void> publishActuator(
    String command, {
    Map<String, dynamic>? args,
    required String kitId,
  }) async {
    // Mock publish - do nothing
  }

  @override
  void enableAutoMode(String deviceId) {
    // Mock enable - do nothing
  }

  @override
  void disableAutoMode(String deviceId) {
    // Mock disable - do nothing
  }

  @override
  bool isAutoMode(String deviceId) {
    // Mock - always return false
    return false;
  }
}

void main() {
  // Set up common overrides for all tests
  createTestOverrides() {
    return [
      // Override the base URL provider to avoid dotenv dependency
      apiBaseUrlProvider.overrideWith((ref) => 'http://localhost:8000'),

      // Override the API service provider with mock
      apiServiceProvider.overrideWith((ref) => MockApiService()),

      // Override the API kits list provider
      apiKitsListProvider.overrideWith((ref) async {
        return [
          {'id': 'test-kit-001', 'name': 'Test Kit 1'},
          {'id': 'test-kit-002', 'name': 'Test Kit 2'},
        ];
      }),

      // Override the MQTT provider with mock
      mqttProvider.overrideWith((ref) => MockMqttVM(ref)),
    ];
  }

  group('Monitor Screen Widget Tests', () {
    testWidgets('should display Fountaine title', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange & Act
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

      // Assert - Updated to match new title
      expect(find.text('Fountaine'), findsOneWidget);
    });

    testWidgets('should display all 6 sensor cards', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange & Act
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

      // Assert - All 6 sensor types should be displayed
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('TDS'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Air Temp'), findsOneWidget);
      expect(find.text('Water Temp'), findsOneWidget);
      expect(find.text('Water Level'), findsOneWidget);
    });

    testWidgets('should display Your Kit section', (WidgetTester tester) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange & Act
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

      // Assert
      expect(find.text('Your Kit'), findsOneWidget);
    });

    testWidgets('should display Mode section', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange & Act
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

      // Assert - Updated to match new text
      expect(find.text('Mode'), findsOneWidget);
      expect(find.text('AUTO'), findsOneWidget);
      expect(find.text('MANUAL'), findsOneWidget);
    });

    testWidgets('should display manual control buttons when in manual mode', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange
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

      // Act - Switch to manual mode
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Manual control buttons should be visible
      expect(find.text('PH UP'), findsOneWidget);
      expect(find.text('PH DOWN'), findsOneWidget);
      expect(find.text('NUTRIENT'), findsOneWidget);
      expect(find.text('REFILL'), findsOneWidget);
    });

    testWidgets('should hide manual control buttons when in auto mode', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange
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

      // Scroll to make buttons visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pump();

      // First switch to manual to show buttons
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify buttons are visible
      expect(find.text('PH UP'), findsOneWidget);

      // Act - Switch to auto mode
      final autoButton = find.text('AUTO');
      await tester.tap(autoButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Manual control buttons should be hidden
      expect(find.text('PH UP'), findsNothing);
      expect(find.text('PH DOWN'), findsNothing);
      expect(find.text('NUTRIENT'), findsNothing);
      expect(find.text('REFILL'), findsNothing);
    });

    testWidgets('should toggle between auto and manual modes', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange
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

      // Scroll to make buttons visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pump();

      // Act & Assert - Toggle to manual
      final manualButton = find.text('MANUAL');
      await tester.tap(manualButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('PH UP'), findsOneWidget);

      // Act & Assert - Toggle back to auto
      final autoButton = find.text('AUTO');
      await tester.tap(autoButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('PH UP'), findsNothing);
    });

    testWidgets('should display kit dropdown', (WidgetTester tester) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange & Act
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

      // Assert - Dropdown should be present
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should display progress bars for sensors', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to prevent overflow
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Arrange & Act
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

      // Assert - Should have 6 progress indicators (one per sensor)
      expect(find.byType(LinearProgressIndicator), findsNWidgets(6));
    });
  });
}
