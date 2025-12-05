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

  // WILDCARD → kit kirim pair: (kitId, Telemetry)
  final _telemetryCtrl =
      StreamController<MapEntry<String, Telemetry>>.broadcast();
  Stream<MapEntry<String, Telemetry>> get telemetry$ => _telemetryCtrl.stream;

  final _statusCtrl =
      StreamController<MapEntry<String, DeviceStatus>>.broadcast();
  Stream<MapEntry<String, DeviceStatus>> get status$ => _statusCtrl.stream;

  MqttServerClient? _client;
  Timer? _reconnectTimer;

  bool _intentionalDisconnect = false;

  Future<void> connect() async {
    print("[MQTT] connecting to ${MqttConst.host}:${MqttConst.port}");
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

    // WILL message
    c.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

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

      // SUBSCRIBE WILDCARD
      c.subscribe("kit/+/telemetry", MqttQos.atLeastOnce);
      c.subscribe("kit/+/status", MqttQos.atLeastOnce);

      print("[MQTT] wildcard subscribed: kit/+/telemetry & kit/+/status");

      c.updates?.listen((events) {
        for (final ev in events) {
          final msg = ev.payload as MqttPublishMessage;
          final topic = ev.topic;
          final payload = MqttPublishPayload.bytesToStringAsString(
            msg.payload.message,
          );

          // print("[MQTT] EVENT → $topic : $payload"); // Commented to reduce noise

          final parts = topic.split("/");
          if (parts.length < 3) continue;

          final kitId = parts[1];

          if (topic.contains("/telemetry")) {
            try {
              final map = jsonDecode(payload);
              final t = Telemetry.fromJson(map);
              _telemetryCtrl.add(MapEntry(kitId, t));
            } catch (_) {}
          }

          if (topic.contains("/status")) {
            try {
              final s = DeviceStatus.fromJson(jsonDecode(payload));
              _statusCtrl.add(MapEntry(kitId, s));
            } catch (_) {}
          }
        }
      });
    } catch (e) {
      print("[MQTT] connect error: $e");
      _connStateCtrl.add(MqttConnState.error);
      try {
        _client?.disconnect();
      } catch (_) {}
      _scheduleReconnect();
    }
  }

  Future<void> publishControl(
    String cmd,
    Map<String, dynamic> data,
    String kitId,
  ) async {
    final cli = _client;
    if (cli == null) return;

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

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () => connect());
  }

  void _onDisconnected() {
    print("[MQTT] DISCONNECTED");
    _connStateCtrl.add(MqttConnState.disconnected);

    if (_intentionalDisconnect) return;
    _scheduleReconnect();
  }

  Future<void> disconnect() async {
    _intentionalDisconnect = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      _client?.disconnect();
    } catch (_) {}

    _client = null;

    _connStateCtrl.add(MqttConnState.disconnected);
    _intentionalDisconnect = false;
  }

  Future<void> dispose() async {
    await disconnect();
    await _telemetryCtrl.close();
    await _statusCtrl.close();
    await _connStateCtrl.close();
  }
}
