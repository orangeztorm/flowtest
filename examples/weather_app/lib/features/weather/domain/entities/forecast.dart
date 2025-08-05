import 'package:freezed_annotation/freezed_annotation.dart';

part 'forecast.freezed.dart';

/// Forecast entity representing weather forecast data
/// Contains forecast information for multiple time periods
@freezed
class Forecast with _$Forecast {
  const factory Forecast({
    /// City name
    required String cityName,

    /// Country name
    required String country,

    /// List of forecast items
    required List<ForecastItem> items,
  }) = _Forecast;
}

/// Individual forecast item for a specific date and time
@freezed
class ForecastItem with _$ForecastItem {
  const factory ForecastItem({
    /// Forecast date and time as Unix timestamp
    required int dt,

    /// Main weather condition (e.g., "Rain", "Snow", "Clear")
    required String main,

    /// Weather description (e.g., "light rain", "clear sky")
    required String description,

    /// Weather icon code for display
    required String iconCode,

    /// Temperature in Celsius
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

    /// Wind speed in m/s
    required double windSpeed,

    /// Wind direction in degrees
    required int windDegree,

    /// Cloudiness percentage
    required int cloudiness,

    /// Probability of precipitation (0.0 to 1.0)
    required double pop,
  }) = _ForecastItem;

  const ForecastItem._();

  /// Get the complete weather icon URL
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  /// Get formatted temperature string
  String get temperatureString => '${temperature.round()}°C';

  /// Get formatted date string
  String get dateString {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }

  /// Get formatted time string
  String get timeString {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted precipitation probability string
  String get precipitationString => '${(pop * 100).round()}%';

  /// Check if it's daytime (6 AM to 6 PM)
  bool get isDaytime {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    final hour = dateTime.hour;
    return hour >= 6 && hour < 18;
  }
}
