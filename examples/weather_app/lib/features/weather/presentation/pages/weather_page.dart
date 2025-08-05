import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_list.dart';
import '../widgets/search_bar.dart';
import '../widgets/error_widget.dart';

/// Main weather page that displays current weather and forecast
/// Uses Riverpod for state management and follows clean architecture principles
class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _lastError;

  @override
  void initState() {
    super.initState();
    // Load default weather data on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).getCurrentWeather('London');
      ref.read(weatherProvider.notifier).getWeatherForecast('London');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Handle search submission
  void _onSearchSubmitted(String cityName) {
    if (cityName.trim().isNotEmpty) {
      _searchFocusNode.unfocus();
      final notifier = ref.read(weatherProvider.notifier);
      notifier.getCurrentWeather(cityName.trim());
      notifier.getWeatherForecast(cityName.trim());

      // Add to search history
      addToSearchHistory(ref, cityName.trim());

      // Clear search field
      _searchController.clear();
    }
  }

  /// Handle refresh
  Future<void> _onRefresh() async {
    await ref.read(weatherProvider.notifier).refreshWeather();
  }

  /// Show error toast message
  void _showErrorToast(String message) {
    // Show a SnackBar for better visibility and platform consistency
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWeather = ref.watch(currentWeatherProvider);
    final forecast = ref.watch(forecastProvider);
    final isLoading = ref.watch(weatherLoadingProvider);
    final error = ref.watch(weatherErrorProvider);

    // Show toast when there's a new error
    ref.listen<String?>(weatherErrorProvider, (previous, next) {
      print(
        'Error listener triggered: previous=$previous, next=$next',
      ); // Debug log
      if (next != null && next != _lastError) {
        print('Showing error toast: $next'); // Debug log
        _lastError = next;
        // Add a small delay to ensure the UI is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorToast(next);
        });
      }
    });

    return Scaffold(
      backgroundColor: _getBackgroundColor(context, currentWeather?.main),
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search bar
              WeatherSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSubmitted: _onSearchSubmitted,
              ),

              const SizedBox(height: 16),

              // Location button
              // LocationButton(
              //   onPressed: _onLocationPressed,
              //   isLoading: isLocationLoading,
              // ),
              const SizedBox(height: 24),

              // Location error
              // if (locationError != null) ...[
              //   WeatherErrorWidget(
              //     message: locationError,
              //     onRetry: _onLocationPressed,
              //   ),
              //   const SizedBox(height: 16),
              // ],

              // Main content
              if (isLoading && currentWeather == null)
                _buildLoadingWidget()
              else if (error != null && currentWeather == null)
                WeatherErrorWidget(
                  message: error,
                  onRetry: () {
                    ref
                        .read(weatherProvider.notifier)
                        .getCurrentWeather('London');
                  },
                )
              else if (currentWeather != null) ...[
                // Current weather card
                WeatherCard(weather: currentWeather),

                const SizedBox(height: 24),

                // Forecast section
                if (forecast != null) ...[
                  const Text(
                    '5-Day Forecast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ForecastList(forecast: forecast),
                ] else if (isLoading) ...[
                  const Text(
                    '5-Day Forecast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLoadingWidget(),
                ],
              ],

              // Add some bottom padding for better scrolling
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    return const Center(
      child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
    );
  }

  /// Get background color based on weather condition
  Color _getBackgroundColor(BuildContext context, String? weatherMain) {
    if (weatherMain == null) {
      return const Color(0xFF2196F3); // Default blue
    }

    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return const Color(0xFFFFB74D); // Orange for clear sky
      case 'clouds':
        return const Color(0xFF90A4AE); // Grey for clouds
      case 'rain':
      case 'drizzle':
        return const Color(0xFF5C6BC0); // Indigo for rain
      case 'thunderstorm':
        return const Color(0xFF424242); // Dark grey for storms
      case 'snow':
        return const Color(0xFFB0BEC5); // Light grey for snow
      case 'mist':
      case 'fog':
      case 'haze':
        return const Color(0xFF78909C); // Blue grey for mist
      default:
        return const Color(0xFF2196F3); // Default blue
    }
  }
}
