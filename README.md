# FlowTest

A comprehensive Flutter testing framework that enables visual recording of user interactions and automated playback during integration tests.

## 🎯 **Current Status: SDK Complete ✅**

**FlowTest SDK v1.0.0 is production-ready!** The core Flutter SDK with visual recording and automated playback is complete and ready for use. We're now building the CLI and IDE extensions to create a complete testing ecosystem.

### ✅ **What's Done**
- Complete Flutter SDK with recording & playback
- Professional documentation and examples
- Cross-platform support (iOS, Android, Web, Desktop)
- Production-ready with error handling and logging

### 🔄 **What's Next**
- Command-line interface for easier workflow
- VS Code extension for IDE integration
- AI-powered test generation

## Overview

FlowTest provides a complete solution for creating, managing, and executing Flutter integration tests through an intuitive visual recording interface. It bridges the gap between manual testing and automated test creation, making it easier for developers and QA teams to build reliable test suites.

## Features

### 🎯 Visual Test Recording
- **Real-time Interaction Capture**: Record taps, text inputs, and gestures with a visual overlay
- **Smart Widget Detection**: Automatically identifies buttons, text fields, and interactive elements
- **Cross-Platform Support**: Works seamlessly on iOS, Android, and web platforms

### 🔄 Automated Test Playback
- **Deterministic Execution**: Reliable test playback with built-in wait conditions
- **Robust Element Finding**: Advanced widget targeting with fallback strategies
- **Performance Monitoring**: Built-in timing and performance tracking

### 🛠 Developer Experience
- **Zero Configuration**: Works out of the box with existing Flutter apps
- **Debug Mode Integration**: Recording only active during development
- **JSON Export**: Human-readable test flow format for version control

## Architecture

```
flowtest/
├── packages/
│   ├── flowtest_sdk/          # Core Flutter SDK
│   ├── flowtest_cli/          # Command-line interface (planned)
│   └── flowtest_vscode/       # VS Code extension (planned)
├── examples/
│   └── weather_app/           # Example application
├── docs/                      # Documentation
└── services/
    └── llm_service/           # AI-powered test generation (planned)
```

## Quick Start

### 1. Add FlowTest SDK to Your App

```yaml
# pubspec.yaml
dependencies:
  flowtest_sdk:
    path: ../packages/flowtest_sdk
```

### 2. Wrap Your App for Recording

```dart
import 'package:flowtest_sdk/flowtest_sdk.dart';

void main() {
  runApp(FlowRecorderOverlay(
    enabled: kDebugMode,
    child: MyApp(),
  ));
}
```

### 3. Record Your Test Flow

1. Run your app in debug mode
2. Interact with the UI naturally
3. Export the recorded flow to JSON

### 4. Create Integration Tests

```dart
import 'package:flowtest_sdk/flowtest_sdk.dart';

testWidgets('Login flow test', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  final runner = FlowRunner(tester);
  final flow = await FlowLoader.fromFile('test_flows/login_flow.json');
  await runner.run(flow);
  
  expect(find.text('Welcome'), findsOneWidget);
});
```

## SDK Components

### Recording System
- **FlowRecorderOverlay**: Visual overlay for capturing interactions
- **RecorderController**: Manages recording state and step storage
- **RecorderUtils**: Utilities for widget detection and target extraction

### Playback Engine
- **FlowRunner**: Orchestrates test execution
- **TargetResolver**: Converts target strings to Flutter Finders
- **ExpectationMatcher**: Validates UI state during playback

### Data Models
- **TestFlow**: Complete test flow definition
- **FlowStep**: Individual interaction step
- **Expectation**: UI state validation rules

## Example Test Flow

```json
{
  "flowId": "login_flow",
  "steps": [
    {
      "action": "tap",
      "target": "button:Login",
      "timestamp": "2024-01-15T10:30:00Z"
    },
    {
      "action": "input",
      "target": "input:Email",
      "value": "user@example.com"
    },
    {
      "action": "input",
      "target": "input:Password",
      "value": "password123"
    },
    {
      "action": "tap",
      "target": "button:Sign In"
    },
    {
      "action": "wait",
      "value": "2000"
    },
    {
      "action": "expect",
      "target": "text:Welcome",
      "condition": "exists"
    }
  ]
}
```

## Development Status

### ✅ **COMPLETED (Sprint S1)**
- **Core SDK Implementation** - Complete Flutter SDK with recording and playback
- **Visual Recording System** - Real-time interaction capture with overlay UI
- **Automated Playback Engine** - WidgetTester integration for test execution
- **Robust Widget Targeting** - Advanced hit testing and element finding
- **Performance Monitoring** - Built-in timing and optimization
- **Cross-Platform Support** - iOS, Android, Web, Desktop compatibility
- **Comprehensive Documentation** - Professional docs and examples
- **Integration Testing** - Complete test suite with CI/CD
- **Production Ready** - Error handling, logging, and reliability features

### 🔄 **IN PROGRESS (Sprint S2)**
- **Command-Line Interface** - `flowtest record/run/list` commands
- **VS Code Extension** - Flow explorer and run button integration
- **Enhanced Test Generation** - AI-powered test creation

### ⏳ **PLANNED (Sprint S3-S10)**
- **AI-Powered Test Creation** - FastAPI service for prompt-to-flow generation
- **Visual Editor** - Web-based flow editor with React
- **Cloud Test Execution** - Headless emulator and CI/CD pipelines
- **Performance Optimization** - Fast-mode, AVD snapshots, parallel execution
- **Public Beta** - Documentation site, security audit, Windows compatibility
- **JetBrains Plugin** - IDE integration for IntelliJ/Android Studio
- **v1.0 GA Launch** - Public release with marketing and community engagement

## What's Next

### 🚀 **Immediate Next Steps**
1. **CLI Development** - Build command-line interface for recording and running flows
2. **VS Code Extension** - Create IDE integration for seamless workflow
3. **Documentation Site** - Launch comprehensive documentation portal

### 🎯 **Current Focus Areas**
- **User Experience** - Streamline the recording and playback workflow
- **Developer Tools** - Provide better debugging and error reporting
- **Community Building** - Gather feedback and build user base

### 📋 **Success Metrics**
- **SDK Adoption** - Number of Flutter projects using FlowTest
- **Test Coverage** - Percentage of apps with automated UI tests
- **Developer Satisfaction** - Reduced time to create integration tests

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Run tests: `flutter test`
4. Build examples: `flutter build`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/your-org/flowtest/issues)
- 💬 [Discussions](https://github.com/your-org/flowtest/discussions)

---

Built with ❤️ for the Flutter community 