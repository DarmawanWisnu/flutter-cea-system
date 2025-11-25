import 'package:flutter/foundation.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'api_service.dart';

class ApiTelemetryService {
  final ApiService api;

  ApiTelemetryService({required this.api});

  // GET LATEST TELEMETRY
  Future<Telemetry?> getLatest(String deviceId) async {
    try {
      final res = await api.getJson('/telemetry/latest?device_id=$deviceId');

      if (res.containsKey('data') && res['data'] != null) {
        return Telemetry.fromJson(res['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e, s) {
      debugPrint('getLatest error: $e\n$s');
      return null;
    }
  }

  // GET TELEMETRY HISTORY
  Future<List<Telemetry>> getHistory(String deviceId, {int limit = 50}) async {
    try {
      final res = await api.getJson(
        '/telemetry/history?device_id=$deviceId&limit=$limit',
      );

      if (!res.containsKey('items')) return [];

      final arr = res['items'] as List;

      return arr
          .map(
            (e) => Telemetry.fromJson(
              (e as Map<String, dynamic>)['data'] as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e, s) {
      debugPrint('getHistory error: $e\n$s');
      return [];
    }
  }
}
