import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';

/// Weather entity representing current weather conditions
/// This is the domain model used throughout the application
@freezed
class Weather with _$Weather {
  const factory Weather({
    /// City name
    required String cityName,

    /// Country name
    required String country,

    /// Main weather condition (e.g., "Rain", "Snow", "Clear")
    required String main,

    /// Weather description (e.g., "light rain", "clear sky")
    required String description,

    /// Weather icon code for display
    required String iconCode,

    /// Current temperature in Celsius
    required double temperature,

    /// Feels like temperature in Celsius
    required double feelsLike,

    /// Minimum temperature in Celsius
    required double tempMin,

    /// Maximum temperature in Celsius
    required double tempMax,

    /// Atmospheric pressure in hPa
    required int pressure,

    /// Humidity percentage
    required int humidity,

    /// Visibility in meters
    required int visibility,

    /// Wind speed in m/s
    required double windSpeed,

    /// Wind direction in degrees
    required int windDegree,

    /// Cloudiness percentage
    required int cloudiness,

    /// Sunrise time as Unix timestamp
    required int sunrise,

    /// Sunset time as Unix timestamp
    required int sunset,

    /// Data calculation time as Unix timestamp
    required int dt,
  }) = _Weather;

  const Weather._();

  /// Get the complete weather icon URL
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  /// Get formatted temperature string
  String get temperatureString => '${temperature.round()}°C';

  /// Get formatted feels like temperature string
  String get feelsLikeString => 'Feels like ${feelsLike.round()}°C';

  /// Get formatted humidity string
  String get humidityString => '$humidity%';

  /// Get formatted pressure string
  String get pressureString => '${pressure} hPa';

  /// Get formatted wind speed string
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} m/s';

  /// Get formatted visibility string
  String get visibilityString => '${(visibility / 1000).toStringAsFixed(1)} km';

  /// Get wind direction as cardinal direction
  String get windDirection {
    if (windDegree >= 337.5 || windDegree < 22.5) return 'N';
    if (windDegree >= 22.5 && windDegree < 67.5) return 'NE';
    if (windDegree >= 67.5 && windDegree < 112.5) return 'E';
    if (windDegree >= 112.5 && windDegree < 157.5) return 'SE';
    if (windDegree >= 157.5 && windDegree < 202.5) return 'S';
    if (windDegree >= 202.5 && windDegree < 247.5) return 'SW';
    if (windDegree >= 247.5 && windDegree < 292.5) return 'W';
    if (windDegree >= 292.5 && windDegree < 337.5) return 'NW';
    return 'N';
  }

  /// Get formatted sunrise time
  String get sunriseTime {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      sunrise * 1000,
    );
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted sunset time
  String get sunsetTime {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      sunset * 1000,
    );
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
