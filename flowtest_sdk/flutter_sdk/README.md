# Flutter Flow Recorder SDK

A Flutter SDK for recording and replaying test flows during development.

## Features

- **Visual Recording**: Record user interactions (taps, text input) during development
- **Flow Export**: Export recorded flows as JSON files
- **Dev Mode Only**: Recording only works in development mode
- **Easy Integration**: Simple overlay widget for existing Flutter apps
- **Robust Hit Testing**: Sophisticated widget detection with overlay filtering
- **Performance Optimized**: Efficient element traversal with bounds checking

## Quick Start

### 1. Wrap Your App with FlowRecorderOverlay

```dart
import 'package:flowtest_sdk/recorder/recorder.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlowRecorderOverlay(
        enabled: true, // Enable in dev mode
        child: MyHomePage(),
      ),
    );
  }
}
```

### 2. Add Recording Controls

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YourAppContent(),
      floatingActionButton: const RecorderToggle(), // Add recording controls
    );
  }
}
```

### 3. Record Your Flow

1. Tap the blue record button to start recording
2. Interact with your app (tap buttons, enter text)
3. Tap the red stop button to stop recording
4. Tap the green export button to save the flow as JSON

## How It Works

### Recording Process

1. **Tap Detection**: The overlay captures tap events and identifies the target widget using sophisticated hit testing
2. **Text Input**: When a text field loses focus, the input value is recorded from the widget's controller
3. **Target Identification**: Widgets are identified by:
   - Keys (e.g., `@email_field`)
   - Text content (e.g., `text:Login`)
   - Button text (e.g., `button:Continue`)
   - Input labels (e.g., `input:Email`)

### Hit Testing Implementation

The recorder uses **Element tree traversal** for robust widget detection:

- **Works in debug AND release builds** (no reliance on `debugCreator`)
- **Filters out recorder UI** (overlay, toggle buttons)
- **Bounds checking** ensures widgets are actually visible
- **Performance monitoring** with `Timeline.timeSync`
- **Deepest match detection** for precise widget identification

See [HIT_TESTING.md](lib/recorder/HIT_TESTING.md) for detailed implementation details.

### Generated Flow JSON

```json
{
  "flowId": "recorded_flow_1234567890",
  "recordedAt": "2024-01-01T12:00:00.000Z",
  "steps": [
    {
      "action": "tap",
      "target": "@email_field"
    },
    {
      "action": "input",
      "target": "input:Email",
      "value": "user@example.com"
    },
    {
      "action": "tap",
      "target": "@login_button"
    }
  ]
}
```

## Advanced Features

### Widget Target Extraction

The recorder intelligently identifies widgets using a priority system:

1. **Keys** (most reliable): `@email_field`
2. **Text content**: `text:Login`
3. **Button text**: `button:Continue`
4. **Input labels**: `input:Email`
5. **Widget type**: `type:ElevatedButton`

### Performance Optimizations

- **Element traversal**: ~0.1ms for typical widget trees
- **Bounds checking**: Negligible CPU impact
- **Memory efficient**: No object creation during hit testing
- **Timeline monitoring**: Built-in performance tracking

### Edge Cases Handled

- **Nested gestures**: Tapping Icon inside Button records the Button
- **Overlay filtering**: Recorder UI is automatically excluded
- **Bounds validation**: Only visible widgets are recorded
- **Controller access**: Text input captured from widget controllers

## Development Status

### ✅ Completed
- [x] Flow model with JSON serialization
- [x] RecorderOverlay for capturing interactions
- [x] RecorderController for managing recording state
- [x] Export functionality to JSON files
- [x] Example app demonstrating usage
- [x] Robust hit testing with Element traversal
- [x] Performance monitoring and optimization
- [x] Comprehensive documentation

### 🔄 Next Steps
- [ ] FlowRunner for replaying recorded flows
- [ ] TargetResolver for finding widgets during playback
- [ ] Integration test examples
- [ ] Enhanced parent traversal for nested widgets
- [ ] LongPress and Scroll gesture recording
- [ ] Platform view support (Google Maps, WebView)

## Example

See the `example/` directory for a complete working example of the recorder in action.

## Documentation

- [Hit Testing Implementation](lib/recorder/HIT_TESTING.md) - Detailed explanation of widget detection
- [API Reference](lib/recorder/) - Complete API documentation

## License

This project is part of the FlowTest SDK development. 