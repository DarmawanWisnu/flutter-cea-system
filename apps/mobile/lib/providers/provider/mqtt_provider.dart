import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/services/mqtt_service.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/domain/device_status.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

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

  final Set<String> _autoModeDevices = {};
  final Map<String, Telemetry> telemetryMap = {};
  final Map<String, DeviceStatus> statusMap = {};

  StreamSubscription<MqttConnState>? _connSub;
  StreamSubscription<MapEntry<String, Telemetry>>? _teleSub;
  StreamSubscription<MapEntry<String, DeviceStatus>>? _statSub;
  
  // Auto mode timer - triggers every 30 seconds (synced with subscriber DB updates)
  Timer? _autoModeTimer;
  static const Duration _autoModeInterval = Duration(seconds: 30);

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
        // First time, use the new telemetry as-is
        telemetryMap[deviceId] = newTelemetry;
      }

      // NOTE: Auto mode NO LONGER triggers here!
      // It now uses a 30-second timer to sync with DB updates from subscriber.

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

  Future<void> _triggerAutoActuator(String deviceId) async {
    try {
      final api = _ref.read(apiServiceProvider);

      // Send auto mode request
      final res = await api.postJson("/actuator/event?deviceId=$deviceId", {
        "phUp": 0,
        "phDown": 0,
        "nutrientAdd": 0,
        "valueS": 0,
        "manual": 0,
        "auto": 1, // ← This triggers ML/rule-based calculation
        "refill": 0,
      });

      // Extract calculated values from response
      if (res != null && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        // Send calculated values to MQTT
        await _svc.publishControl("auto", data, deviceId);

        print("[MQTT] Auto actuator event sent for $deviceId with data: $data");
      } else {
        print("[MQTT] Auto actuator response missing data");
      }
    } catch (e) {
      print("[MQTT] Error sending auto actuator: $e");
    }
  }

  /// Start the auto mode timer if not already running
  void _startAutoModeTimer() {
    if (_autoModeTimer != null) return; // Already running
    
    print("[MQTT] Starting auto mode timer (every ${_autoModeInterval.inSeconds}s)");
    
    // Trigger immediately for the first time
    _runAutoModeForAllDevices();
    
    // Then run periodically
    _autoModeTimer = Timer.periodic(_autoModeInterval, (_) {
      _runAutoModeForAllDevices();
    });
  }

  /// Stop the auto mode timer
  void _stopAutoModeTimer() {
    if (_autoModeTimer == null) return;
    
    print("[MQTT] Stopping auto mode timer");
    _autoModeTimer?.cancel();
    _autoModeTimer = null;
  }

  /// Trigger auto actuator for all devices in auto mode
  void _runAutoModeForAllDevices() {
    if (_autoModeDevices.isEmpty) return;
    
    print("[MQTT] Auto mode timer tick - ${_autoModeDevices.length} device(s)");
    
    for (final deviceId in _autoModeDevices) {
      _triggerAutoActuator(deviceId);
    }
  }

  void enableAutoMode(String deviceId) {
    final wasEmpty = _autoModeDevices.isEmpty;
    _autoModeDevices.add(deviceId);
    print("[MQTT] Auto mode ENABLED for $deviceId");
    
    // Start timer if this is the first device
    if (wasEmpty && _autoModeDevices.isNotEmpty) {
      _startAutoModeTimer();
    }
    
    notifyListeners();
  }

  void disableAutoMode(String deviceId) {
    _autoModeDevices.remove(deviceId);
    print("[MQTT] Auto mode DISABLED for $deviceId");
    
    // Stop timer if no more devices in auto mode
    if (_autoModeDevices.isEmpty) {
      _stopAutoModeTimer();
    }
    
    notifyListeners();
  }

  /// Check if a device is in auto mode
  bool isAutoMode(String deviceId) {
    return _autoModeDevices.contains(deviceId);
  }

  Future<void> disposeSafely() async {
    // Cancel auto mode timer
    _stopAutoModeTimer();
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
    _stopAutoModeTimer();
    super.dispose();
  }
}
