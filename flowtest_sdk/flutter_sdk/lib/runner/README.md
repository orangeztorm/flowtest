# FlowRunner - Playback Engine

The FlowRunner is the playback engine that executes recorded test flows during integration tests. It loads JSON flow files and replays the recorded user interactions using Flutter's WidgetTester.

## Overview

```
JSON Flow File → FlowLoader → TestFlow Model → FlowRunner → WidgetTester Actions
```

## Quick Start

### 1. Basic Usage

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flowtest_sdk/runner/runner.dart';

testWidgets('run recorded flow', (tester) async {
  // Launch your app
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  // Load and run a recorded flow
  final flow = await FlowLoader.fromFile('test_flows/login_flow.json');
  final runner = FlowRunner(tester);
  await runner.run(flow);
});
```

### 2. Integration Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flowtest_sdk/runner/runner.dart';

void main() {
  group('Flow Playback Tests', () {
    testWidgets('login flow', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      final flow = await FlowLoader.fromFile('test_flows/login_flow.json');
      final runner = FlowRunner(tester);
      
      await runner.run(flow);
      
      // Additional assertions
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

## Components

### FlowLoader

Loads TestFlow objects from JSON files:

```dart
// Load from file
final flow = await FlowLoader.fromFile('path/to/flow.json');

// Load from JSON string
final flow = FlowLoader.fromJsonString(jsonString);

// Load all flows from directory
final flows = await FlowLoader.fromDirectory('test_flows/');
```

### FinderFactory

Converts target strings to Flutter test Finders:

```dart
// Supported target formats:
final finder = FinderFactory.fromTarget('@email_field');     // Key
final finder = FinderFactory.fromTarget('text:Login');       // Text content
final finder = FinderFactory.fromTarget('button:Submit');    // Button text
final finder = FinderFactory.fromTarget('input:Email');      // Input field
final finder = FinderFactory.fromTarget('type:IconButton');  // Widget type
```

### ExpectationMatcher

Handles assertions for expectations:

```dart
final matcher = ExpectationMatcher(tester);

// Match single expectation
await matcher.match(expectation);

// Match multiple expectations
await matcher.matchAll(expectations);
```

### FlowRunner

Orchestrates the execution of flow steps:

```dart
final runner = FlowRunner(tester);

// Run complete flow
await runner.run(flow);

// Run single step
await runner.runStep(step);

// Run multiple steps
await runner.runSteps(steps);
```

## Supported Actions

### 1. Tap
```json
{
  "action": "tap",
  "target": "@login_button"
}
```

### 2. Input
```json
{
  "action": "input",
  "target": "input:Email",
  "value": "user@example.com"
}
```

### 3. Long Press
```json
{
  "action": "longPress",
  "target": "@menu_button"
}
```

### 4. Scroll
```json
{
  "action": "scroll",
  "target": "@list_view",
  "value": "300"
}
```

### 5. Wait
```json
{
  "action": "wait",
  "value": "1000"
}
```

## Expectations

### Chained Expectations

Expectations can be chained to flow steps:

```json
{
  "action": "tap",
  "target": "@login_button",
  "expects": [
    {
      "target": "text:Login successful",
      "condition": "isVisible"
    },
    {
      "target": "@welcome_screen",
      "condition": "exists"
    }
  ]
}
```

### Supported Conditions

- `isVisible` - Widget is visible (findsOneWidget)
- `isHidden` - Widget is not visible (findsNothing)
- `exists` - Widget exists (findsWidgets)
- `notExists` - Widget doesn't exist (findsNothing)
- `isEnabled` - Widget is enabled
- `isDisabled` - Widget is disabled
- `hasText` - Widget has exact text
- `containsText` - Widget contains text
- `matchesRegex` - Widget text matches regex

## Target Formats

### 1. Keys (@keyName)
```dart
// Widget: ElevatedButton(key: Key('login_btn'))
// Target: @login_btn
```

### 2. Text Content (text:content)
```dart
// Widget: Text('Login')
// Target: text:Login
```

### 3. Button Text (button:text)
```dart
// Widget: ElevatedButton(child: Text('Submit'))
// Target: button:Submit
```

### 4. Input Fields (input:label)
```dart
// Widget: TextField(decoration: InputDecoration(labelText: 'Email'))
// Target: input:Email
```

### 5. Widget Types (type:WidgetName)
```dart
// Widget: IconButton()
// Target: type:IconButton
```

## Error Handling

The FlowRunner provides detailed error messages:

```
Step #3 failed (tap → @login_button):
No widgets found matching find.byKey(ValueKey('login_button'))
```

## Advanced Usage

### Running Multiple Flows

```dart
final flows = await FlowLoader.fromDirectory('test_flows/');
final runner = FlowRunner(tester);

for (final flow in flows) {
  await runner.run(flow);
  // Reset app state if needed
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
}
```

### Partial Flow Execution

```dart
final flow = await FlowLoader.fromFile('test_flows/long_flow.json');
final runner = FlowRunner(tester);

// Run first 3 steps
await runner.runSteps(flow.steps.take(3).toList());

// Run specific step
await runner.runStep(flow.steps[5]);
```

### Custom Expectations

```dart
final matcher = ExpectationMatcher(tester);

// Create custom expectation
final expectation = Expectation(
  target: '@my_widget',
  condition: ExpectCondition.hasText,
  value: 'Expected Text',
);

await matcher.match(expectation);
```

## Best Practices

### 1. Use Keys for Reliable Targeting
```dart
// Good: Use keys for important widgets
ElevatedButton(key: Key('login_btn'), child: Text('Login'))

// Target: @login_btn
```

### 2. Add Expectations for Validation
```json
{
  "action": "tap",
  "target": "@submit_button",
  "expects": [
    {
      "target": "text:Success",
      "condition": "isVisible"
    }
  ]
}
```

### 3. Use Wait Steps for Async Operations
```json
{
  "action": "wait",
  "value": "2000"
}
```

### 4. Handle Dynamic Content
```json
{
  "action": "tap",
  "target": "button:Continue",
  "expects": [
    {
      "target": "text:",
      "condition": "containsText"
    }
  ]
}
```

## Troubleshooting

### Common Issues

1. **Widget Not Found**
   - Check target format
   - Verify widget exists in current screen
   - Use `tester.pumpAndSettle()` to wait for animations

2. **Timing Issues**
   - Add wait steps for async operations
   - Use expectations to wait for specific conditions
   - Ensure UI has settled before next step

3. **Text Matching**
   - Use exact text for `hasText`
   - Use partial text for `containsText`
   - Use regex for `matchesRegex`

### Debug Tips

```dart
// Print widget tree for debugging
print(tester.getSemantics(find.byType(MaterialApp)));

// Check if widget exists
expect(find.byKey(Key('my_widget')), findsOneWidget);

// Wait for specific condition
await tester.pumpUntil(() => find.text('Loaded').evaluate().isNotEmpty);
```

## Performance Considerations

- **Flow Loading**: JSON parsing is fast for typical flows
- **Widget Finding**: Finder creation is negligible
- **UI Settling**: `pumpAndSettle()` can take time for complex animations
- **Memory**: Flows are loaded on-demand and can be garbage collected

## Future Enhancements

- **Condition-based waits**: Wait until expectation is met
- **Screenshot on failure**: Automatic screenshots for failed steps
- **Retry logic**: Retry failed steps with exponential backoff
- **Parallel execution**: Run multiple flows in parallel
- **Performance profiling**: Measure step execution times 