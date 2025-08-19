# Flow Manager - Complete Flow Management System

The Flow Manager provides a comprehensive solution for managing, playing, and automating test flows in your Flutter app.

## 🚀 Quick Start

### 1. Long-press the Recording Bubble
- Long-press the recording bubble (red circle) in your app
- This opens the **Flow Manager** bottom sheet

### 2. Manage Your Flows
The Flow Manager provides:
- **List all saved flows** with metadata (date, size)
- **Rename flows** with a simple dialog
- **Delete flows** with confirmation
- **Play flows** immediately or schedule for restart
- **Speed control** (0.25x to 2.0x playback speed)

## 📱 Flow Manager Features

### Play Now
- Tap the **Play** button to immediately replay a flow
- The bottom sheet closes and playback starts
- Shows progress via snackbar notifications

### Restart & Play
- Toggle the **"Restart & play"** chip
- Tap **Restart & play** to close the app and replay on next launch
- Perfect for testing app startup flows

### Speed Control
- Adjust playback speed from 0.25x to 2.0x
- Speed affects both step execution and delays
- Real-time speed adjustment

### Flow Management
- **Rename**: Tap the edit icon to rename flows
- **Delete**: Tap the delete icon with confirmation
- **Refresh**: Pull to refresh or tap refresh button

## 🖥️ Terminal Integration

### Command Line Flow Execution
Use the provided CLI script to run flows from terminal:

```bash
# Make the script executable (first time only)
chmod +x scripts/flowctl.sh

# Run a flow at default speed (1.0x)
./scripts/flowctl.sh test_flows/my_flow.json

# Run a flow at 2x speed
./scripts/flowctl.sh test_flows/my_flow.json 2.0

# Run a flow at 0.5x speed
./scripts/flowctl.sh test_flows/my_flow.json 0.5
```

### How Terminal Integration Works
1. **Base64 Encoding**: The script encodes your flow JSON
2. **Dart Defines**: Passes encoded data via `--dart-define`
3. **Auto-Launch**: App boots and immediately replays the flow
4. **No File Transfer**: No need to copy files into app sandbox

### Platform Support
- **iOS**: `./scripts/flowctl.sh flow.json && flutter run -d ios`
- **Android**: `./scripts/flowctl.sh flow.json && flutter run -d emulator-5554`

## 🔧 Technical Implementation

### Flow Manager Sheet
```dart
// Open the flow manager
await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => FlowManagerSheet(
    onClose: () => Navigator.of(context).maybePop(),
  ),
);
```

### Auto-Replay on App Launch
The app automatically checks for pending replays on startup:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _maybeAutoReplay(); // Check for pending replays
  runApp(const MyApp());
}
```

### Flow Replayer
```dart
// Replay a flow in app context
await FlowReplayer(
  rootContext: context,
  speed: 1.5,
).replay(flow);
```

## 📁 File Structure

```
lib/
├── recorder/
│   ├── flow_manager_sheet.dart    # Main flow manager UI
│   ├── run_on_next_launch.dart    # Restart & play functionality
│   └── recorder_overlay.dart      # Updated with long-press handler
├── runner/
│   └── flow_replayer.dart         # App context flow replay
├── utils/
│   └── storage_service.dart       # Enhanced with flow management
└── main.dart                      # Auto-replay integration

scripts/
└── flowctl.sh                     # Terminal CLI script
```

## 🎯 Use Cases

### 1. Development Testing
- Record flows during development
- Use "Play now" to quickly test changes
- Adjust speed to test different scenarios

### 2. CI/CD Integration
- Use terminal script in automated tests
- Run flows at different speeds
- Validate app behavior programmatically

### 3. User Acceptance Testing
- Record user workflows
- Replay flows to verify functionality
- Use restart & play for full app lifecycle testing

### 4. Regression Testing
- Save flows as regression tests
- Run flows automatically on app updates
- Speed up testing with faster playback

## 🔄 Flow Chaining (Future Enhancement)

The system is designed to support flow chaining:

```dart
// Future: Chain multiple flows
final compositeFlow = TestFlow(
  flowId: 'composite_test',
  steps: [
    FlowStep(action: FlowAction.runFlow, target: 'login_flow'),
    FlowStep(action: FlowAction.runFlow, target: 'checkout_flow'),
    FlowStep(action: FlowAction.runFlow, target: 'logout_flow'),
  ],
);
```

## 🛠️ Customization

### Custom Flow Actions
Extend the `FlowReplayer` to support custom actions:

```dart
class CustomFlowReplayer extends FlowReplayer {
  @override
  Future<void> _executeStep(FlowStep step) async {
    switch (step.action) {
      case FlowAction.customAction:
        await _executeCustomAction(step);
        break;
      default:
        await super._executeStep(step);
    }
  }
}
```

### Custom Storage
Implement custom storage providers:

```dart
class CustomStorageService extends StorageService {
  @override
  Future<List<FlowFile>> listFlows() async {
    // Custom implementation
  }
}
```

## 🚨 Troubleshooting

### Flow Not Playing
1. Check that the flow JSON is valid
2. Verify widget targets exist in current app state
3. Check console for error messages

### Terminal Script Issues
1. Ensure script is executable: `chmod +x scripts/flowctl.sh`
2. Check flow file path is correct
3. Verify Flutter device is connected

### Restart & Play Not Working
1. Check platform support (iOS/Android)
2. Verify SharedPreferences permissions
3. Check app launch configuration

## 📊 Performance Considerations

- **Speed Control**: Affects both execution and delays
- **Memory Usage**: Large flows may impact performance
- **Storage**: Flows are stored locally, consider cleanup
- **Network**: Terminal integration requires no network

## 🔐 Security Notes

- Flows are stored locally on device
- No sensitive data is transmitted
- Terminal integration uses base64 encoding (not encryption)
- Consider flow content when sharing

---

The Flow Manager provides a complete solution for managing test flows in your Flutter app, from simple playback to advanced automation scenarios.
