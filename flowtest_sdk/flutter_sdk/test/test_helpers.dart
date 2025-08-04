import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

/// Helper to detect if we're in an environment suitable for integration tests
bool get _isIntegrationEnv {
  // Check if we're running on a real device or emulator
  // This can be detected by checking if platform channels are available
  try {
    // In a true integration test environment, platform channels work
    // In widget test environment, they don't
    return Platform.environment.containsKey('FLUTTER_TEST_DEVICE') ||
        Platform.environment.containsKey('INTEGRATION_TEST');
  } catch (_) {
    return false;
  }
}

/// Professional integration test wrapper with automatic environment detection
///
/// This helper automatically skips tests when no device/emulator is available,
/// preventing hanging tests in pure widget test environments.
///
/// Usage:
/// ```dart
/// integrationTest('My device-dependent test', (tester) async {
///   // This will only run when a device/emulator is connected
///   await tester.pumpWidget(MyApp());
///   // ... rest of test
/// });
/// ```
void integrationTest(
  String description,
  Future<void> Function(WidgetTester) body, {
  bool? skip,
  Timeout? timeout,
}) {
  final shouldSkip = skip ?? !_isIntegrationEnv;
  final skipReason = shouldSkip
      ? '❌ Requires a connected device or emulator'
      : null;

  testWidgets(
    description,
    body,
    skip: shouldSkip,
    timeout:
        timeout ?? const Timeout(Duration(minutes: 5)), // Reasonable default
  );

  // Print skip reason for clarity
  if (skipReason != null) {
    print('SKIPPED: $description - $skipReason');
  }
}

/// Safe app launcher that works in all test environments
/// Uses bounded timeouts to prevent infinite hangs
Future<void> launchDemo(WidgetTester tester, {Function()? main}) async {
  if (main != null) main();

  // Give the start-up animations some time, *but* bail out after 5 s max.
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Just in case previous test left a SnackBar etc. finishing:
  await tester.pump(const Duration(milliseconds: 300));
}

/// Professional test group with automatic cleanup between tests
void robustTestGroup(String description, void Function() body) {
  group(description, () {
    // Clean up between tests to prevent lingering state
    tearDown(() {
      // Dispose text-field focus blink
      try {
        FocusManager.instance.primaryFocus?.unfocus();
      } catch (_) {
        // Ignore if FocusManager isn't available
      }
    });

    body();
  });
}
