import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:fountaine/models/kit.dart';
import 'package:fountaine/providers/provider/url_settings_provider.dart';

/// BASE URL BACKEND (now uses dynamic URL from SharedPreferences)
final apiBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(customApiUrlProvider);
});

/// API SERVICE (HTTP CLIENT)
final apiServiceProvider = Provider<ApiService>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return ApiService(baseUrl: baseUrl);
});

/// TELEMETRY API SERVICE
final apiTelemetryProvider = Provider.autoDispose<ApiService>((ref) {
  return ref.watch(apiServiceProvider);
});

/// GET LATEST
final latestTelemetryProvider = FutureProvider.autoDispose
    .family<Telemetry?, String>((ref, deviceId) async {
      final api = ref.watch(apiTelemetryProvider);
      return api.getLatestTelemetry(deviceId);
    });

/// GET HISTORY
final telemetryHistoryProvider = FutureProvider.autoDispose
    .family<List<Telemetry>, TelemetryHistoryRequest>((ref, req) async {
      final api = ref.watch(apiTelemetryProvider);
      return api.getTelemetryHistory(req.deviceId, limit: req.limit);
    });

/// REQUEST MODEL
class TelemetryHistoryRequest {
  final String deviceId;
  final int limit;

  const TelemetryHistoryRequest({required this.deviceId, this.limit = 50});
}

/// KITS API SERVICE
final apiKitsProvider = Provider<ApiKitsService>((ref) {
  final api = ref.read(apiServiceProvider);
  return ApiKitsService(api);
});

class ApiKitsService {
  final ApiService _api;

  ApiKitsService(this._api);

  /// GET all kits (returns List<Kit>)
  Future<List<Kit>> getKits() async {
    final res = await _api.getJson("/kits");
    final list = (res as List).cast<Map<String, dynamic>>();

    return list.map((e) => Kit.fromJson(e)).toList();
  }

  /// ADD KIT
  Future<void> addKit({required String id, required String name}) async {
    await _api.postJson("/kits", {"id": id, "name": name});
  }

  /// DELETE KIT
  Future<void> deleteKit(String id) async {
    await _api.deleteJson("/kits/$id");
  }
}

/// RAW KIT LIST
final apiKitsListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final api = ref.read(apiServiceProvider);
      final res = await api.getJson("/kits");

      return (res as List).cast<Map<String, dynamic>>();
    });

/// CURRENT KIT ID (shared between monitor and notifications)
final currentKitIdProvider = StateProvider<String?>((ref) => null);
