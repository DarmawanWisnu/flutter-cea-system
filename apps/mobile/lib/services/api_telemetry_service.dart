import 'package:flutter/foundation.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'api_service.dart';

class ApiTelemetryService {
  final ApiService api;

  ApiTelemetryService({required this.api});

  // GET LATEST
  Future<Telemetry?> getLatest(String deviceId) async {
    try {
      final res = await api.getJson('/telemetry/latest?device_id=$deviceId');

      if (res['data'] != null) {
        final map = res['data'] as Map<String, dynamic>;

        return Telemetry.fromJson({...map, "ingestTime": res["ingest_time"]});
      }
      return null;
    } catch (e, s) {
      debugPrint('getLatest error: $e\n$s');
      return null;
    }
  }

  // GET HISTORY
  Future<List<Telemetry>> getHistory(String deviceId, {int limit = 50}) async {
    try {
      final res = await api.getJson(
        '/telemetry/history?device_id=$deviceId&limit=$limit',
      );

      if (res['items'] is! List) return [];

      final arr = res['items'] as List;

      return arr.map((e) {
        final map = e as Map<String, dynamic>;

        return Telemetry.fromJson({
          ...map['data'] as Map<String, dynamic>,
          "ingestTime": map["ingest_time"],
        });
      }).toList();
    } catch (e, s) {
      debugPrint('getHistory error: $e\n$s');
      return [];
    }
  }
}
