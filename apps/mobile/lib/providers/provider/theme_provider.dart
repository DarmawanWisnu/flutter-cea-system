import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeKey = 'app_theme_mode';

/// Provider for app theme mode with SharedPreferences persistence
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  SharedPreferences? _prefs;

  ThemeNotifier() : super(ThemeMode.system) {
    _loadFromPrefs();
  }

  /// Load saved theme from SharedPreferences
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs?.getString(_themeKey);
    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// Set a new theme mode and save to SharedPreferences
  Future<void> setTheme(ThemeMode mode) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_themeKey, mode.name);
    state = mode;
  }

  /// Check if current theme matches
  bool isCurrentTheme(ThemeMode mode) => state == mode;
}
