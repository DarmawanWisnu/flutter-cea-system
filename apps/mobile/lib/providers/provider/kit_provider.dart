import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/domain/device_status.dart';
import 'package:fountaine/services/mqtt_service.dart';

/// Provider global untuk list Kit
final kitListProvider = StateNotifierProvider<KitListNotifier, List<Kit>>((
  ref,
) {
  return KitListNotifier(ref);
});

/// Model Kit
class Kit {
  final String id;
  final String name;
  final bool online;
  final DateTime lastUpdated;
  final Telemetry? telemetry;

  Kit({
    required this.id,
    required this.name,
    this.online = false,
    DateTime? lastUpdated,
    this.telemetry,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'online': online,
    'lastUpdated': lastUpdated.toIso8601String(),
    'telemetry': telemetry?.toJson(),
  };

  static Kit fromJson(Map<String, dynamic> j) => Kit(
    id: j['id'],
    name: j['name'],
    online: j['online'] ?? false,
    lastUpdated: DateTime.tryParse(j['lastUpdated'] ?? '') ?? DateTime.now(),
    telemetry: j['telemetry'] != null
        ? Telemetry.fromJson(Map<String, dynamic>.from(j['telemetry']))
        : null,
  );

  Kit copyWith({
    String? id,
    String? name,
    bool? online,
    DateTime? lastUpdated,
    Telemetry? telemetry,
  }) => Kit(
    id: id ?? this.id,
    name: name ?? this.name,
    online: online ?? this.online,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    telemetry: telemetry ?? this.telemetry,
  );
}

/// NOTIFIER
class KitListNotifier extends StateNotifier<List<Kit>> {
  final Ref ref;
  KitListNotifier(this.ref) : super([]) {
    _load();
  }

  static const _storageKey = 'kits';
  final MqttService _mqtt = MqttService();

  StreamSubscription<Map<String, dynamic>>? _sensorSub;
  StreamSubscription<DeviceStatus>? _statusSub;
  String? _currentKitId;

  // LOAD / SAVE
  Future<void> _load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_storageKey) ?? '[]';
      final arr = jsonDecode(raw) as List;
      state = arr
          .map((e) => Kit.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _storageKey,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  // CRUD
  Future<void> addKit(Kit kit) async {
    if (state.any((k) => k.id == kit.id)) {
      throw Exception("Kit sudah ada");
    }
    state = [kit, ...state];
    await _save();
  }

  Future<void> removeKit(String id) async {
    state = state.where((k) => k.id != id).toList();
    await _save();
  }

  Future<void> updateKit(Kit kit) async {
    final i = state.indexWhere((k) => k.id == kit.id);
    if (i == -1) return;

    final s = [...state];
    s[i] = kit;
    state = s;
    await _save();
  }

  // CONNECT & LISTEN
  Future<void> listenToKit(String kitId, {String? kitName}) async {
    // upsert kit
    if (!state.any((k) => k.id == kitId)) {
      state = [Kit(id: kitId, name: kitName ?? kitId), ...state];
      await _save();
    }

    if (_currentKitId != null && _currentKitId != kitId) {
      await stopListening();
    }
    _currentKitId = kitId;

    // Fetch initial telemetry from API
    final latest = await ref.read(apiTelemetryProvider).getLatest(kitId);

    state = [
      for (final k in state)
        k.id == kitId
            ? k.copyWith(
                telemetry: latest,
                online: true,
                lastUpdated: DateTime.now(),
              )
            : k,
    ];

    await _save();

    // Connect MQTT
    await _mqtt.connect(kitId: kitId);

    // SENSOR REALTIME
    _sensorSub = _mqtt.sensorUpdate$().listen((msg) {
      final sensor = msg['sensor'];
      final value = msg['value'] * 1.0;

      state = [
        for (final k in state)
          k.id == kitId
              ? k.copyWith(
                  telemetry: k.telemetry?.updateSensor(sensor, value),
                  lastUpdated: DateTime.now(),
                  online: true,
                )
              : k,
      ];
    });

    // STATUS (online/offline)
    _statusSub = _mqtt.status$(kitId).listen((s) {
      state = [
        for (final k in state)
          k.id == kitId
              ? k.copyWith(
                  online: s.online,
                  lastUpdated: s.lastSeen ?? DateTime.now(),
                )
              : k,
      ];
    });
  }

  // STOP LISTENERS
  Future<void> stopListening() async {
    await _sensorSub?.cancel();
    await _statusSub?.cancel();
    _sensorSub = null;
    _statusSub = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
