import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../core/constants.dart';
import '../domain/device_status.dart';

enum MqttConnState { disconnected, connecting, connected, error }

class MqttService {
  final _connStateCtrl = StreamController<MqttConnState>.broadcast();
  Stream<MqttConnState> get connectionState$ => _connStateCtrl.stream;

  /// Stream MQTT realtime → update single sensor
  final _sensorUpdateCtrl = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> sensorUpdate$() => _sensorUpdateCtrl.stream;

  final _statusCtrl = StreamController<DeviceStatus>.broadcast();
  Stream<DeviceStatus> status$(String kitId) => _statusCtrl.stream;

  MqttServerClient? _client;
  Timer? _reconnectTimer;
  String? _kitId;

  Future<void> connect({required String kitId}) async {
    _kitId = kitId;
    _connStateCtrl.add(MqttConnState.connecting);

    final clientId =
        "${MqttConst.clientPrefix}${kitId}-${DateTime.now().millisecondsSinceEpoch}";

    final c =
        MqttServerClient.withPort(MqttConst.host, clientId, MqttConst.port)
          ..secure = MqttConst.tls
          ..logging(on: false)
          ..keepAlivePeriod = 30
          ..autoReconnect = true;

    c.onDisconnected = _onDisconnected;
    c.onConnected = () => _connStateCtrl.add(MqttConnState.connected);

    final topicStatus = MqttConst.tStatus(kitId);

    // Last will (offline)
    c.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillTopic(topicStatus)
        .withWillMessage(
          jsonEncode({"online": false, "ts": DateTime.now().toIso8601String()}),
        )
        .withWillRetain()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      final status = await c.connect(
        (MqttConst.username.isEmpty) ? null : MqttConst.username,
        (MqttConst.password.isEmpty) ? null : MqttConst.password,
      );

      if (status?.state != MqttConnectionState.connected) {
        _connStateCtrl.add(MqttConnState.error);
        c.disconnect();
        _scheduleReconnect();
        return;
      }

      _client = c;
      _connStateCtrl.add(MqttConnState.connected);

      // publish online
      _publish(topicStatus, {
        "online": true,
        "ts": DateTime.now().toIso8601String(),
      }, retain: true);

      final topicTelemetry = MqttConst.tTelemetry(kitId);

      // Subscribe topics
      c.subscribe(topicTelemetry, MqttQos.atLeastOnce);
      c.subscribe(topicStatus, MqttQos.atLeastOnce);

      c.updates?.listen((events) {
        for (final ev in events) {
          final msg = ev.payload as MqttPublishMessage;
          final topic = ev.topic;
          final payload = MqttPublishPayload.bytesToStringAsString(
            msg.payload.message,
          );

          if (topic == topicTelemetry) {
            _handleSensorPayload(payload);
          } else if (topic == topicStatus) {
            _handleStatusPayload(payload);
          }
        }
      });
    } catch (e, s) {
      _connStateCtrl.add(MqttConnState.error);
      _client?.disconnect();
      print('MQTT connect error: $e\n$s');
      _scheduleReconnect();
    }
  }

  /// HANDLE SENSOR-ONLY PAYLOAD
  void _handleSensorPayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final sensor = data["sensor"];
      final value = data["value"];

      if (sensor == null || value == null) return;

      // Emit sensor update
      _sensorUpdateCtrl.add({"sensor": sensor, "value": value});
    } catch (e, s) {
      print("MQTT sensor parse error: $e\n$s\nPayload: $payload");
    }
  }

  /// HANDLE STATUS PAYLOAD
  void _handleStatusPayload(String payload) {
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      _statusCtrl.add(DeviceStatus.fromJson(json));
    } catch (e, s) {
      print("MQTT status parse error: $e\n$s\nPayload: $payload");
    }
  }

  /// publish control command
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

  Future<void> publishControl(
    String kitId,
    String cmd,
    Map<String, dynamic> args,
  ) async {
    _publish(MqttConst.tControl(kitId), {
      "cmd": cmd,
      "args": args,
      "ts": DateTime.now().toIso8601String(),
    });
  }

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

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _connStateCtrl.add(MqttConnState.disconnected);
  }

  Future<void> dispose() async {
    await disconnect();
    await _sensorUpdateCtrl.close();
    await _statusCtrl.close();
    await _connStateCtrl.close();
  }
}
