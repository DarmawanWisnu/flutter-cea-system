import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/services/mqtt_service.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/domain/device_status.dart';

final mqttProvider = ChangeNotifierProvider<MqttVM>((ref) {
  ref.keepAlive();
  final vm = MqttVM();

  ref.onDispose(vm.disposeSafely);

  return vm;
});

class MqttVM extends ChangeNotifier {
  final MqttService _svc = MqttService();

  MqttConnState _state = MqttConnState.disconnected;
  MqttConnState get state => _state;

  final Map<String, Telemetry> telemetryMap = {};
  final Map<String, DeviceStatus> statusMap = {};

  StreamSubscription<MqttConnState>? _connSub;
  StreamSubscription<MapEntry<String, Telemetry>>? _teleSub;
  StreamSubscription<MapEntry<String, DeviceStatus>>? _statSub;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _connSub = _svc.connectionState$.listen((s) {
      _state = s;
      notifyListeners();
    });

    _teleSub = _svc.telemetry$.listen((entry) {
      telemetryMap[entry.key] = entry.value;
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

  Future<void> disposeSafely() async {
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
