import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock MQTT class for testing
class _MockMqttVM extends ChangeNotifier {
  final Ref _ref;
  _MockMqttVM(this._ref);
  
  Future<void> init() async {}
  Future<void> publishActuator(String command, {Map<String, dynamic>? args, required String kitId}) async {}
  void enableAutoMode(String deviceId) {}
  void disableAutoMode(String deviceId) {}
}
