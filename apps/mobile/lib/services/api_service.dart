import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // GET
  Future<Map<String, dynamic>> getJson(String path) async {
    final url = Uri.parse('$baseUrl$path');

    try {
      final r = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (r.statusCode >= 200 && r.statusCode < 300) {
        return jsonDecode(r.body) as Map<String, dynamic>;
      } else {
        throw Exception('GET $path failed (${r.statusCode}): ${r.body}');
      }
    } catch (e, s) {
      debugPrint('API GET error @ $path: $e\n$s');
      rethrow;
    }
  }

  // POST
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$path');

    try {
      final r = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (r.statusCode >= 200 && r.statusCode < 300) {
        return jsonDecode(r.body) as Map<String, dynamic>;
      } else {
        throw Exception('POST $path failed (${r.statusCode}): ${r.body}');
      }
    } catch (e, s) {
      debugPrint('API POST error @ $path: $e\n$s');
      rethrow;
    }
  }
}
