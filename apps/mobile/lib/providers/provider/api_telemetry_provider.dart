import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

/// LATEST TELEMETRY
final latestTelemetryProvider = FutureProvider.autoDispose
    .family<Telemetry?, String>((ref, kitId) async {
      final api = ref.watch(apiTelemetryProvider);
      return api.getLatest(kitId);
    });

/// HISTORY
final telemetryHistoryProvider = FutureProvider.autoDispose
    .family<List<Telemetry>, TelemetryHistoryRequest>((ref, req) async {
      final api = ref.watch(apiTelemetryProvider);
      return api.getHistory(req.kitId, limit: req.limit);
    });

/// REQ MODEL
class TelemetryHistoryRequest {
  final String kitId;
  final int limit;

  const TelemetryHistoryRequest({required this.kitId, this.limit = 50});
}
