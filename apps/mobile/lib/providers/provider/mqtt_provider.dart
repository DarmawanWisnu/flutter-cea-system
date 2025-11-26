import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/services/mqtt_service.dart';

final mqttProvider = ChangeNotifierProvider.autoDispose<MqttVM>((ref) {
  final vm = MqttVM();

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

  // INIT MQTT
  Future<void> init({required String kitId}) async {
    if (_initializing) return;
    _initializing = true;

    // Listen connection state (setup one-time only)
    _connSub ??= _svc.connectionState$.listen((s) {
      _state = s;
      notifyListeners();
    });

    // FIRST INIT
    if (!_initialized) {
      _initialized = true;
      _currentKitId = kitId;

      await _svc.connect(kitId: kitId);

      _initializing = false;
      return;
    }

    // SWITCH KIT
    if (kitId != _currentKitId) {
      _currentKitId = kitId;

      await _svc.disconnect();
      await _svc.connect(kitId: kitId);
    }

    _initializing = false;
  }

  // SERVICE ACCESSOR
  MqttService get service => _svc;

  // SWITCH KIT
  Future<void> switchKit(String kitId) async {
    if (kitId == _currentKitId) return;
    _currentKitId = kitId;

    await _svc.disconnect();
    await _svc.connect(kitId: kitId);
  }

  // ACTUATOR CONTROL
  Future<void> publishActuator(
    String command, {
    Map<String, dynamic>? args,
  }) async {
    if (!isConnected) {
      debugPrint("[MQTT] Cannot publish actuator → not connected");
      return;
    }

    await _svc.publishControl(
      command, // <-- ini CMD
      args ?? {},
    );
  }

  Future<void> phUp() => publishActuator("ph_up");
  Future<void> phDown() => publishActuator("ph_down");
  Future<void> nutrientAdd() => publishActuator("nutrient_add");
  Future<void> refill() => publishActuator("refill");

  // Auto / Manual
  Future<void> setAuto() => publishActuator("mode_auto");
  Future<void> setManual() => publishActuator("mode_manual");

  // DISPOSE SAFE
  Future<void> disposeSafely() async {
    await _connSub?.cancel();
    _connSub = null;

    await _svc.disconnect();

    _initialized = false;
    _currentKitId = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
