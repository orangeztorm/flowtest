import 'package:dartz/dartz.dart';
import 'package:wether_app/core/error/failures.dart';
import '../entities/weather.dart';
import '../entities/forecast.dart';

/// Weather repository interface
/// Defines the contract for weather data operations
/// Follows the Repository pattern from Clean Architecture
abstract class WeatherRepository {
  /// Get current weather for a specific city
  ///
  /// Returns [Weather] object on success
  /// Returns [Failure] on error
  ///
  /// [cityName] - Name of the city to get weather for
  Future<Either<Failure, Weather>> getCurrentWeather(String cityName);

  /// Get weather forecast for a specific city
  ///
  /// Returns [Forecast] object containing forecast items on success
  /// Returns [Failure] on error
  ///
  /// [cityName] - Name of the city to get forecast for
  Future<Either<Failure, Forecast>> getWeatherForecast(String cityName);

  /// Get current weather for specific coordinates
  ///
  /// Returns [Weather] object on success
  /// Returns [Failure] on error
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double latitude,
    double longitude,
  );

  /// Get weather forecast for specific coordinates
  ///
  /// Returns [Forecast] object containing forecast items on success
  /// Returns [Failure] on error
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  Future<Either<Failure, Forecast>> getForecastByCoordinates(
    double latitude,
    double longitude,
  );
}
