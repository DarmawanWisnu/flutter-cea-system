import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'location_provider.dart';

/// Weather state containing temperature and weather code
class WeatherState {
  final double temperature;
  final int weatherCode;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const WeatherState({
    required this.temperature,
    required this.weatherCode,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  factory WeatherState.initial() {
    return const WeatherState(
      temperature: 0,
      weatherCode: 0,
      isLoading: true,
    );
  }

  WeatherState copyWith({
    double? temperature,
    int? weatherCode,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return WeatherState(
      temperature: temperature ?? this.temperature,
      weatherCode: weatherCode ?? this.weatherCode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get weather description from WMO weather code
  String get description {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  /// Get appropriate icon based on weather code
  String get iconAsset {
    if (weatherCode == 0) return 'clear';
    if (weatherCode <= 3) return 'cloudy';
    if (weatherCode <= 48) return 'foggy';
    if (weatherCode <= 55) return 'drizzle';
    if (weatherCode <= 65) return 'rain';
    if (weatherCode <= 75) return 'snow';
    if (weatherCode <= 82) return 'rain';
    return 'thunder';
  }

  /// Check if it's currently raining
  bool get isRaining => weatherCode >= 51 && weatherCode <= 82;
}

/// Weather provider that fetches data from Open-Meteo API
class WeatherNotifier extends Notifier<WeatherState> {
  @override
  WeatherState build() {
    _init();
    return WeatherState.initial();
  }

  Future<void> _init() async {
    // Wait a bit for location to be ready
    await Future.delayed(const Duration(milliseconds: 500));
    await fetchWeather();
  }

  /// Fetch weather from Open-Meteo API
  Future<void> fetchWeather() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final location = ref.read(locationProvider);
      
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${location.latitude}'
        '&longitude=${location.longitude}'
        '&current_weather=true',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];
        
        state = WeatherState(
          temperature: (current['temperature'] as num).toDouble(),
          weatherCode: current['weathercode'] as int,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch weather: ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh weather data
  Future<void> refresh() async {
    await fetchWeather();
  }
}

/// Provider for weather state
final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);
