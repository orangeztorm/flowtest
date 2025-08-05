import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wether_app/core/dependency_injection/injection_container.dart';
import 'package:wether_app/core/error/failures.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_weather_forecast.dart';
import '../../domain/usecases/get_weather_by_location.dart';

/// Weather state for managing weather data and UI state
class WeatherState {
  final Weather? currentWeather;
  final Forecast? forecast;
  final bool isLoading;
  final String? error;
  final bool isLocationLoading;
  final String? locationError;

  const WeatherState({
    this.currentWeather,
    this.forecast,
    this.isLoading = false,
    this.error,
    this.isLocationLoading = false,
    this.locationError,
  });

  /// Copy with method for immutable updates
  WeatherState copyWith({
    Weather? currentWeather,
    Forecast? forecast,
    bool? isLoading,
    String? error,
    bool? isLocationLoading,
    String? locationError,
    bool clearWeather = false,
    bool clearForecast = false,
    bool clearError = false,
    bool clearLocationError = false,
  }) {
    return WeatherState(
      currentWeather: clearWeather
          ? null
          : currentWeather ?? this.currentWeather,
      forecast: clearForecast ? null : forecast ?? this.forecast,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      locationError: clearLocationError
          ? null
          : locationError ?? this.locationError,
    );
  }
}

/// Weather notifier for managing weather state
class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetCurrentWeather _getCurrentWeather;
  final GetWeatherForecast _getWeatherForecast;
  final GetWeatherByLocation _getWeatherByLocation;

  WeatherNotifier(
    this._getCurrentWeather,
    this._getWeatherForecast,
    this._getWeatherByLocation,
  ) : super(const WeatherState());

  /// Get current weather for a city
  Future<void> getCurrentWeather(String cityName) async {
    // Clear previous error and set loading
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getCurrentWeather(cityName);

    result.fold(
      (failure) {
        print(
          'Error in getCurrentWeather: ${failure.userMessage}',
        ); // Debug log
        state = state.copyWith(isLoading: false, error: failure.userMessage);
      },
      (weather) {
        state = state.copyWith(
          isLoading: false,
          currentWeather: weather,
          clearError: true,
        );
      },
    );
  }

  /// Get weather forecast for a city
  Future<void> getWeatherForecast(String cityName) async {
    // Don't show loading for forecast if we already have current weather
    if (state.currentWeather == null) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    final result = await _getWeatherForecast(cityName);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.userMessage);
      },
      (forecast) {
        state = state.copyWith(
          isLoading: false,
          forecast: forecast,
          clearError: true,
        );
      },
    );
  }

  /// Get weather for user's current location
  Future<void> getWeatherByLocation() async {
    state = state.copyWith(isLocationLoading: true, clearLocationError: true);

    final result = await _getWeatherByLocation();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLocationLoading: false,
          locationError: failure.userMessage,
        );
      },
      (weather) {
        state = state.copyWith(
          isLocationLoading: false,
          currentWeather: weather,
          clearLocationError: true,
        );

        // Also get forecast for the same location
        getWeatherForecast(weather.cityName);
      },
    );
  }

  /// Refresh current weather data
  Future<void> refreshWeather() async {
    if (state.currentWeather != null) {
      await getCurrentWeather(state.currentWeather!.cityName);
      await getWeatherForecast(state.currentWeather!.cityName);
    }
  }

  /// Clear all weather data
  void clearWeatherData() {
    state = const WeatherState();
  }
}

/// Provider for weather notifier
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>(
  (ref) => WeatherNotifier(
    sl<GetCurrentWeather>(),
    sl<GetWeatherForecast>(),
    sl<GetWeatherByLocation>(),
  ),
);

/// Provider for current weather
final currentWeatherProvider = Provider<Weather?>((ref) {
  return ref.watch(weatherProvider).currentWeather;
});

/// Provider for weather forecast
final forecastProvider = Provider<Forecast?>((ref) {
  return ref.watch(weatherProvider).forecast;
});

/// Provider for weather loading state
final weatherLoadingProvider = Provider<bool>((ref) {
  return ref.watch(weatherProvider).isLoading;
});

/// Provider for weather error
final weatherErrorProvider = Provider<String?>((ref) {
  return ref.watch(weatherProvider).error;
});

/// Provider for location loading state
final locationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(weatherProvider).isLocationLoading;
});

/// Provider for location error
final locationErrorProvider = Provider<String?>((ref) {
  return ref.watch(weatherProvider).locationError;
});

/// Provider for search history (simple implementation)
final searchHistoryProvider = StateProvider<List<String>>((ref) => []);

/// Add city to search history
void addToSearchHistory(WidgetRef ref, String cityName) {
  final history = ref.read(searchHistoryProvider);
  final updatedHistory =
      [cityName, ...history.where((city) => city != cityName)]
          .take(5) // Keep only last 5 searches
          .toList();
  ref.read(searchHistoryProvider.notifier).state = updatedHistory;
}
