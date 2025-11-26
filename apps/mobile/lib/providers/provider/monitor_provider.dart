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
final monitorTelemetryProvider = StateNotifierProvider.autoDispose
    .family<MonitorNotifier, MonitorState, String>((ref, kitId) {
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
    final mqttVM = ref.read(mqttProvider.notifier);
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

    await api.postJson("/actuator/event", {
      "deviceId": kitId,
      "ingestTime": DateTime.now().millisecondsSinceEpoch,
      field: 1,
    });

    // publish MQTT
    ref.read(mqttProvider.notifier).publishActuator(field);
  }

  Future<void> phUp() => _actuatorEvent(field: "phUp");
  Future<void> phDown() => _actuatorEvent(field: "phDown");
  Future<void> nutrientAdd() => _actuatorEvent(field: "nutrientAdd");
  Future<void> refill() => _actuatorEvent(field: "refill");

  /// Auto / Manual Mode
  Future<void> setManual() => _actuatorEvent(field: "manual");
  Future<void> setAuto() => _actuatorEvent(field: "auto");

  /// DISPOSE
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
