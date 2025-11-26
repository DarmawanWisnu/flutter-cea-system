import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../core/constants.dart';
import '../domain/telemetry.dart';
import '../domain/device_status.dart';

enum MqttConnState { disconnected, connecting, connected, error }

class MqttService {
  final _connStateCtrl = StreamController<MqttConnState>.broadcast();
  Stream<MqttConnState> get connectionState$ => _connStateCtrl.stream;

  final _telemetryCtrl = StreamController<Telemetry>.broadcast();
  Stream<Telemetry> get telemetry$ => _telemetryCtrl.stream;

  final _statusCtrl = StreamController<DeviceStatus>.broadcast();
  Stream<DeviceStatus> get status$ => _statusCtrl.stream;

  MqttServerClient? _client;
  Timer? _reconnectTimer;
  String? _kitId;

  // CONNECT
  Future<void> connect({required String kitId}) async {
    _kitId = kitId;
    _connStateCtrl.add(MqttConnState.connecting);

    final clientId =
        "${MqttConst.clientPrefix}${DateTime.now().millisecondsSinceEpoch}";

    final c =
        MqttServerClient.withPort(MqttConst.host, clientId, MqttConst.port)
          ..secure = MqttConst.tls
          ..logging(on: false)
          ..keepAlivePeriod = 30
          ..autoReconnect = true;

    c.onDisconnected = _onDisconnected;
    c.onConnected = () => _connStateCtrl.add(MqttConnState.connected);

    // Will message (offline)
    final willTopic = MqttConst.tStatus(kitId);
    c.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillTopic(willTopic)
        .withWillMessage(
          jsonEncode({"online": false, "ts": DateTime.now().toIso8601String()}),
        )
        .withWillQos(MqttQos.atLeastOnce)
        .withWillRetain();

    try {
      final status = await c.connect(
        MqttConst.username.isEmpty ? null : MqttConst.username,
        MqttConst.password.isEmpty ? null : MqttConst.password,
      );

      if (status?.state != MqttConnectionState.connected) {
        _connStateCtrl.add(MqttConnState.error);
        c.disconnect();
        _scheduleReconnect();
        return;
      }

      _client = c;
      _connStateCtrl.add(MqttConnState.connected);

      // Publish ONLINE status
      _publish(willTopic, {
        "online": true,
        "ts": DateTime.now().toIso8601String(),
      }, retain: true);

      // SUBSCRIBE
      final teleTopic = MqttConst.tTelemetry(kitId);
      final statTopic = MqttConst.tStatus(kitId);

      c.subscribe(teleTopic, MqttQos.atLeastOnce);
      c.subscribe(statTopic, MqttQos.atLeastOnce);

      c.updates?.listen((events) {
        for (final ev in events) {
          final msg = ev.payload as MqttPublishMessage;
          final topic = ev.topic;
          final payload = MqttPublishPayload.bytesToStringAsString(
            msg.payload.message,
          );

          // TELEMETRY
          if (topic == teleTopic) {
            try {
              final map = jsonDecode(payload);
              final t = Telemetry.fromJson(map);
              _telemetryCtrl.add(t);
            } catch (_) {}
          }

          // STATUS
          if (topic == statTopic) {
            try {
              final s = DeviceStatus.fromJson(jsonDecode(payload));
              _statusCtrl.add(s);
            } catch (_) {}
          }
        }
      });
    } catch (_) {
      _connStateCtrl.add(MqttConnState.error);
      _client?.disconnect();
      _scheduleReconnect();
    }
  }

  // CONTROL (ACTUATOR PUBLISH)
  Future<void> publishControl(String cmd, Map<String, dynamic> data) async {
    final cli = _client;
    final kitId = _kitId;

    if (cli == null || kitId == null) return;

    final topic = MqttConst.tControl(kitId);

    final payload = {
      "cmd": cmd,
      "data": data,
      "ts": DateTime.now().toIso8601String(),
    };

    final builder = MqttClientPayloadBuilder()
      ..addUTF8String(jsonEncode(payload));

    cli.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: false,
    );
  }

  // INTERNAL PUBLISH
  void _publish(String topic, Map<String, dynamic> obj, {bool retain = false}) {
    final cli = _client;
    if (cli == null) return;

    final builder = MqttClientPayloadBuilder()..addUTF8String(jsonEncode(obj));

    cli.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: retain,
    );
  }

  // RECONNECT HANDLER
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_kitId == null) return;

    _reconnectTimer = Timer(
      const Duration(seconds: 5),
      () => connect(kitId: _kitId!),
    );
  }

  void _onDisconnected() {
    _connStateCtrl.add(MqttConnState.disconnected);
    _scheduleReconnect();
  }

  // DISCONNECT CLEAN
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _connStateCtrl.add(MqttConnState.disconnected);
  }

  // DISPOSE INTERNAL
  Future<void> dispose() async {
    await disconnect();
    await _telemetryCtrl.close();
    await _statusCtrl.close();
    await _connStateCtrl.close();
  }
}
