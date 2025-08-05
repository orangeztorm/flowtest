import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/weather.dart';

/// Weather card widget that displays current weather information
/// Shows temperature, weather description, and additional details
class WeatherCard extends StatelessWidget {
  final Weather weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Location
            Text(
              '${weather.cityName}, ${weather.country}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Weather icon and temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weather icon
                CachedNetworkImage(
                  imageUrl: weather.iconUrl,
                  width: 80,
                  height: 80,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(color: Colors.white),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.cloud, size: 80, color: Colors.white),
                ),

                const SizedBox(width: 20),

                // Temperature
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.temperatureString,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weather.feelsLikeString,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Weather description
            Text(
              weather.description.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Weather details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // First row: Humidity, Pressure
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: weather.humidityString,
                      ),
                      _buildDetailItem(
                        icon: Icons.speed,
                        label: 'Pressure',
                        value: weather.pressureString,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Second row: Wind, Visibility
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailItem(
                        icon: Icons.air,
                        label: 'Wind',
                        value:
                            '${weather.windSpeedString} ${weather.windDirection}',
                      ),
                      _buildDetailItem(
                        icon: Icons.visibility,
                        label: 'Visibility',
                        value: weather.visibilityString,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Third row: Sunrise, Sunset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailItem(
                        icon: Icons.wb_sunny,
                        label: 'Sunrise',
                        value: weather.sunriseTime,
                      ),
                      _buildDetailItem(
                        icon: Icons.nights_stay,
                        label: 'Sunset',
                        value: weather.sunsetTime,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual detail item
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
