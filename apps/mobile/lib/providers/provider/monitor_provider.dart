import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/providers/provider/mqtt_provider.dart';

///   STATE
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

///   PROVIDER
/// autoDispose
final monitorTelemetryProvider = StateNotifierProvider.autoDispose
    .family<MonitorNotifier, MonitorState, String>((ref, kitId) {
      return MonitorNotifier(ref, kitId);
    });

///   NOTIFIER
class MonitorNotifier extends StateNotifier<MonitorState> {
  final Ref ref;
  final String kitId;

  StreamSubscription<Telemetry>? _sub;

  MonitorNotifier(this.ref, this.kitId)
    : super(const MonitorState(loading: true)) {
    _init();
  }

  Future<void> _init() async {
    /// Snapshot pertama dari API
    final api = ref.read(apiTelemetryProvider);
    final latest = await api.getLatest(kitId);

    state = state.copyWith(
      data: latest,
      lastUpdated: DateTime.now(),
      loading: false,
    );

    /// STEP 2 — Realtime dari MQTT
    final mqttVM = ref.read(mqttProvider.notifier);

    /// Connect atau switch kit (idempotent)
    await mqttVM.init(kitId: kitId);

    /// Listen telemetry stream
    _sub = mqttVM.service.telemetry$.listen((t) {
      state = state.copyWith(data: t, lastUpdated: DateTime.now());
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
