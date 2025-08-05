# StorageService

Professional cross-platform storage service for FlowTest SDK.

## Features

- **Cross-Platform Safe Storage**: Uses `path_provider` to find OS-appropriate directories
- **Asset Loading**: Load test flows from app bundles for integration tests
- **Error Handling**: Comprehensive error handling with `StorageException`
- **File Management**: List, save, load, and delete flow files

## Usage

### Saving Flows (from Recorder)

```dart
import '../utils/storage_service.dart';
import '../models/test_flow.dart';

// Save a flow with auto-generated filename
final filePath = await StorageService.saveFlow(testFlow);

// Save with specific filename
final filePath = await StorageService.saveFlowWithName(testFlow, 'login_flow');
```

### Loading Flows (for Runner)

```dart
// Load from app assets (recommended for integration tests)
final flow = await StorageService.loadFlowFromAsset('flutter_sdk/test_flows/login_flow.json');

// Load from device storage
final flow = await StorageService.loadFlow('login_flow.json');
```

### File Management

```dart
// List all saved flows
final flowFiles = await StorageService.listSavedFlows();

// Get directory path for debugging
final dirPath = await StorageService.getFlowsDirectoryPath();

// Delete a flow
await StorageService.deleteFlow('old_flow.json');
```

## Integration with FlowLoader

The `FlowLoader` class now provides convenient methods that use `StorageService`:

```dart
// Load from assets (for tests)
final flow = await FlowLoader.fromAsset('flutter_sdk/test_flows/login_flow.json');

// Load from storage (for saved flows)
final flow = await FlowLoader.fromStorage('login_flow.json');
```

## Asset Configuration

To use asset loading, ensure your `pubspec.yaml` includes:

```yaml
flutter:
  assets:
    - flutter_sdk/test_flows/
```

## Error Handling

```dart
try {
  final flow = await StorageService.loadFlow('nonexistent.json');
} on StorageException catch (e) {
  print('Storage error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}

try {
  final flow = FlowLoader.fromJsonString(invalidJson);
} on FlowParseException catch (e) {
  print('Parse error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Path Safety

Flow IDs are automatically URL-encoded to handle special characters safely:

```dart
// Flow ID: "Login / Sign-up Flow" becomes filename: "Login%20%2F%20Sign-up%20Flow_1234567890.json"
final flow = TestFlow(flowId: 'Login / Sign-up Flow', steps: []);
await StorageService.saveFlow(flow);
```
