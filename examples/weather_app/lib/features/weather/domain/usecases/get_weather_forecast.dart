import 'package:dartz/dartz.dart';
import 'package:wether_app/core/error/failures.dart';
import '../entities/forecast.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting weather forecast by city name
/// Follows the Single Responsibility Principle from Clean Architecture
class GetWeatherForecast {
  final WeatherRepository repository;

  const GetWeatherForecast(this.repository);

  /// Execute the use case to get weather forecast
  ///
  /// [cityName] - Name of the city to get forecast for
  /// Returns [Either<Failure, Forecast>] where:
  /// - Left side contains [Failure] if operation fails
  /// - Right side contains [Forecast] if operation succeeds
  Future<Either<Failure, Forecast>> call(String cityName) async {
    // Validate input
    if (cityName.trim().isEmpty) {
      return const Left(Failure.unknown(message: 'City name cannot be empty'));
    }

    // Delegate to repository
    return await repository.getWeatherForecast(cityName.trim());
  }
}
