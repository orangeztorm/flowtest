import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Represents different types of failures that can occur in the application
/// Uses Freezed for immutable data classes and union types
@freezed
class Failure with _$Failure {
  /// Network-related failure (no internet, connection timeout, etc.)
  const factory Failure.network({
    @Default('Network error occurred') String message,
  }) = NetworkFailure;

  /// Server-related failure (HTTP 500, API errors, etc.)
  const factory Failure.server({
    @Default('Server error occurred') String message,
  }) = ServerFailure;

  /// Invalid API key failure
  const factory Failure.invalidApiKey({
    @Default('Invalid API key') String message,
  }) = InvalidApiKeyFailure;

  /// Location not found failure
  const factory Failure.locationNotFound({
    @Default('Location not found') String message,
  }) = LocationNotFoundFailure;

  /// Location service disabled failure
  const factory Failure.locationServiceDisabled({
    @Default('Location services are disabled') String message,
  }) = LocationServiceDisabledFailure;

  /// Location permission denied failure
  const factory Failure.locationPermissionDenied({
    @Default('Location permission denied') String message,
  }) = LocationPermissionDeniedFailure;

  /// Data parsing failure
  const factory Failure.parse({
    @Default('Failed to parse data') String message,
  }) = ParseFailure;

  /// Cache-related failure
  const factory Failure.cache({
    @Default('Cache error occurred') String message,
  }) = CacheFailure;

  /// Unknown/unexpected failure
  const factory Failure.unknown({
    @Default('An unknown error occurred') String message,
  }) = UnknownFailure;
}

/// Extension to get user-friendly error messages from failures
extension FailureExtension on Failure {
  /// Returns a user-friendly error message for display in the UI
  String get userMessage {
    return when(
      network: (message) =>
          'Please check your internet connection and try again.',
      server: (message) =>
          'Something went wrong on our end. Please try again later.',
      invalidApiKey: (message) =>
          'Service temporarily unavailable. Please try again later.',
      locationNotFound: (message) =>
          'Location not found. Please try searching for a different location.',
      locationServiceDisabled: (message) =>
          'Please enable location services to get weather for your current location.',
      locationPermissionDenied: (message) =>
          'Please allow location access to get weather for your current location.',
      parse: (message) => 'Something went wrong. Please try again.',
      cache: (message) => 'Unable to load cached data. Please try again.',
      unknown: (message) => 'Something went wrong. Please try again.',
    );
  }
}
