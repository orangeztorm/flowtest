# Using FlowTest SDK in Your Flutter Project

## Method 1: Local Development (Current SDK Development)

### 1. Add as Local Dependency

In your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Add FlowTest SDK as local dependency
  flowtest_sdk:
    path: ../flowtest_sdk/flutter_sdk # Path to the SDK

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 2. Import and Use in Your App

```dart
// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flowtest_sdk/flowtest_sdk.dart';  // Single import!

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlowRecorderOverlay(
        enabled: kDebugMode,  // Only in debug mode
        child: Scaffold(
          appBar: AppBar(title: Text('My App')),
          body: MyHomePage(),
          floatingActionButton: RecorderToggle(), // Recording controls
        ),
      ),
    );
  }
}
```

### 3. Create Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flowtest_sdk/flowtest_sdk.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MyApp Flow Tests', () {
    testWidgets('login flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Use FlowTest SDK to run recorded flows
      final logger = FlowLogger(verbose: true);
      final runner = FlowRunner(logger: logger);

      await runner.runFromAsset(tester, 'test_flows/login_flow.json');

      // Verify results
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
```

## Method 2: Published Package (Future)

When published to pub.dev:

```yaml
dependencies:
  flowtest_sdk: ^1.0.0
```

```dart
import 'package:flowtest_sdk/flowtest_sdk.dart';
```

## Method 3: Git Dependency

```yaml
dependencies:
  flowtest_sdk:
    git:
      url: https://github.com/orangeztorm/flowtest.git
      path: flowtest_sdk/flutter_sdk
```

## Running Tests

```bash
# Run widget tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with verbose output
flutter test integration_test/ --verbose

# Run specific test
flutter test integration_test/login_test.dart
```

## Example Project Structure

```
my_flutter_app/
├── lib/
│   ├── main.dart              # App with FlowRecorderOverlay
│   └── screens/               # Your app screens
├── integration_test/
│   ├── login_test.dart        # Tests using FlowTest SDK
│   └── user_journey_test.dart
├── test_flows/                # Recorded JSON flows
│   ├── login_flow.json
│   └── checkout_flow.json
├── pubspec.yaml               # References FlowTest SDK
└── README.md
```
