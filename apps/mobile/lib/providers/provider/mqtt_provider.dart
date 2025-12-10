import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/services/mqtt_service.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/domain/device_status.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';

final mqttProvider = ChangeNotifierProvider<MqttVM>((ref) {
  ref.keepAlive();
  final vm = MqttVM(ref);

  ref.onDispose(vm.disposeSafely);

  return vm;
});

class MqttVM extends ChangeNotifier {
  final MqttService _svc = MqttService();
  final Ref _ref;

  MqttConnState _state = MqttConnState.disconnected;
  MqttConnState get state => _state;

  // Local cache of auto mode devices (synced with backend)
  final Set<String> _autoModeDevices = {};
  final Map<String, Telemetry> telemetryMap = {};
  final Map<String, DeviceStatus> statusMap = {};

  StreamSubscription<MqttConnState>? _connSub;
  StreamSubscription<MapEntry<String, Telemetry>>? _teleSub;
  StreamSubscription<MapEntry<String, DeviceStatus>>? _statSub;

  bool _initialized = false;

  MqttVM(this._ref);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _connSub = _svc.connectionState$.listen((s) {
      _state = s;
      notifyListeners();
    });

    _teleSub = _svc.telemetry$.listen((entry) {
      final deviceId = entry.key;
      final newTelemetry = entry.value;
      
      // Merge with existing telemetry (partial payload support)
      if (telemetryMap.containsKey(deviceId)) {
        final existing = telemetryMap[deviceId]!;
        telemetryMap[deviceId] = existing.copyWith(
          ppm: newTelemetry.ppm != 0.0 ? newTelemetry.ppm : null,
          ph: newTelemetry.ph != 0.0 ? newTelemetry.ph : null,
          tempC: newTelemetry.tempC != 0.0 ? newTelemetry.tempC : null,
          humidity: newTelemetry.humidity != 0.0 ? newTelemetry.humidity : null,
          waterTemp: newTelemetry.waterTemp != 0.0 ? newTelemetry.waterTemp : null,
          waterLevel: newTelemetry.waterLevel != 0.0 ? newTelemetry.waterLevel : null,
        );
      } else {
        telemetryMap[deviceId] = newTelemetry;
      }

      notifyListeners();
    });

    _statSub = _svc.status$.listen((entry) {
      statusMap[entry.key] = entry.value;
      notifyListeners();
    });

    await _svc.connect();
  }

  Future<void> publishActuator(
    String command, {
    Map<String, dynamic>? args,
    required String kitId,
  }) async {
    if (!(_state == MqttConnState.connected)) return;
    await _svc.publishControl(command, args ?? {}, kitId);
  }

  /// Get current user ID from Firebase Auth
  String? _getUserId() {
    final user = _ref.read(authProvider);
    return user?.uid;
  }

  /// Enable auto mode for a device (saves to backend)
  Future<void> enableAutoMode(String deviceId) async {
    final userId = _getUserId();
    if (userId == null) {
      print("[MQTT] Cannot enable auto mode - user not logged in");
      return;
    }

    // Update local state immediately for UI
    _autoModeDevices.add(deviceId);
    notifyListeners();

    // Save to backend (backend subscriber will handle the timer)
    try {
      final api = _ref.read(apiServiceProvider);
      final success = await api.setDeviceMode(
        userId: userId,
        deviceId: deviceId,
        autoMode: true,
      );
      
      if (success) {
        print("[MQTT] Auto mode ENABLED for $deviceId (saved to backend)");
      } else {
        print("[MQTT] Failed to save auto mode to backend");
        // Revert local state on failure
        _autoModeDevices.remove(deviceId);
        notifyListeners();
      }
    } catch (e) {
      print("[MQTT] Error enabling auto mode: $e");
      _autoModeDevices.remove(deviceId);
      notifyListeners();
    }
  }

  /// Disable auto mode for a device (saves to backend)
  Future<void> disableAutoMode(String deviceId) async {
    final userId = _getUserId();
    if (userId == null) {
      print("[MQTT] Cannot disable auto mode - user not logged in");
      return;
    }

    // Update local state immediately for UI
    _autoModeDevices.remove(deviceId);
    notifyListeners();

    // Save to backend
    try {
      final api = _ref.read(apiServiceProvider);
      final success = await api.setDeviceMode(
        userId: userId,
        deviceId: deviceId,
        autoMode: false,
      );
      
      if (success) {
        print("[MQTT] Auto mode DISABLED for $deviceId (saved to backend)");
      } else {
        print("[MQTT] Failed to save manual mode to backend");
      }
    } catch (e) {
      print("[MQTT] Error disabling auto mode: $e");
    }
  }

  /// Check if a device is in auto mode (from local cache)
  bool isAutoMode(String deviceId) {
    return _autoModeDevices.contains(deviceId);
  }

  /// Load auto mode state from backend for a specific device
  Future<bool> loadAutoModeFromBackend(String deviceId) async {
    final userId = _getUserId();
    if (userId == null) return false;

    try {
      final api = _ref.read(apiServiceProvider);
      final autoMode = await api.getDeviceMode(
        userId: userId,
        deviceId: deviceId,
      );
      
      // Update local cache
      if (autoMode) {
        _autoModeDevices.add(deviceId);
      } else {
        _autoModeDevices.remove(deviceId);
      }
      notifyListeners();
      
      print("[MQTT] Loaded auto mode from backend: $deviceId = $autoMode");
      return autoMode;
    } catch (e) {
      print("[MQTT] Error loading auto mode from backend: $e");
      return false;
    }
  }

  Future<void> disposeSafely() async {
    _autoModeDevices.clear();
    
    await _connSub?.cancel();
    await _teleSub?.cancel();
    await _statSub?.cancel();

    await _svc.disconnect();

    telemetryMap.clear();
    statusMap.clear();

    _initialized = false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
