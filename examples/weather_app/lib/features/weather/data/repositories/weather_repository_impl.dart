import 'package:dartz/dartz.dart';
import 'package:wether_app/core/error/exceptions.dart';
import 'package:wether_app/core/error/failures.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

/// Implementation of WeatherRepository
/// Handles data operations and error conversion
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  const WeatherRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Weather>> getCurrentWeather(String cityName) async {
    try {
      final weatherModel = await remoteDataSource.getCurrentWeather(cityName);
      return Right(weatherModel.toEntity());
    } on WeatherException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Forecast>> getWeatherForecast(String cityName) async {
    try {
      final forecastModel = await remoteDataSource.getWeatherForecast(cityName);
      return Right(forecastModel.toEntity());
    } on WeatherException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Weather>> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final weatherModel = await remoteDataSource.getWeatherByCoordinates(
        latitude,
        longitude,
      );
      return Right(weatherModel.toEntity());
    } on WeatherException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Forecast>> getForecastByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final forecastModel = await remoteDataSource.getForecastByCoordinates(
        latitude,
        longitude,
      );
      return Right(forecastModel.toEntity());
    } on WeatherException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  /// Map exceptions to failures
  Failure _mapExceptionToFailure(WeatherException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return Failure.network(message: exception.message);
      case TimeoutException:
        return Failure.network(message: exception.message);
      case ServerException:
        return Failure.server(message: exception.message);
      case InvalidApiKeyException:
        return Failure.invalidApiKey(message: exception.message);
      case LocationNotFoundException:
        return Failure.locationNotFound(message: exception.message);
      case LocationServiceDisabledException:
        return Failure.locationServiceDisabled(message: exception.message);
      case LocationPermissionDeniedException:
        return Failure.locationPermissionDenied(message: exception.message);
      case ParseException:
        return Failure.parse(message: exception.message);
      case CacheException:
        return Failure.cache(message: exception.message);
      default:
        return Failure.unknown(message: exception.message);
    }
  }
}
