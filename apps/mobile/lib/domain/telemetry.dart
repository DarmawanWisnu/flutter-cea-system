class Telemetry {
  final int? id;
  final double ppm;
  final double ph;
  final double tempC;
  final double humidity;
  final double waterTemp;
  final double waterLevel;

  const Telemetry({
    this.id,
    required this.ppm,
    required this.ph,
    required this.tempC,
    required this.humidity,
    required this.waterTemp,
    required this.waterLevel,
  });

  // Convert dynamic ke double aman
  static double _toDouble(dynamic v, [double def = 0]) {
    if (v == null) return def;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? def;
    return def;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory Telemetry.fromJson(Map<String, dynamic> j) {
    return Telemetry(
      id: _toInt(j['id']),
      ppm: _toDouble(j['ppm']),
      ph: _toDouble(j['ph']),
      tempC: _toDouble(j['tempC']),
      humidity: _toDouble(j['humidity']),
      waterTemp: _toDouble(j['waterTemp'] ?? j['water_temp']),
      waterLevel: _toDouble(j['waterLevel'] ?? j['water_level']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) "id": id,
    "ppm": ppm,
    "ph": ph,
    "tempC": tempC,
    "humidity": humidity,
    "waterTemp": waterTemp,
    "waterLevel": waterLevel,
  };

  Telemetry copyWith({
    int? id,
    double? ppm,
    double? ph,
    double? tempC,
    double? humidity,
    double? waterTemp,
    double? waterLevel,
  }) {
    return Telemetry(
      id: id ?? this.id,
      ppm: ppm ?? this.ppm,
      ph: ph ?? this.ph,
      tempC: tempC ?? this.tempC,
      humidity: humidity ?? this.humidity,
      waterTemp: waterTemp ?? this.waterTemp,
      waterLevel: waterLevel ?? this.waterLevel,
    );
  }

  /// Untuk update 1 sensor dari MQTT realtime:
  Telemetry updateSensor(String sensor, double value) {
    switch (sensor) {
      case 'ppm':
        return copyWith(ppm: value);
      case 'ph':
        return copyWith(ph: value);
      case 'tempC':
        return copyWith(tempC: value);
      case 'humidity':
        return copyWith(humidity: value);
      case 'waterTemp':
        return copyWith(waterTemp: value);
      case 'waterLevel':
        return copyWith(waterLevel: value);
      default:
        return this;
    }
  }
}
