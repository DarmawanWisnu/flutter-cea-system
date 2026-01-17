import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'location_provider.dart';

/// Effective weather type computed from weather code AND precipitation data.
/// This provides more accurate weather representation for tropical regions.
enum EffectiveWeatherType {
  clear,
  partlyCloudy,
  foggy,
  drizzle,
  rain,
  heavyRain,
  thunderstorm,
  snow,
}

/// Weather state containing temperature, weather code, and precipitation data
class WeatherState {
  final double temperature;
  final int weatherCode;
  final double rain;
  final double precipitation;
  final double showers;
  final EffectiveWeatherType effectiveWeather;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const WeatherState({
    required this.temperature,
    required this.weatherCode,
    this.rain = 0.0,
    this.precipitation = 0.0,
    this.showers = 0.0,
    this.effectiveWeather = EffectiveWeatherType.clear,
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
    double? rain,
    double? precipitation,
    double? showers,
    EffectiveWeatherType? effectiveWeather,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return WeatherState(
      temperature: temperature ?? this.temperature,
      weatherCode: weatherCode ?? this.weatherCode,
      rain: rain ?? this.rain,
      precipitation: precipitation ?? this.precipitation,
      showers: showers ?? this.showers,
      effectiveWeather: effectiveWeather ?? this.effectiveWeather,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if weather is rainy/stormy based on effective weather
  bool get isRainy =>
      effectiveWeather == EffectiveWeatherType.drizzle ||
      effectiveWeather == EffectiveWeatherType.rain ||
      effectiveWeather == EffectiveWeatherType.heavyRain ||
      effectiveWeather == EffectiveWeatherType.thunderstorm;

  /// Check if it's thunderstorm
  bool get isThunderstorm =>
      effectiveWeather == EffectiveWeatherType.thunderstorm;
}

/// Weather provider that fetches data from Open-Meteo API
class WeatherNotifier extends Notifier<WeatherState> {
  Timer? _autoRefreshTimer;

  @override
  WeatherState build() {
    _init();
    return WeatherState.initial();
  }

  Future<void> _init() async {
    // Wait a bit for location to be ready
    await Future.delayed(const Duration(milliseconds: 500));
    await fetchWeather();

    // Setup auto-refresh every 30 minutes (both location and weather)
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => refreshAll(),
    );
  }

  /// Refresh both location and weather
  Future<void> refreshAll() async {
    // First refresh location
    await ref.read(locationProvider.notifier).fetchLocation();
    // Then fetch weather with new location
    await fetchWeather();
  }

  /// Compute effective weather type from weather code and precipitation data.
  /// Weather codes indicating rain take priority, then precipitation amounts.
  EffectiveWeatherType _computeEffectiveWeather({
    required int weatherCode,
    required double rain,
    required double precipitation,
    required double showers,
  }) {
    // PRIORITAS 1: Weather code eksplisit hujan (HARUS diproses duluan!)
    // Thunderstorm (95-99) - highest priority
    if (weatherCode >= 95) return EffectiveWeatherType.thunderstorm;

    // Rain showers (80-82) - KRUSIAL untuk hujan konvektif tropis
    if (weatherCode >= 80 && weatherCode <= 82) {
      return EffectiveWeatherType.rain;
    }

    // Rain (61-65)
    if (weatherCode >= 61 && weatherCode <= 65) {
      return EffectiveWeatherType.rain;
    }

    // Drizzle (51-55)
    if (weatherCode >= 51 && weatherCode <= 55) {
      return EffectiveWeatherType.drizzle;
    }

    // PRIORITAS 2: Presipitasi aktual (untuk kasus weather code tidak update)
    // Total semua sumber presipitasi
    final totalPrecip = precipitation + rain + showers;

    // Heavy rain: >= 5.0 mm (threshold lebih rendah untuk tropis)
    if (totalPrecip >= 5.0) return EffectiveWeatherType.heavyRain;

    // Moderate rain: >= 1.0 mm
    if (totalPrecip >= 1.0) return EffectiveWeatherType.rain;

    // Light rain/drizzle: any measurable precipitation > 0
    if (totalPrecip > 0) return EffectiveWeatherType.drizzle;

    // PRIORITAS 3: Kondisi atmosfer lainnya
    // Snow (71-75)
    if (weatherCode >= 71 && weatherCode <= 75) {
      return EffectiveWeatherType.snow;
    }

    // Fog (45-48)
    if (weatherCode >= 45 && weatherCode <= 48) {
      return EffectiveWeatherType.foggy;
    }

    // Partly cloudy (1-3)
    if (weatherCode >= 1 && weatherCode <= 3) {
      return EffectiveWeatherType.partlyCloudy;
    }

    // Clear (0)
    return EffectiveWeatherType.clear;
  }

  /// Fetch weather from Open-Meteo API including precipitation data
  Future<void> fetchWeather() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final location = ref.read(locationProvider);

      // Enhanced API URL with precipitation parameters for real-time rain detection
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${location.latitude}'
        '&longitude=${location.longitude}'
        '&current=temperature_2m,weather_code,rain,precipitation,showers'
        '&timezone=auto',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];

        final weatherCode = current['weather_code'] as int;
        final rain = (current['rain'] as num?)?.toDouble() ?? 0.0;
        final precipitation =
            (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        final showers = (current['showers'] as num?)?.toDouble() ?? 0.0;

        final effectiveWeather = _computeEffectiveWeather(
          weatherCode: weatherCode,
          rain: rain,
          precipitation: precipitation,
          showers: showers,
        );

        state = WeatherState(
          temperature: (current['temperature_2m'] as num).toDouble(),
          weatherCode: weatherCode,
          rain: rain,
          precipitation: precipitation,
          showers: showers,
          effectiveWeather: effectiveWeather,
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

  /// Manual refresh weather data (called on tap)
  Future<void> refresh() async {
    await fetchWeather();
  }
}

/// Provider for weather state
final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);
