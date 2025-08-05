/// Custom exceptions for the weather application
/// Defines different types of errors that can occur during API calls and data processing

/// Base exception class for all weather app exceptions
abstract class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => 'WeatherException: $message';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends WeatherException {
  const NetworkException([String message = 'Network error occurred'])
    : super(message);
}

/// Exception thrown when the API request times out
class TimeoutException extends WeatherException {
  const TimeoutException([String message = 'Request timeout']) : super(message);
}

/// Exception thrown when the server returns an error response
class ServerException extends WeatherException {
  const ServerException([String message = 'Server error occurred'])
    : super(message);
}

/// Exception thrown when the API key is invalid or missing
class InvalidApiKeyException extends WeatherException {
  const InvalidApiKeyException([String message = 'Invalid API key'])
    : super(message);
}

/// Exception thrown when the requested location is not found
class LocationNotFoundException extends WeatherException {
  const LocationNotFoundException([String message = 'Location not found'])
    : super(message);
}

/// Exception thrown when location services are disabled
class LocationServiceDisabledException extends WeatherException {
  const LocationServiceDisabledException([
    String message = 'Location services are disabled',
  ]) : super(message);
}

/// Exception thrown when location permission is denied
class LocationPermissionDeniedException extends WeatherException {
  const LocationPermissionDeniedException([
    String message = 'Location permission denied',
  ]) : super(message);
}

/// Exception thrown when there's an error parsing the API response
class ParseException extends WeatherException {
  const ParseException([String message = 'Failed to parse response data'])
    : super(message);
}

/// Exception thrown when the cache is empty or corrupted
class CacheException extends WeatherException {
  const CacheException([String message = 'Cache error occurred'])
    : super(message);
}

/// Exception thrown for any other unexpected errors
class UnknownException extends WeatherException {
  const UnknownException([String message = 'An unknown error occurred'])
    : super(message);
}
