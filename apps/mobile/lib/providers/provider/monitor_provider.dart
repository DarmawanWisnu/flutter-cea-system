import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';

/// STATE
class MonitorState {
  final Telemetry? data;
  final DateTime? lastUpdated;
  final bool loading;

  const MonitorState({this.data, this.lastUpdated, this.loading = false});

  MonitorState copyWith({
    Telemetry? data,
    DateTime? lastUpdated,
    bool? loading,
  }) {
    return MonitorState(
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      loading: loading ?? this.loading,
    );
  }
}

/// PROVIDER
final monitorTelemetryProvider =
    StateNotifierProvider.family<MonitorNotifier, MonitorState, String>((
      ref,
      kitId,
    ) {
      return MonitorNotifier(ref, kitId);
    });

/// NOTIFIER
class MonitorNotifier extends StateNotifier<MonitorState> {
  final Ref ref;
  String kitId;

  StreamSubscription<Telemetry>? _sub;

  MonitorNotifier(this.ref, this.kitId)
    : super(const MonitorState(loading: true)) {
    _init();
  }

  /// INIT / SWITCH KIT
  Future<void> _init() async {
    state = state.copyWith(loading: true);

    // Snapshot pertama dari API
    final api = ref.read(apiServiceProvider);
    final latest = await api.getLatestTelemetry(kitId);

    state = state.copyWith(
      data: latest,
      lastUpdated: DateTime.now(),
      loading: false,
    );

    // MQTT realtime
    // before publishing
    final mqttVM = ref.read(mqttProvider.notifier);
    print("[MONITOR] calling mqtt init…");
    await mqttVM.init(kitId: kitId);
    // Listen stream
    _sub = mqttVM.service.telemetry$.listen((t) {
      state = state.copyWith(data: t, lastUpdated: DateTime.now());
    });
  }

  /// SWITCH KIT
  Future<void> switchKit(String newKitId) async {
    if (newKitId == kitId) return;

    kitId = newKitId;
    await _sub?.cancel();
    await _init();
  }

  /// ACTUATOR API
  Future<void> _actuatorEvent({required String field}) async {
    final api = ref.read(apiServiceProvider);

    final body = {
      "phUp": 0,
      "phDown": 0,
      "nutrientAdd": 0,
      "valueS": 0,
      "manual": 0,
      "auto": 0,
      "refill": 0,
    };

    body[field] = 1;

    // 1. KIRIM KE BACKEND
    api.postJson("/actuator/event?deviceId=$kitId", body);

    // 2. MQTT MAPPER (CAMELCASE)
    final mqtt = ref.read(mqttProvider.notifier);

    switch (field) {
      case "phUp":
        mqtt.phUp();
        break;
      case "phDown":
        mqtt.phDown();
        break;
      case "nutrientAdd":
        mqtt.nutrientAdd();
        break;
      case "refill":
        mqtt.refill();
        break;
      case "manual":
        mqtt.setManual();
        break;
      case "auto":
        mqtt.setAuto();
        break;
      default:
        print("[MQTT] Unknown actuator field: $field");
    }
  }

  Future<void> phUp() => _actuatorEvent(field: "phUp");
  Future<void> phDown() => _actuatorEvent(field: "phDown");
  Future<void> nutrientAdd() => _actuatorEvent(field: "nutrientAdd");
  Future<void> refill() => _actuatorEvent(field: "refill");
  Future<void> setManual() => _actuatorEvent(field: "manual");
  Future<void> setAuto() => _actuatorEvent(field: "auto");

  /// DISPOSE
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
