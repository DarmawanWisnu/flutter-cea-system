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
    _initMqtt();
    _init();
    _setupListener();
  }

  /// Listen telemetryMap from mqttProvider
  void _setupListener() {
    _mqttSub = ref.listen(mqttProvider, (_, next) {
      final map = next.telemetryMap;
      print("[MonitorNotifier] MQTT update received, telemetryMap keys: ${map.keys.toList()}, current kitId: $kitId");
      if (map.containsKey(kitId)) {
        final newData = map[kitId];
        print("[MonitorNotifier] Updating state with new telemetry for $kitId");
        state = state.copyWith(data: newData, lastUpdated: DateTime.now());
      } else {
        print("[MonitorNotifier] No telemetry data for $kitId yet");
      }
    }, fireImmediately: true);
  }

  /// INIT (API snapshot first)
  Future<void> _init() async {
    state = state.copyWith(loading: true);

    final api = ref.read(apiServiceProvider);
    print("[MonitorNotifier] Fetching latest telemetry for kitId: $kitId");
    final latest = await api.getLatestTelemetry(kitId);
    print("[MonitorNotifier] Got telemetry: ${latest != null ? 'data received' : 'null'}");

    state = state.copyWith(
      data: latest,
      lastUpdated: DateTime.now(),
      loading: false,
    );
  }

  /// Initialize MQTT connection
  Future<void> _initMqtt() async {
    try {
      await ref.read(mqttProvider.notifier).init();
      print("[Monitor] MQTT initialized");
    } catch (e) {
      print("[Monitor] MQTT init error: $e");
    }
  }

  /// SWITCH KIT
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
  }

  /// ACTUATOR API
  Future<void> _actuatorEvent({required String field}) async {
    print("[Flutter] _actuatorEvent called with field: $field");
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
    print(
      "[Flutter] Sending to /actuator/event?deviceId=$kitId with body: $body",
    );

    // Await with error handling
    Map<String, dynamic>? responseData;
    try {
      final res = await api.postJson("/actuator/event?deviceId=$kitId", body);
      print("[Flutter] Response received: $res");
      if (res != null && res['data'] != null) {
        responseData = res['data'];
        print("[Flutter] Response data: $responseData");
      }
    } catch (e) {
      print("[Actuator] Error: $e");
    }

    // 2. MQTT CONTROL
    final mqtt = ref.read(mqttProvider.notifier);

    switch (field) {
      case "phUp":
        mqtt.publishActuator(
          "phUp",
          kitId: kitId,
          args: responseData,
        ); // <--- 3. Add args
        break;
      case "phDown":
        mqtt.publishActuator("phDown", kitId: kitId, args: responseData);
        break;
      case "nutrientAdd":
        mqtt.publishActuator("nutrientAdd", kitId: kitId, args: responseData);
        break;
      case "refill":
        mqtt.publishActuator("refill", kitId: kitId, args: responseData);
        break;
      case "manual":
        mqtt.publishActuator("manual", kitId: kitId, args: responseData);
        break;
      case "auto":
        mqtt.publishActuator("auto", kitId: kitId, args: responseData);
        break;
    }
  }

  Future<void> phUp() => _actuatorEvent(field: "phUp");
  Future<void> phDown() => _actuatorEvent(field: "phDown");
  Future<void> nutrientAdd() => _actuatorEvent(field: "nutrientAdd");
  Future<void> refill() => _actuatorEvent(field: "refill");
  Future<void> setAuto() async {
    await _actuatorEvent(field: "auto");

    // Enable auto mode in MQTT provider
    ref.read(mqttProvider.notifier).enableAutoMode(kitId);
  }

  Future<void> setManual() async {
    await _actuatorEvent(field: "manual");

    // Disable auto mode in MQTT provider
    ref.read(mqttProvider.notifier).disableAutoMode(kitId);
  }

  /// DISPOSE
  @override
  void dispose() {
    _mqttSub.close();
    super.dispose();
  }
}
