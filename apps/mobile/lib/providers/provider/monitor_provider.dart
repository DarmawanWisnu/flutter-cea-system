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

  late final ProviderSubscription _mqttSub;

  MonitorNotifier(this.ref, this.kitId)
    : super(const MonitorState(loading: true)) {
    _init();
    _setupListener();
  }

  /// Listen telemetryMap from mqttProvider
  void _setupListener() {
    _mqttSub = ref.listen(mqttProvider, (_, next) {
      final map = next.telemetryMap;
      if (map.containsKey(kitId)) {
        state = state.copyWith(data: map[kitId], lastUpdated: DateTime.now());
      }
    }, fireImmediately: true);
  }

  /// INIT (API snapshot first)
  Future<void> _init() async {
    state = state.copyWith(loading: true);

    final api = ref.read(apiServiceProvider);
    final latest = await api.getLatestTelemetry(kitId);

    state = state.copyWith(
      data: latest,
      lastUpdated: DateTime.now(),
      loading: false,
    );
  }

  /// SWITCH KIT (does NOT touch MQTT anymore)
  Future<void> switchKit(String newKitId) async {
    if (newKitId == kitId) return;

    kitId = newKitId;

    state = state.copyWith(loading: true);

    // re-fetch snapshot from API
    final api = ref.read(apiServiceProvider);
    final latest = await api.getLatestTelemetry(kitId);

    state = state.copyWith(
      data: latest,
      lastUpdated: DateTime.now(),
      loading: false,
    );

    // stream real-time akan update otomatis dari listener
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

    // Await with error handling
    try {
      await api.postJson("/actuator/event?deviceId=$kitId", body);
    } catch (e) {
      print("[Actuator] Error: $e");
      // Optional: show error to user
    }

    // 2. MQTT CONTROL
    final mqtt = ref.read(mqttProvider.notifier);

    switch (field) {
      case "phUp":
        mqtt.publishActuator("phUp", kitId: kitId);
        break;
      case "phDown":
        mqtt.publishActuator("phDown", kitId: kitId);
        break;
      case "nutrientAdd":
        mqtt.publishActuator("nutrientAdd", kitId: kitId);
        break;
      case "refill":
        mqtt.publishActuator("refill", kitId: kitId);
        break;
      case "manual":
        mqtt.publishActuator("manual", kitId: kitId);
        break;
      case "auto":
        mqtt.publishActuator("auto", kitId: kitId);
        break;
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
    _mqttSub.close();
    super.dispose();
  }
}
