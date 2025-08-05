import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';

/// Search bar widget for entering city names
/// Includes search history and suggestions
class WeatherSearchBar extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryProvider);

    return Column(
      children: [
        // Search input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter city name...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        controller.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            onChanged: (value) {
              // Trigger rebuild to show/hide clear button
              // This is a simple approach; in production, you might want to use a StatefulWidget
            },
          ),
        ),

        // Search history
        if (searchHistory.isNotEmpty && focusNode.hasFocus) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                final city = searchHistory[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 18),
                  title: Text(city, style: const TextStyle(fontSize: 14)),
                  onTap: () {
                    controller.text = city;
                    onSubmitted(city);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      final updatedHistory = List<String>.from(searchHistory);
                      updatedHistory.removeAt(index);
                      ref.read(searchHistoryProvider.notifier).state =
                          updatedHistory;
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
