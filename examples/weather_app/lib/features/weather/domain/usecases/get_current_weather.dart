import 'package:dartz/dartz.dart';
import 'package:wether_app/core/error/failures.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting current weather by city name
/// Follows the Single Responsibility Principle from Clean Architecture
class GetCurrentWeather {
  final WeatherRepository repository;

  const GetCurrentWeather(this.repository);

  /// Execute the use case to get current weather
  ///
  /// [cityName] - Name of the city to get weather for
  /// Returns [Either<Failure, Weather>] where:
  /// - Left side contains [Failure] if operation fails
  /// - Right side contains [Weather] if operation succeeds
  Future<Either<Failure, Weather>> call(String cityName) async {
    // Validate input
    if (cityName.trim().isEmpty) {
      return const Left(Failure.unknown(message: 'City name cannot be empty'));
    }

    // Delegate to repository
    return await repository.getCurrentWeather(cityName.trim());
  }
}
