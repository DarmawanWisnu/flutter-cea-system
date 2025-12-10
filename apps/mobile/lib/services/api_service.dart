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

    final finalHeaders = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',  // Skip ngrok interstitial page
      ...?headers,
    };

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

  /// GET LATEST ACTUATOR EVENT
  Future<Map<String, dynamic>?> getLatestActuatorEvent(String deviceId) async {
    try {
      final res = await getJson('/actuator/latest?deviceId=$deviceId');
      
      if (res is Map<String, dynamic> && res.containsKey('id')) {
        return res;
      }
      return null;
    } catch (e) {
      debugPrint('getLatestActuatorEvent error: $e');
      return null;
    }
  }

  // DEVICE MODE API

  /// SET device mode (auto/manual) for a user's device
  Future<bool> setDeviceMode({
    required String userId,
    required String deviceId,
    required bool autoMode,
  }) async {
    try {
      final res = await postJson('/device/mode', {
        'userId': userId,
        'deviceId': deviceId,
        'autoMode': autoMode,
      });
      return res['status'] == 'ok';
    } catch (e) {
      debugPrint('setDeviceMode error: $e');
      return false;
    }
  }

  /// GET device mode (auto/manual) for a user's device
  Future<bool> getDeviceMode({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final res = await getJson(
        '/device/mode?userId=$userId&deviceId=$deviceId',
      );
      return res['autoMode'] == true;
    } catch (e) {
      debugPrint('getDeviceMode error: $e');
      return false; // Default to manual
    }
  }

  // USER PREFERENCE API

  /// SET user's selected kit preference
  Future<bool> setUserPreference({
    required String userId,
    required String selectedKitId,
  }) async {
    try {
      final res = await postJson('/user/preference', {
        'userId': userId,
        'selectedKitId': selectedKitId,
      });
      return res['status'] == 'ok';
    } catch (e) {
      debugPrint('setUserPreference error: $e');
      return false;
    }
  }

  /// GET user's selected kit preference
  Future<String?> getUserPreference({required String userId}) async {
    try {
      final res = await getJson('/user/preference?userId=$userId');
      return res['selectedKitId'] as String?;
    } catch (e) {
      debugPrint('getUserPreference error: $e');
      return null;
    }
  }

  // NOTIFICATION API

  /// GET notifications with optional filters
  Future<List<Map<String, dynamic>>> getNotifications({
    required String userId,
    String? level,
    int days = 7,
    int limit = 100,
  }) async {
    try {
      String url = '/notifications?userId=$userId&days=$days&limit=$limit';
      if (level != null && level.isNotEmpty && level != 'all') {
        url += '&level=$level';
      }
      final res = await getJson(url);
      final items = res['items'] as List? ?? [];
      return items.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('getNotifications error: $e');
      return [];
    }
  }

  /// MARK notification as read
  Future<bool> markNotificationRead(int id) async {
    try {
      final res = await putJson('/notifications/$id/read', {});
      return res['status'] == 'ok';
    } catch (e) {
      debugPrint('markNotificationRead error: $e');
      return false;
    }
  }

  /// MARK ALL notifications as read
  Future<bool> markAllNotificationsRead(String userId) async {
    try {
      final res = await putJson('/notifications/mark-all-read?userId=$userId', {});
      return res['status'] == 'ok';
    } catch (e) {
      debugPrint('markAllNotificationsRead error: $e');
      return false;
    }
  }

  /// DELETE a single notification
  Future<bool> deleteNotification(int id) async {
    try {
      final res = await deleteJson('/notifications/$id');
      return res['status'] == 'ok';
    } catch (e) {
      debugPrint('deleteNotification error: $e');
      return false;
    }
  }

  /// CLEAR ALL notifications for user
  Future<bool> clearAllNotifications(String userId) async {
    try {
      final res = await deleteJson('/notifications?userId=$userId');
      return res['status'] == 'ok';
    } catch (e) {
      debugPrint('clearAllNotifications error: $e');
      return false;
    }
  }
}
