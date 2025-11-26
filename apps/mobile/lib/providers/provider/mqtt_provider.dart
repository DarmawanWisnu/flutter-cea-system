import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/services/mqtt_service.dart';

/// MQTT Provider (autoDispose) — aman dan stabil
final mqttProvider = ChangeNotifierProvider.autoDispose<MqttVM>((ref) {
  final vm = MqttVM();

  // Pastikan ketika provider dihancurkan → MQTT disconnect aman
  ref.onDispose(() {
    vm.disposeSafely();
  });

  return vm;
});

class MqttVM extends ChangeNotifier {
  final MqttService _svc = MqttService();

  MqttConnState _state = MqttConnState.disconnected;
  MqttConnState get state => _state;

  StreamSubscription<MqttConnState>? _connSub;

  bool _initializing = false;
  bool _initialized = false;
  String? _currentKitId;

  bool get isConnected => _state == MqttConnState.connected;

  // ------------------------------------------------------------
  // INIT — idempotent & aman
  // ------------------------------------------------------------
  Future<void> init({required String kitId}) async {
    if (_initializing) return;
    _initializing = true;

    // Pasang listener koneksi hanya sekali
    _connSub ??= _svc.connectionState$.listen((s) {
      _state = s;
      notifyListeners();
    });

    // CASE: pertama kali
    if (!_initialized) {
      _initialized = true;
      _currentKitId = kitId;

      await _svc.connect(kitId: kitId);

      _initializing = false;
      return;
    }

    // CASE: sudah init tapi pindah KIT
    if (kitId != _currentKitId) {
      _currentKitId = kitId;

      await _svc.disconnect();
      await _svc.connect(kitId: kitId);
    }

    _initializing = false;
  }

  // ------------------------------------------------------------
  // ACCESS ke service (telemetry$, status$, publishControl)
  // ------------------------------------------------------------
  MqttService get service => _svc;

  // ------------------------------------------------------------
  // SWITCH KIT (opsional)
  // ------------------------------------------------------------
  Future<void> switchKit(String kitId) async {
    if (kitId == _currentKitId) return;

    _currentKitId = kitId;
    await _svc.disconnect();
    await _svc.connect(kitId: kitId);
  }

  // ------------------------------------------------------------
  // SEND CONTROL ke actuator (pH up/down, pump, nutrient, etc)
  // ------------------------------------------------------------
  Future<void> sendControl(String cmd, Map<String, dynamic> args) async {
    if (!isConnected) {
      debugPrint("[MQTT] Cannot send control → not connected");
      return;
    }

    await _svc.publishControl(cmd, args);
  }

  // ------------------------------------------------------------
  // SAFE DISPOSE — tidak menutup StreamController MQTT
  // ------------------------------------------------------------
  Future<void> disposeSafely() async {
    // bersihkan listener
    await _connSub?.cancel();
    _connSub = null;

    // hanya disconnect, jangan dispose full StreamController
    await _svc.disconnect();

    _initialized = false;
    _currentKitId = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
