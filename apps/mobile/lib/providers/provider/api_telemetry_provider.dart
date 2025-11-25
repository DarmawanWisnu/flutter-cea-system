import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/domain/telemetry.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

/// STATE: latest telemetry (UI monitor)
final latestTelemetryProvider = FutureProvider.family<Telemetry?, String>((
  ref,
  kitId,
) async {
  final api = ref.watch(apiTelemetryProvider);
  return api.getLatest(kitId);
});

/// STATE: history telemetry (UI grafik)
final telemetryHistoryProvider =
    FutureProvider.family<List<Telemetry>, TelemetryHistoryRequest>((
      ref,
      req,
    ) async {
      final api = ref.watch(apiTelemetryProvider);
      return api.getHistory(req.kitId, limit: req.limit);
    });

/// Request model untuk history
class TelemetryHistoryRequest {
  final String kitId;
  final int limit;

  const TelemetryHistoryRequest({required this.kitId, this.limit = 50});
}
