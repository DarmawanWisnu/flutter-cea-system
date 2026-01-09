import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Location state containing coordinates and city name
class LocationState {
  final double latitude;
  final double longitude;
  final String cityName;
  final bool isLoading;
  final String? error;

  const LocationState({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.isLoading = false,
    this.error,
  });

  /// Default location: Tangerang, Banten
  factory LocationState.defaultLocation() {
    return const LocationState(
      latitude: -6.1781,
      longitude: 106.6319,
      cityName: 'Tangerang, Banten',
    );
  }

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Location provider that handles GPS location and reverse geocoding
class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    _init();
    return LocationState.defaultLocation();
  }

  Future<void> _init() async {
    await fetchLocation();
  }

  /// Fetch current location from GPS
  Future<void> fetchLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services disabled',
        );
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Location permission denied',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission permanently denied',
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocode to get city name
      String cityName = 'Unknown Location';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.subAdministrativeArea ?? place.locality ?? '';
          final area = place.administrativeArea ?? '';
          cityName = '$city, $area'.trim();
          if (cityName.startsWith(',')) cityName = cityName.substring(1).trim();
          if (cityName.endsWith(',')) cityName = cityName.substring(0, cityName.length - 1).trim();
          if (cityName.isEmpty) cityName = 'Unknown Location';
        }
      } catch (_) {
        // Geocoding failed, use default name
      }

      state = LocationState(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider for location state
final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);
