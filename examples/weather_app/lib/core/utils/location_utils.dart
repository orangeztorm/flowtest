import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import '../error/exceptions.dart';

/// Utility class for location-related operations
/// Handles location permissions, GPS access, and geocoding
class LocationUtils {
  /// Get the current location of the device
  /// Returns a [Position] object with latitude and longitude
  ///
  /// Throws [LocationServiceDisabledException] if location services are disabled
  /// Throws [LocationPermissionDeniedException] if location permission is denied
  static Future<geo.Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException(
        'Location services are disabled. Please enable location services in settings.',
      );
    }

    // Check location permissions
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        throw const LocationPermissionDeniedException(
          'Location permission denied. Please allow location access in settings.',
        );
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException(
        'Location permissions are permanently denied. Please enable location access in device settings.',
      );
    }

    try {
      // Get current position with high accuracy
      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw NetworkException('Failed to get current location: ${e.toString()}');
    }
  }

  /// Get the city name from latitude and longitude coordinates
  /// Returns the city name as a string
  ///
  /// Throws [LocationNotFoundException] if no location is found for the coordinates
  /// Throws [NetworkException] if there's a network error during geocoding
  static Future<String> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Return the locality (city) or administrative area if locality is null
        return placemark.locality ??
            placemark.administrativeArea ??
            placemark.subAdministrativeArea ??
            'Unknown Location';
      } else {
        throw const LocationNotFoundException(
          'No location found for the given coordinates',
        );
      }
    } catch (e) {
      if (e is LocationNotFoundException) {
        rethrow;
      }
      throw NetworkException(
        'Failed to get city from coordinates: ${e.toString()}',
      );
    }
  }

  /// Get coordinates (latitude, longitude) from a city name
  /// Returns a [Location] object with latitude and longitude
  ///
  /// Throws [LocationNotFoundException] if the city is not found
  /// Throws [NetworkException] if there's a network error during geocoding
  static Future<Location> getCoordinatesFromCity(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);

      if (locations.isNotEmpty) {
        return locations.first;
      } else {
        throw LocationNotFoundException(
          'No coordinates found for city: $cityName',
        );
      }
    } catch (e) {
      if (e is LocationNotFoundException) {
        rethrow;
      }
      throw NetworkException(
        'Failed to get coordinates from city: ${e.toString()}',
      );
    }
  }

  /// Calculate the distance between two coordinates in kilometers
  /// Uses the Haversine formula for accurate distance calculation
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return geo.Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Check if location services are enabled on the device
  static Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  /// Check the current location permission status
  static Future<geo.LocationPermission> checkPermission() async {
    return await geo.Geolocator.checkPermission();
  }

  /// Request location permission from the user
  static Future<geo.LocationPermission> requestPermission() async {
    return await geo.Geolocator.requestPermission();
  }
}
