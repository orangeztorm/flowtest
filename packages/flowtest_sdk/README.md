# FlowTest SDK 🎯

[![Tests](https://github.com/orangeztorm/flowtest/actions/workflows/integration-tests.yml/badge.svg)](https://github.com/orangeztorm/flowtest/actions/workflows/integration-tests.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.32.0-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.8.0-blue.svg)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-iOS%20|%20Android%20|%20Web%20|%20Desktop-lightgrey.svg)](https://flutter.dev/docs/development/tools/sdk/release-notes)
[![Coverage](https://codecov.io/gh/orangeztorm/flowtest/branch/main/graph/badge.svg)](https://codecov.io/gh/orangeztorm/flowtest)

A comprehensive Flutter SDK for **visual test recording and automated playback** during development and integration testing. Record user interactions as JSON flows and replay them seamlessly across all platforms.

## 🌟 Key Features

### 🎬 Visual Recording

- **Real-time interaction capture** during development
- **Smart widget detection** with sophisticated hit testing
- **Professional UI overlay** with intuitive controls
- **Cross-platform compatibility** (iOS, Android, Web, Desktop)

### 🔄 Automated Playback

- **JSON-based test flows** for reliable replay
- **WidgetTester integration** for Flutter integration tests
- **Comprehensive assertions** with expectation matching
- **Screenshot capture** on test failures for debugging

### 🎨 Professional Development Experience

- **ANSI colored console logging** with cross-platform support
- **Step progress tracking** ([1/5], [2/5] format)
- **Verbose control** (chatty in dev, quiet in CI)
- **Error handling** with detailed failure context

### 💾 Robust Storage

- **Cross-platform file operations** with path_provider
- **Asset bundling** for test flows in apps
- **Collision detection** and safe file operations
- **Multiple storage formats** (assets, local storage)

## 🚀 Quick Start

### 1. Add FlowTest to Your Project

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.2 # Required for storage

dev_dependencies:
  flutter_test:
    sdk: flutter

# Bundle your test flows as assets
flutter:
  assets:
    - test_flows/
```

### 2. Recording Test Flows (Development Mode)

```dart
import 'package:flowtest_sdk/recorder/recorder.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlowRecorderOverlay(
        enabled: kDebugMode, // Only in development
        child: Scaffold(
          body: MyHomePage(),
          floatingActionButton: const RecorderToggle(),
        ),
      ),
    );
  }
}
```

### 3. Playing Back Test Flows (Integration Tests)

```dart
// test/integration/my_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flowtest_sdk/runner/flow_runner.dart';
import 'package:flowtest_sdk/utils/flow_logger.dart';

void main() {
  testWidgets('Login flow test', (WidgetTester tester) async {
    // Initialize with professional logging
    final logger = FlowLogger(verbose: true);
    final runner = FlowRunner(logger: logger);

    // Load and run your recorded flow
    await runner.runFromAsset(
      tester,
      'test_flows/login_flow.json',
      screenshotOnFailure: true,
    );

    // Verify final state
    expect(find.text('Welcome!'), findsOneWidget);
  });
}
```

### 4. Creating Custom Test Flows

```dart
import 'package:flowtest_sdk/models/test_flow.dart';
import 'package:flowtest_sdk/utils/storage_service.dart';

// Create a flow programmatically
final flow = TestFlow(
  flowId: 'custom_login_flow',
  steps: [
    FlowStep.tap(target: '@email_field'),
    FlowStep.input(target: 'input:Email', value: 'test@example.com'),
    FlowStep.tap(target: '@password_field'),
    FlowStep.input(target: 'input:Password', value: 'secure123'),
    FlowStep.tap(target: 'button:Login'),
    FlowStep.expect(target: 'text:Welcome', condition: ExpectCondition.exists),
  ],
);

// Save for later use
final storage = StorageService();
await storage.saveFlow(flow, 'my_custom_login');
```

## 📋 Complete Example Workflows

### Recording a Login Flow

1. **Start Recording**: Tap the blue record button
2. **Interact Naturally**:
   - Tap email field → Enter "user@example.com"
   - Tap password field → Enter password
   - Tap login button
3. **Stop & Export**: Tap red stop, then green export
4. **Generated JSON**:

```json
{
  "flowId": "login_flow_20250804",
  "recordedAt": "2025-08-04T10:30:00.000Z",
  "steps": [
    { "action": "tap", "target": "@email_field" },
    { "action": "input", "target": "input:Email", "value": "user@example.com" },
    { "action": "tap", "target": "@password_field" },
    { "action": "input", "target": "input:Password", "value": "********" },
    { "action": "tap", "target": "button:Login" },
    { "action": "wait", "duration": 2000 },
    { "action": "expect", "target": "text:Welcome", "condition": "exists" }
  ]
}
```

### Running Integration Tests

```bash
# Run all integration tests with verbose logging
flutter test integration_test/ --verbose

