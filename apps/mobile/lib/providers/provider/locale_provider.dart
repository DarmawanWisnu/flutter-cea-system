import 'dart:ui';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';
const Locale _defaultLocale = Locale('en');

/// Provider for app locale with SharedPreferences persistence
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  SharedPreferences? _prefs;

  LocaleNotifier() : super(_defaultLocale) {
    _loadFromPrefs();
  }

  /// Supported locales for the app
  static const supportedLocales = [Locale('en'), Locale('id')];

  /// Load saved locale from SharedPreferences
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLocale = _prefs?.getString(_localeKey);
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  /// Set a new locale and save to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_localeKey, locale.languageCode);
    state = locale;
  }

  /// Check if current locale matches
  bool isCurrentLocale(Locale locale) =>
      state.languageCode == locale.languageCode;
}
