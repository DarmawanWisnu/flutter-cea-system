import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences instance provider
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Key for storing custom API URL
const String _apiUrlKey = 'custom_api_url';

/// Default API URL from .env
String get _defaultApiUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

/// Provider for custom API URL (from SharedPreferences)
/// Returns the saved URL or falls back to .env default
final customApiUrlProvider = StateNotifierProvider<CustomApiUrlNotifier, String>((ref) {
  return CustomApiUrlNotifier(ref);
});

class CustomApiUrlNotifier extends StateNotifier<String> {
  final Ref _ref;
  SharedPreferences? _prefs;

  CustomApiUrlNotifier(this._ref) : super(_defaultApiUrl) {
    _loadFromPrefs();
  }

  /// Load saved URL from SharedPreferences
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedUrl = _prefs?.getString(_apiUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      state = savedUrl;
    }
  }

  /// Set a new API URL and save to SharedPreferences
  Future<void> setUrl(String url) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_apiUrlKey, url);
    state = url;
  }

  /// Reset to default URL from .env
  Future<void> resetToDefault() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_apiUrlKey);
    state = _defaultApiUrl;
  }

  /// Get current default URL (for display)
  String get defaultUrl => _defaultApiUrl;

  /// Check if using custom URL
  bool get isCustomUrl => state != _defaultApiUrl;
}
