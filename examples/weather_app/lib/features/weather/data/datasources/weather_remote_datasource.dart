import 'package:dio/dio.dart';
import 'package:wether_app/core/constants/api_constants.dart';
import 'package:wether_app/core/error/exceptions.dart';

import '../models/weather_model.dart';
import '../models/forecast_model.dart';

/// Abstract class for weather remote data source
/// Defines the contract for remote weather data operations
abstract class WeatherRemoteDataSource {
  /// Get current weather by city name from API
  Future<WeatherModel> getCurrentWeather(String cityName);

  /// Get weather forecast by city name from API
  Future<ForecastModel> getWeatherForecast(String cityName);

  /// Get current weather by coordinates from API
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon);

  /// Get weather forecast by coordinates from API
  Future<ForecastModel> getForecastByCoordinates(double lat, double lon);
}

/// Implementation of weather remote data source
/// Handles API calls and error handling
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;

  const WeatherRemoteDataSourceImpl(this.dio);

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      final response = await dio.get(
        ApiConstants.currentWeather,
        queryParameters: {
          'q': cityName,
          'appid': ApiConstants.apiKey,
          'units': ApiConstants.units,
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get weather data');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException('Failed to get weather: ${e.toString()}');
    }
  }

  @override
  Future<ForecastModel> getWeatherForecast(String cityName) async {
    try {
      final response = await dio.get(
        ApiConstants.forecast,
        queryParameters: {
          'q': cityName,
          'appid': ApiConstants.apiKey,
          'units': ApiConstants.units,
        },
      );

      if (response.statusCode == 200) {
        return ForecastModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get forecast data');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException('Failed to get forecast: ${e.toString()}');
    }
  }

  @override
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await dio.get(
        ApiConstants.currentWeather,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': ApiConstants.apiKey,
          'units': ApiConstants.units,
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get weather data by coordinates');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        'Failed to get weather by coordinates: ${e.toString()}',
      );
    }
  }

  @override
  Future<ForecastModel> getForecastByCoordinates(double lat, double lon) async {
    try {
      final response = await dio.get(
        ApiConstants.forecast,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': ApiConstants.apiKey,
          'units': ApiConstants.units,
        },
      );

      if (response.statusCode == 200) {
        return ForecastModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get forecast data by coordinates');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        'Failed to get forecast by coordinates: ${e.toString()}',
      );
    }
  }

  /// Handle Dio exceptions and convert to custom exceptions
  WeatherException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Request timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ?? 'Unknown server error';

        switch (statusCode) {
          case 401:
            return InvalidApiKeyException('Invalid API key: $message');
          case 404:
            return LocationNotFoundException('Location not found: $message');
          case 429:
            return const ServerException(
              'Too many requests. Please try again later.',
            );
          case 500:
          case 502:
          case 503:
            return ServerException('Server error: $message');
          default:
            return ServerException('HTTP $statusCode: $message');
        }

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network settings.',
        );

      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('Certificate verification failed.');

      case DioExceptionType.unknown:
        return const UnknownException(
          'Unknown error occurred. Please try again.',
        );
    }
  }
}
