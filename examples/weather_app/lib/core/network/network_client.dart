import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// Network client for making HTTP requests
/// Configures Dio with default settings and interceptors
class NetworkClient {
  static Dio? _dio;

  /// Get the singleton Dio instance
  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  /// Create and configure the Dio instance
  static Dio _createDio() {
    final dio = Dio();

    // Configure base options
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: ApiConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add logging interceptor in debug mode
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          // Only log in debug mode
          assert(() {
            print(object);
            return true;
          }());
        },
      ),
    );

    // Add error handling interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Log error details
          assert(() {
            print('Network Error: ${error.message}');
            print('Status Code: ${error.response?.statusCode}');
            print('Response Data: ${error.response?.data}');
            return true;
          }());

          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Reset the Dio instance (useful for testing)
  static void reset() {
    _dio = null;
  }
}
