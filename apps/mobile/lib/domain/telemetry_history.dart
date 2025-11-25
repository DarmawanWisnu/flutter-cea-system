import 'package:fountaine/domain/telemetry.dart';

class TelemetryHistoryItem {
  final DateTime ingestTime;
  final Telemetry data;

  TelemetryHistoryItem({required this.ingestTime, required this.data});

  static DateTime _toDate(dynamic v) {
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
    }
    if (v is String) {
      return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory TelemetryHistoryItem.fromJson(Map<String, dynamic> j) {
    return TelemetryHistoryItem(
      ingestTime: _toDate(j['ingest_time']),
      data: Telemetry.fromJson(j['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    "ingest_time": ingestTime.toIso8601String(),
    "data": data.toJson(),
  };
}
