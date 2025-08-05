import 'package:dartz/dartz.dart';
import 'package:wether_app/core/error/failures.dart';
import 'package:wether_app/core/utils/location_utils.dart';

import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting weather by user's current location
/// Handles location permission and GPS access
class GetWeatherByLocation {
  final WeatherRepository repository;

  const GetWeatherByLocation(this.repository);

  /// Execute the use case to get weather for current location
  ///
  /// Returns [Either<Failure, Weather>] where:
  /// - Left side contains [Failure] if operation fails (location or network error)
  /// - Right side contains [Weather] if operation succeeds
  Future<Either<Failure, Weather>> call() async {
    try {
      // Get current location
      final position = await LocationUtils.getCurrentLocation();

      // Get weather for current coordinates
      return await repository.getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // Handle location-related errors
      if (e.toString().contains('Location services are disabled')) {
        return const Left(Failure.locationServiceDisabled());
      } else if (e.toString().contains('Location permission denied')) {
        return const Left(Failure.locationPermissionDenied());
      } else {
        return Left(Failure.unknown(message: e.toString()));
      }
    }
  }
}
