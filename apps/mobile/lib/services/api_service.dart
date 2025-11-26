import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fountaine/domain/telemetry.dart';

class ApiService {
  final String baseUrl;
  final Duration timeout;

  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
  });

  // BASIC REQUEST
  Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    int retry = 1,
  }) async {
    final url = Uri.parse('$baseUrl$path');

    final finalHeaders = {'Content-Type': 'application/json', ...?headers};

    http.Response res;

    for (int attempt = 0; attempt <= retry; attempt++) {
      try {
        if (kDebugMode) {
          print('[API] $method $url (try ${attempt + 1})');
          if (body != null) print('[API] body: $body');
        }

        switch (method) {
          case 'POST':
            res = await http
                .post(url, headers: finalHeaders, body: jsonEncode(body))
                .timeout(timeout);
            break;
          case 'PUT':
            res = await http
                .put(url, headers: finalHeaders, body: jsonEncode(body))
                .timeout(timeout);
            break;
          case 'DELETE':
            res = await http
                .delete(url, headers: finalHeaders)
                .timeout(timeout);
            break;
          default:
            res = await http.get(url, headers: finalHeaders).timeout(timeout);
        }

        if (res.statusCode >= 200 && res.statusCode < 300) {
          return jsonDecode(res.body);
        }

        throw HttpException('HTTP ${res.statusCode}: ${res.body}', uri: url);
      } catch (e) {
        if (e is SocketException || e is TimeoutException) {
          if (attempt == retry) {
            throw Exception('Request timeout: $method $path');
          }
          continue;
        }

        debugPrint('API ERROR ($method $path): $e');
        rethrow;
      }
    }

    throw Exception('Unknown API error at $method $path');
  }

  // PUBLIC JSON CALLS
  Future<dynamic> getJson(String path) => _request(path, method: 'GET');

  Future<dynamic> postJson(String path, Map<String, dynamic> data) =>
      _request(path, method: 'POST', body: data);

  Future<dynamic> putJson(String path, Map<String, dynamic> data) =>
      _request(path, method: 'PUT', body: data);

  Future<dynamic> deleteJson(String path) => _request(path, method: 'DELETE');

  // TELEMETRY API

  /// GET LATEST TELEMETRY
  Future<Telemetry?> getLatestTelemetry(String deviceId) async {
    try {
      final res = await getJson('/telemetry/latest?deviceId=$deviceId');

      if (res['data'] != null) {
        final map = res['data'] as Map<String, dynamic>;
        return Telemetry.fromJson({...map, "ingestTime": res["ingestTime"]});
      }
      return null;
    } catch (e, s) {
      debugPrint('getLatestTelemetry error: $e\n$s');
      return null;
    }
  }

  /// GET TELEMETRY HISTORY
  Future<List<Telemetry>> getTelemetryHistory(
    String deviceId, {
    int limit = 50,
  }) async {
    try {
      final res = await getJson(
        '/telemetry/history?deviceId=$deviceId&limit=$limit',
      );

      if (res['items'] is! List) return [];

      final arr = res['items'] as List;

      return arr.map((item) {
        final map = item as Map<String, dynamic>;
        return Telemetry.fromJson({
          ...map['data'],
          "ingestTime": map["ingestTime"],
        });
      }).toList();
    } catch (e, s) {
      debugPrint('getTelemetryHistory error: $e\n$s');
      return [];
    }
  }
}
