// Mock MQTT ViewModel for Testing
//
// Provides a mock implementation of MqttVM for widget and integration tests.
// This mock:
// - Maintains connected state
// - Provides empty telemetry and status maps
// - Provides no-op implementations for all MQTT operations
// - Can be used with Riverpod provider overrides

import 'package:flutter/foundation.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import 'package:fountaine/services/mqtt_service.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/domain/device_status.dart';

/// Mock MQTT ViewModel that simulates connected state with no-op operations.
class MockMqttVM extends ChangeNotifier implements MqttVM {
  @override
  MqttConnState get state => MqttConnState.connected;

  @override
  Future<void> init() async {}

  @override
  final Map<String, Telemetry> telemetryMap = {};

  @override
  final Map<String, DeviceStatus> statusMap = {};

  @override
  Future<void> publishActuator(
    String command, {
    Map<String, dynamic>? args,
    required String kitId,
  }) async {}

  @override
  Future<void> enableAutoMode(String deviceId) async {}

  @override
  Future<void> disableAutoMode(String deviceId) async {}

  @override
  bool isAutoMode(String deviceId) {
    return false;
  }

  @override
  Future<bool> loadAutoModeFromBackend(String deviceId) async {
    return false;
  }

  @override
  Future<void> disposeSafely() async {}
}
