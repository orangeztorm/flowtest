import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Location button widget for getting weather by current location
/// Shows loading state when fetching location
class LocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const LocationButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: isLoading
          ? const SpinKitThreeBounce(color: Colors.white, size: 20)
          : const Icon(Icons.my_location),
      label: Text(
        isLoading ? 'Getting Location...' : 'Use My Location',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
