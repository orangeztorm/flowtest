// 📁 PROJECT: flutter_sdk/
// 🎯 Purpose: Flutter SDK for test recording & playback in dev mode

// ✅ Goal: Allow developers to visually record test flows
// ✅ Goal: Allow replay of flow JSON during integration tests or dev builds

/*
📁 Folder Structure:
flutter_sdk/
├── lib/
│   ├── recorder/              # RecorderOverlay + RecorderController
│   │   ├── recorder_overlay.dart
│   │   ├── recorder_controller.dart
│   │   ├── recorder_toggle.dart
│   │   ├── recorder_widget_utils.dart
│   │   ├── recorder.dart
│   │   └── HIT_TESTING.md
│   ├── runner/                # FlowRunner that executes flow JSON
│   │   ├── flow_runner.dart
│   │   └── target_resolver.dart
│   ├── models/                # All Flow-related models
│   │   ├── flow_step.dart
│   │   ├── expectation.dart
│   │   ├── enums.dart
│   │   └── test_flow.dart
│   ├── utils/                 # Helpers (storage, logger)
│   │   ├── storage_service.dart
│   │   └── flow_logger.dart
│   └── flutter_sdk.dart       # Public export
├── test/
│   └── flow_runner_test.dart  # Tests for playback
├── example/
│   └── main.dart              # Example usage in a Flutter app
├── pubspec.yaml
*/

/*
🗺️ Dev Plan:

✅ Step 1: Define Flow Model
- flowId
- steps: List<FlowStep>
- FlowStep: action (tap, input, expect), target, value
- COMPLETED: Created flow_step.dart and test_flow.dart with JSON serialization
- ENHANCED: Added chainable expectations with ExpectCondition enum and Expectation class
- ENHANCED: Added new actions (scroll, longPress, wait) and comprehensive expectation conditions
- REORGANIZED: Split into clean model structure (enums.dart, expectation.dart, flow_step.dart, test_flow.dart)

✅ Step 2: Build RecorderOverlay (for dev mode only)
- Wrap app in overlay
- Capture taps, input
- Save step as FlowStep
- Export to JSON
- COMPLETED: Created FlowRecorderOverlay with tap and text input recording
- COMPLETED: Added RecorderController singleton for managing recording state
- COMPLETED: Added RecorderToggle widget for start/stop/export controls
- COMPLETED: Added RecorderUtils for widget target extraction
- COMPLETED: Added example app demonstrating usage
- COMPLETED: Added export functionality to JSON files in test_flows/ directory
- ENHANCED: Implemented robust hit testing with Element tree traversal
- ENHANCED: Added overlay filtering to exclude recorder UI components
- ENHANCED: Added bounds checking for accurate widget detection
- ENHANCED: Added performance monitoring with Timeline.timeSync
- ENHANCED: Improved text input capture from widget controllers
- ENHANCED: Added comprehensive documentation (HIT_TESTING.md, README.md)

🔹 Step 3: Build FlowRunner
- Load flow from file
- Execute each step using WidgetTester or gestures
- Match target using key, text, type

🔹 Step 4: Build TargetResolver
- Map "@keyName" → Key
- Map "text:Login" → find.text()
- Map "button:Continue[1]" → heuristic matching
- COMPLETED: Created target_resolver.dart with support for key, text, button patterns

🔹 Step 5: Add StorageService
- Save/load JSON flow files
- Export path: test_flows/

🔹 Step 6: Add Dev Logger (optional)
- Log each step to console / overlay
- Show success/failure visually

🔹 Step 7: Example integration_test
- Load a flow and replay it in test
- Use `flutter test integration_test/flow_test.dart`
*/
