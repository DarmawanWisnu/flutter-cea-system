import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fountaine/services/api_service.dart';
import 'package:fountaine/services/api_telemetry_service.dart';

/// BASE URL BACKEND
final apiBaseUrlProvider = Provider.autoDispose<String>((ref) {
  return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
});

/// API SERVICE (HTTP CLIENT)
final apiServiceProvider = Provider.autoDispose<ApiService>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return ApiService(baseUrl: baseUrl);
});

/// TELEMETRY API SERVICE
final apiTelemetryProvider = Provider.autoDispose<ApiTelemetryService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ApiTelemetryService(api: api);
});
