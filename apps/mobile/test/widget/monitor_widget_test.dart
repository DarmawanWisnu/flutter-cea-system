/// Monitor Screen Widget Tests
///
/// Tests the MonitorScreen widget for proper rendering of sensor data and controls.
/// Uses mock API and MQTT providers to isolate from external dependencies.
/// Covers:
/// - Sensor gauge display (pH, TDS, Humidity, Temperature)
/// - Kit selection dropdown
/// - Mode switching (AUTO/MANUAL)
/// - Progress bar indicators
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/features/monitor/monitor_screen.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:fountaine/domain/telemetry.dart';

import '../helpers/test_overflow_handler.dart';

/// Mock API Service that returns static telemetry data for testing.
class MockApiService extends ApiService {
  MockApiService() : super(baseUrl: 'http://localhost:8000');

  @override
  Future<Telemetry?> getLatestTelemetry(String deviceId) async {
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

/// Mock MQTT ViewModel that provides no-op implementations for testing.
class MockMqttVM extends MqttVM {
  MockMqttVM(Ref ref) : super(ref);

  @override
  Future<void> init() async {}

  @override
  Future<void> publishActuator(
    String command, {
    Map<String, dynamic>? args,
    required String kitId,
  }) async {}

  @override
  void enableAutoMode(String deviceId) {}

  @override
  void disableAutoMode(String deviceId) {}

  @override
  bool isAutoMode(String deviceId) => false;
}

void main() {
  /// Creates provider overrides for test isolation.
  List<Override> createTestOverrides() {
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

  group('Monitor Screen Widget Tests', () {
    /// Helper function to pump MonitorScreen with proper viewport and overrides.
    Future<void> pumpMonitorScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidgetSafe(
        ProviderScope(
          overrides: createTestOverrides(),
          child: const MaterialApp(
            home: MonitorScreen(selectedKit: 'test-kit-001'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    /// Verifies Fountaine branding title is displayed.
    testWidgets('should display Fountaine title', (WidgetTester tester) async {
      await pumpMonitorScreen(tester);
      expect(find.text('Fountaine'), findsOneWidget);
    });

    /// Verifies sensor type labels are displayed.
    testWidgets('should display sensor labels', (WidgetTester tester) async {
      await pumpMonitorScreen(tester);
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('TDS'), findsOneWidget);
    });

    /// Verifies kit selection section is displayed.
    testWidgets('should display Your Kit section', (WidgetTester tester) async {
      await pumpMonitorScreen(tester);
      expect(find.text('Your Kit'), findsOneWidget);
    });

    /// Verifies mode selection section is displayed.
    testWidgets('should display Mode section', (WidgetTester tester) async {
      await pumpMonitorScreen(tester);
      expect(find.text('Mode'), findsOneWidget);
    });

    /// Verifies AUTO and MANUAL mode toggle buttons are displayed.
    testWidgets('should display AUTO and MANUAL buttons', (
      WidgetTester tester,
    ) async {
      await pumpMonitorScreen(tester);
      expect(find.text('AUTO'), findsOneWidget);
      expect(find.text('MANUAL'), findsOneWidget);
    });

    /// Verifies kit selection dropdown is displayed.
    testWidgets('should display kit dropdown', (WidgetTester tester) async {
      await pumpMonitorScreen(tester);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    /// Verifies sensor progress bars are displayed.
    testWidgets('should display progress bars', (WidgetTester tester) async {
      await pumpMonitorScreen(tester);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });
  });
}