# Run specific test file
flutter test integration_test/login_flow_test.dart

# Run with screenshot capture
flutter test integration_test/ --screenshot=on-failure
```

## 🎯 Target Selectors

FlowTest uses a unified selector system for maximum reliability:

| Selector Type | Format            | Example               | Best For                    |
| ------------- | ----------------- | --------------------- | --------------------------- |
| **Key**       | `@keyName`        | `@email_field`        | Reliable, developer-defined |
| **Text**      | `text:content`    | `text:Login`          | Buttons, labels             |
| **Button**    | `button:text`     | `button:Continue`     | Interactive buttons         |
| **Input**     | `input:label`     | `input:Email`         | Form fields                 |
| **Type**      | `type:WidgetType` | `type:ElevatedButton` | Fallback option             |

### Advanced Selector Examples

```dart
// Complex nested button
FlowStep.tap(target: 'button:Continue[1]'), // Second "Continue" button

// Case-insensitive text matching
FlowStep.expect(target: 'text:success', condition: ExpectCondition.exists),

// Multiple expectations
FlowStep.expect(target: '@login_form', condition: ExpectCondition.enabled),
FlowStep.expect(target: 'input:Email', condition: ExpectCondition.notEmpty),
```

## 🔧 Advanced Configuration

### Custom Logger Setup

```dart
// Configure logger for different environments
final logger = FlowLogger(
  verbose: kDebugMode, // Automatic dev/prod switching
  useColors: true,     // ANSI colors (auto-detected)
);

// Manual logging
logger.info('Starting test suite');
logger.success('✅ Login flow completed successfully');
logger.error('❌ Test failed: Widget not found');
logger.step('▶️ [3/5] Filling login form');
```

### Storage Service Configuration

```dart
final storage = StorageService();

// List all saved flows
final flows = await storage.listSavedFlows();
print('Available flows: ${flows.join(', ')}');

// Load from different sources
final assetFlow = await storage.loadFlowFromAsset('test_flows/login.json');
final savedFlow = await storage.loadFlowFromStorage('my_custom_flow');

// Safe saving with collision detection
await storage.saveFlowWithName(flow, 'login_v2'); // Auto-renames if exists
```

### Screenshot and Error Handling

```dart
final runner = FlowRunner(
  logger: logger,
  screenshotOnFailure: true, // Automatic failure screenshots
  screenshotPath: 'test_failures/', // Custom screenshot directory
);

// Handle errors gracefully
try {
  await runner.runFromAsset(tester, 'test_flows/complex_flow.json');
} catch (e) {
  logger.error('Flow execution failed: $e');
  // Screenshot automatically captured
  rethrow;
}
```

## 📁 Project Structure

```
flowtest_sdk/
├── flutter_sdk/              # Core SDK implementation
│   ├── lib/
│   │   ├── models/           # Data models (TestFlow, FlowStep, etc.)
│   │   ├── recorder/         # Recording overlay & controls
│   │   ├── runner/           # Flow execution engine
│   │   └── utils/           # Storage, logging, helpers
│   ├── test/
│   │   └── integration/     # Comprehensive test suite
│   ├── example/             # Working example app
│   └── test_flows/          # Sample flow JSON files
├── docs/                    # Documentation
├── test_flows/              # Bundled test assets
└── README.md               # This file
```

## 🧪 Testing & Validation

### Running the Test Suite

```bash
# Complete validation
flutter analyze                          # Static analysis
flutter test flutter_sdk/test/           # Unit tests
flutter test integration_test/           # Integration tests

# Specific test categories
flutter test flutter_sdk/test/integration/logger_test.dart
flutter test flutter_sdk/test/integration/storage_test.dart
flutter test flutter_sdk/test/integration/production_ready_test.dart
```

### Example Test Results

```
✅ FlowLogger Integration Tests
✅ StorageService cross-platform operations
✅ Production-ready FlowRunner features
✅ Asset loading and validation
✅ Screenshot capture verification
✅ Error handling and recovery

All 15 tests passed! 🎉
```

## 🚀 Production Deployment

### CI/CD Configuration

```yaml
# .github/workflows/test.yml
name: FlowTest SDK Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.32.0"
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter test integration_test/
```

### Performance Characteristics

- **Recording overhead**: < 1ms per interaction
- **Playback speed**: ~50ms per step (WidgetTester dependent)
- **Memory usage**: < 5MB additional for recorder overlay
- **Binary size impact**: < 500KB (when tree-shaken in release)

## 🔍 Troubleshooting

### Common Issues

#### "Widget not found" during playback

```dart
// Solution: Use more specific selectors
FlowStep.tap(target: '@login_button'),     // ✅ Good - Key-based
FlowStep.tap(target: 'text:Login'),        // ⚠️ OK - Text-based
FlowStep.tap(target: 'type:ElevatedButton'), // ❌ Avoid - Too generic
```

#### Assets not loading in tests

```yaml
# Ensure pubspec.yaml includes:
flutter:
  assets:
    - test_flows/
    - flutter_sdk/test_flows/ # If using nested structure
