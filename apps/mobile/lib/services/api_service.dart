import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ApiService versi lengkap dan aman.
/// Mendukung dynamic JSON (Map / List),
/// timeout, retry, logging, dan header custom.
class ApiService {
  final String baseUrl;
  final Duration timeout;

  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
  });

  /// ===========================
  ///   BASIC REQUEST HANDLER
  /// ===========================
  Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    int retry = 1,
  }) async {
    final url = Uri.parse('$baseUrl$path');

    // Default headers
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

        // Success Response
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final decoded = jsonDecode(res.body);
          return decoded; // Bisa Map ATAU List
        }

        // Server Error Response
        throw HttpException('HTTP ${res.statusCode}: ${res.body}', uri: url);
      }
      // Timeout
      catch (e) {
        if (e is SocketException || e is TimeoutException) {
          if (attempt == retry) {
            throw Exception('Request timeout: $method $path');
          }
          continue; // Retry
        }

        // Unexpected error
        debugPrint('API ERROR ($method $path): $e');
        rethrow;
      }
    }

    throw Exception('Unknown API error at $method $path');
  }

  /// ===========================
  ///   PUBLIC METHODS
  /// ===========================
  Future<dynamic> getJson(String path) async {
    return _request(path, method: 'GET');
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> data) async {
    return _request(path, method: 'POST', body: data);
  }

  Future<dynamic> putJson(String path, Map<String, dynamic> data) async {
    return _request(path, method: 'PUT', body: data);
  }

  Future<dynamic> deleteJson(String path) async {
    return _request(path, method: 'DELETE');
  }
}
