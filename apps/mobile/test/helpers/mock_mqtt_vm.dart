import 'package:flutter/foundation.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';
import 'package:fountaine/services/mqtt_service.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/domain/device_status.dart';

class MockMqttVM extends ChangeNotifier implements MqttVM {
  @override
  MqttConnState get state => MqttConnState.connected;

  @override
  Future<void> init() async {
    // No-op for testing
  }

  @override
  final Map<String, Telemetry> telemetryMap = {};

  @override
  final Map<String, DeviceStatus> statusMap = {};

  @override
  Future<void> publishActuator(
    String command, {
    Map<String, dynamic>? args,
    required String kitId,
  }) async {
    // No-op for testing
  }

  @override
  void enableAutoMode(String deviceId) {
    // No-op
  }

  @override
  void disableAutoMode(String deviceId) {
    // No-op
  }

  @override
  Future<void> disposeSafely() async {
    // No-op
  }
}