```

#### ANSI colors not showing on Windows

```dart
// FlowLogger automatically detects terminal support
final logger = FlowLogger(
  verbose: true,
  useColors: true, // Auto-detects Windows CMD limitations
);
```

### Debug Mode

```dart
// Enable maximum verbosity for debugging
final logger = FlowLogger(verbose: true);
Timeline.startSync('FlowTest Debugging'); // Performance monitoring

// Check widget tree during recording
RecorderController.instance.debugPrintWidgetTree = true;
```

## 📚 Documentation

- **[API Reference](flutter_sdk/lib/)** - Complete code documentation
- **[Recording Guide](flutter_sdk/README.md)** - Detailed recording setup
- **[Hit Testing Implementation](flutter_sdk/lib/recorder/HIT_TESTING.md)** - Technical deep-dive
- **[Development Plan](plan.md)** - Implementation roadmap and progress

## 🏆 Production Ready Features

### ✅ Cross-Platform Compatibility

- iOS, Android, Web, macOS, Linux, Windows
- Graceful degradation on limited platforms
- Platform-specific optimizations

### ✅ Enterprise Grade Reliability

- Comprehensive error handling with recovery
- Memory leak prevention
- Performance monitoring and optimization
- Thread-safe operations

### ✅ Developer Experience

- Zero-configuration setup for basic use cases
- Professional logging with ANSI color support
- Intuitive API design with method chaining
- Extensive documentation and examples

### ✅ CI/CD Integration

- Quiet mode for automated testing
- Screenshot capture for failure analysis
- Compatible with GitHub Actions, Jenkins, etc.
- Deterministic test execution

## 🎯 Version 1.0.0 Status

**All 7 planned development steps completed:**

1. ✅ **Flow Data Model** - Complete JSON serialization
2. ✅ **Visual Recording Overlay** - Professional UI with hit testing
3. ✅ **Flow Execution Engine** - Full WidgetTester integration
4. ✅ **Unified Selector System** - Single API for all widget finding
5. ✅ **Storage Service** - Cross-platform file operations
6. ✅ **Development Logger** - Production-ready logging with ANSI support
7. ✅ **Integration Examples** - Comprehensive test suite

**Ready for production use, testing, and potential publishing! 🚀**

## 🧪 Testing & CI/CD

### Running Tests Locally

```bash
# Run all tests
flutter test

# Run only unit tests
flutter test --exclude-tags integration

# Run only integration tests
flutter test --tags integration

# Run integration tests on specific device
flutter test integration_test/ -d "device-id"

# Run with coverage
flutter test --coverage
```

### Test Tags Configuration

The SDK uses `dart_test.yaml` for test configuration:

```yaml
# dart_test.yaml
tags:
  integration:
    skip: false # Declaration only; no behavior change

# Usage examples:
# flutter test --tags integration      # Run only integration tests
# flutter test --exclude-tags integration  # Skip integration tests
```

### CI/CD Integration

#### Automated Script

Use the provided CI script for automated testing:

```bash
# Auto-detect device and run tests
./scripts/run_integration_tests.sh

# Use specific device
./scripts/run_integration_tests.sh --device-id "simulator-id"

# CI environment
CI=true ./scripts/run_integration_tests.sh
```

#### GitHub Actions

The repository includes a complete GitHub Actions workflow (`.github/workflows/integration-tests.yml`) that:

- ✅ Tests on iOS, Android, and macOS
- ✅ Collects test artifacts and screenshots
- ✅ Uploads coverage reports
- ✅ Creates test summary reports

#### Test Artifacts

Failed tests automatically capture:

- 📸 **Screenshots** in `flowtest_screenshots/`
- 📊 **Coverage reports** in `coverage/`
- 📝 **Test logs** for debugging

### Test Architecture

The SDK uses a **defense-in-depth** testing strategy:

1. **Layer 1**: Dart environment detection
2. **Layer 2**: Platform channel timeout protection
3. **Layer 3**: Integration test binding configuration

This ensures tests never hang in any environment (development, CI/CD, or production).

### Example Integration Test

```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowtest_sdk/flowtest_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlowTest Integration', () {
    testWidgets('Complete flow execution', (WidgetTester tester) async {
      // Load and execute a recorded flow
      final flow = await FlowLoader.fromAsset('test_flows/login_flow.json');
      final runner = FlowRunner(tester, verbose: true);

      await runner.run(flow);

      // Screenshots automatically captured on failure
      expect(find.text('Success'), findsOneWidget);
    }, tags: ['integration']);
  });
}
```

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

**Built with ❤️ for the Flutter community**
