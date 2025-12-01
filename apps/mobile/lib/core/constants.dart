import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class AppConst {
  // Kit default
  static String get defaultKitId => dotenv.env['DEFAULT_KIT_ID'] ?? 'devkit-01';

  // Format datetime
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return "-";
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(dt.toLocal());
  }
}

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

  // Topic
  static String tTelemetry(String kitId) => "kit/$kitId/telemetry";
  static String tStatus(String kitId) => "kit/$kitId/status";
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

  static const double wlMinPercent = 40.0;
  static const double wlMaxPercent = 85.0;

  static const double hysteresisPercent = 5.0;
  static const int confirmSamples = 3;
  static const int alertCooldownMin = 5;
}
