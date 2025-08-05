import 'package:get_it/get_it.dart';
import '../network/network_client.dart';
import '../../features/weather/data/datasources/weather_remote_datasource.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/domain/usecases/get_current_weather.dart';
import '../../features/weather/domain/usecases/get_weather_forecast.dart';
import '../../features/weather/domain/usecases/get_weather_by_location.dart';

/// Service locator for dependency injection
/// Uses GetIt to manage application dependencies
final sl = GetIt.instance;

/// Initialize all dependencies
/// Must be called before runApp() in main.dart
Future<void> initializeDependencies() async {
  // Register network client
  sl.registerLazySingleton(() => NetworkClient.dio);

  // Register data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(sl()),
  );

  // Register repositories
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(sl()),
  );

  // Register use cases
  sl.registerLazySingleton(() => GetCurrentWeather(sl()));
  sl.registerLazySingleton(() => GetWeatherForecast(sl()));
  sl.registerLazySingleton(() => GetWeatherByLocation(sl()));
}
