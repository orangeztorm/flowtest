/// Application constants for the weather app
/// Contains UI constants, dimensions, and other app-specific values
class AppConstants {
  /// App name
  static const String appName = 'Weather App';

  /// Default city for weather data
  static const String defaultCity = 'London';

  /// Default country for weather data
  static const String defaultCountry = 'UK';

  /// Maximum number of forecast days to display
  static const int maxForecastDays = 5;

  /// Refresh interval for weather data in minutes
  static const int refreshIntervalMinutes = 30;

  /// Location permission denied message
  static const String locationPermissionDenied =
      'Location permission denied. Please enable location access in settings.';

  /// Location service disabled message
  static const String locationServiceDisabled =
      'Location services are disabled. Please enable location services.';

  /// Network error message
  static const String networkError =
      'Network error. Please check your internet connection.';

  /// Server error message
  static const String serverError = 'Server error. Please try again later.';

  /// Unknown error message
  static const String unknownError =
      'An unknown error occurred. Please try again.';

  /// Default animation duration in milliseconds
  static const int animationDuration = 300;

  /// Default border radius
  static const double borderRadius = 16.0;

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Small padding
  static const double smallPadding = 8.0;

  /// Large padding
  static const double largePadding = 24.0;
}
