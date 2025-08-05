import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/forecast.dart';

/// Forecast list widget that displays weather forecast items
/// Shows forecast for the next 5 days with weather details
class ForecastList extends StatelessWidget {
  final Forecast forecast;

  const ForecastList({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Group forecast items by date (take one item per day, preferably around noon)
    final dailyForecasts = _getDailyForecasts(forecast.items);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dailyForecasts.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.white.withOpacity(0.2), height: 1),
        itemBuilder: (context, index) {
          final item = dailyForecasts[index];
          return _buildForecastItem(item);
        },
      ),
    );
  }

  /// Build individual forecast item
  Widget _buildForecastItem(ForecastItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Text(
              item.dateString,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Weather icon
          CachedNetworkImage(
            imageUrl: item.iconUrl,
            width: 40,
            height: 40,
            placeholder: (context, url) => const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.cloud, size: 40, color: Colors.white),
          ),

          const SizedBox(width: 12),

          // Weather description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.main,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Temperature and precipitation
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.temperatureString,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (item.pop > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 12,
                      color: Colors.blue.shade200,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item.precipitationString,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade200,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get daily forecasts from forecast items
  /// Takes one forecast per day, preferring forecasts around noon (12:00)
  List<ForecastItem> _getDailyForecasts(List<ForecastItem> items) {
    final Map<String, ForecastItem> dailyMap = {};

    for (final item in items) {
      final date = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000);
      final dateKey = '${date.year}-${date.month}-${date.day}';

      // If we don't have a forecast for this date, or if this forecast is closer to noon
      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = item;
      } else {
        final existingItem = dailyMap[dateKey]!;
        final existingDate = DateTime.fromMillisecondsSinceEpoch(
          existingItem.dt * 1000,
        );

        // Prefer forecasts closer to noon (12:00)
        final currentDistanceFromNoon = (date.hour - 12).abs();
        final existingDistanceFromNoon = (existingDate.hour - 12).abs();

        if (currentDistanceFromNoon < existingDistanceFromNoon) {
          dailyMap[dateKey] = item;
        }
      }
    }

    // Return up to 5 days of forecasts
    return dailyMap.values.take(5).toList();
  }
}
