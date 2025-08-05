/// API constants for the weather application
/// Contains all API-related configuration and endpoints
class ApiConstants {
  /// OpenWeatherMap API base URL
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Your OpenWeatherMap API key
  /// Get your free API key from: https://openweathermap.org/api
  /// IMPORTANT: Replace 'YOUR_API_KEY_HERE' with your actual API key
  static const String apiKey =
      'eea0433eff99ebb7c7acc246fbb7b5b4'; // ⚠️ REPLACE THIS WITH YOUR ACTUAL API KEY ⚠️

  /// Current weather endpoint
  static const String currentWeather = '/weather';

  /// Weather forecast endpoint (5 days with 3-hour intervals)
  static const String forecast = '/forecast';

  /// Weather icon base URL
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn';

  /// Default connection timeout in milliseconds
  static const int connectionTimeout = 30000;

  /// Default receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Default send timeout in milliseconds
  static const int sendTimeout = 30000;

  /// Metric units (Celsius, meters/sec, etc.)
  static const String units = 'metric';
}
// https://api.openweathermap.org/data/2.5/onecall/timemachine?appid=c74169edb427a33c1630557e945fd6dd
