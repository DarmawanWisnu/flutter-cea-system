import 'package:flutter_dotenv/flutter_dotenv.dart';

/// MQTT CONFIGURATION
class MqttConst {
  // Host broker
  static String get host => dotenv.env['MQTT_HOST'] ?? '10.0.2.2';

  // Port broker
  static int get port =>
      int.tryParse(dotenv.env['MQTT_PORT'] ?? '1883') ?? 1883;

  // Username/password
  static String get username => dotenv.env['MQTT_USERNAME'] ?? '';
  static String get password => dotenv.env['MQTT_PASSWORD'] ?? '';

  // Client ID prefix
  static String get clientPrefix =>
      dotenv.env['MQTT_CLIENT_PREFIX'] ?? 'hydro-app-';

  // MQTT non-TLS
  static const bool tls = false;

  // Topic helper
  static String tControl(String kitId) => "kit/$kitId/control";
}

/// THRESHOLDS Selada Hydroponic
class ThresholdConst {
  static const double ppmMin = 560.0;
  static const double ppmMax = 840.0;

  static const double phMin = 5.5;
  static const double phMax = 6.5;

  static const double tempMin = 18.0;
  static const double tempMax = 24.0;

  // Water level thresholds (0-3 scale: 0=empty, 1=low, 2=medium, 3=high)
  static const double wlMin = 1.2;
  static const double wlMax = 2.5;
}
