/// FlowTest SDK - Flutter test recording and playback library
///
/// A comprehensive Flutter SDK for recording user interactions as JSON flows
/// and replaying them during integration tests.
///
/// ## Core Features:
/// - Visual recording with overlay UI
/// - Automated playback with WidgetTester
/// - Cross-platform storage and asset management
/// - Professional logging with ANSI colors
/// - Unified selector system for widget targeting
///
/// ## Quick Start:
///
/// ### Recording (Development Mode):
/// ```dart
/// import 'package:flowtest_sdk/flowtest_sdk.dart';
///
/// // Wrap your app for recording
/// FlowRecorderOverlay(
///   enabled: kDebugMode,
///   child: MyApp(),
/// )
/// ```
///
/// ### Playback (Integration Tests):
/// ```dart
/// import 'package:flowtest_sdk/flowtest_sdk.dart';
///
/// testWidgets('My flow test', (tester) async {
///   final runner = FlowRunner(logger: FlowLogger(verbose: true));
///   await runner.runFromAsset(tester, 'test_flows/my_flow.json');
/// });
/// ```
///
/// See the README.md for complete documentation and examples.
library flowtest_sdk;

// Core Models - Data structures for flows and steps
export 'models/test_flow.dart';
export 'models/flow_step.dart';
export 'models/expectation.dart';
export 'models/enums.dart';

// Recording System - Visual capture during development
export 'recorder/recorder_overlay.dart';
export 'recorder/recorder_controller.dart';
export 'recorder/recorder_toggle.dart';
export 'recorder/recorder_widget_utils.dart';
export 'recorder/recorder.dart';

// Playback Engine - Automated test execution
export 'runner/flow_runner.dart';
export 'runner/flow_loader.dart';
export 'runner/target_resolver.dart';
export 'runner/expectation_matcher.dart';
export 'runner/runner.dart';

// Utilities - Storage, logging, and helpers
export 'utils/storage_service.dart';
export 'utils/flow_logger.dart';

// Re-export commonly used Flutter testing components for convenience
export 'package:flutter/foundation.dart' show kDebugMode;
export 'package:flutter_test/flutter_test.dart'
    show WidgetTester, testWidgets, expect, findsOneWidget, findsNothing;
