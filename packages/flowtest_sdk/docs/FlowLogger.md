# FlowLogger

Professional development logger for FlowTest SDK with colored console output and step-by-step flow execution tracking.

## Features

- **Colored Console Output**: Visual distinction between different log levels using ANSI colors
- **Verbose Control**: Global flag to control logging verbosity without changing code
- **Step Tracking**: Specialized logging for flow execution steps and expectations
- **Always-Show Errors**: Critical errors are always displayed regardless of verbose setting
- **Screenshot Integration**: Automatic screenshot capture on flow failures

## Usage

### Basic Logging

```dart
import '../utils/flow_logger.dart';

// Enable verbose logging (shows info, success, warning, step, expectation)
FlowLogger.enableVerbose();

// Different log levels
FlowLogger.info('Flow started');
FlowLogger.success('Step completed successfully');
FlowLogger.warning('Retrying operation');
FlowLogger.error('Critical failure occurred');  // Always shown
FlowLogger.step('Executing tap on login button');
FlowLogger.expectation('Verifying 3 expectations...');

// Disable verbose logging (only errors will show)
FlowLogger.disableVerbose();
```

### Integration with FlowRunner

```dart
// Enable verbose logging for detailed step-by-step output
final runner = FlowRunner(tester, verbose: true);
await runner.run(flow);

// Disable logging for production/CI environments
final runner = FlowRunner(tester, verbose: false);
await runner.run(flow);
```

### Sample Output

When verbose logging is enabled, you'll see colored output like:

```
[FlowTest] 🚀 Starting flow: Login Flow
[FlowTest] ▶️ Step #1: tap on "@login_button"
[FlowTest] 🔎 Verifying 2 expectation(s)...
[FlowTest] ✅ Step #1 passed
[FlowTest] ▶️ Step #2: input on "@email_field"
[FlowTest] ✅ Step #2 passed
[FlowTest] 🎉 Flow "Login Flow" completed successfully!
```

On failure, you'll see:

```
[FlowTest] ❌ Step #3 failed (tap → "@submit_button")
[FlowTest] ❌ Screenshot saved to: /path/to/failure_step_3_1234567890.png
```

## Log Levels

| Level           | Color  | When Shown   | Purpose                  |
| --------------- | ------ | ------------ | ------------------------ |
| `info()`        | Cyan   | Verbose only | General information      |
| `success()`     | Green  | Verbose only | Successful operations    |
| `warning()`     | Yellow | Verbose only | Non-critical issues      |
| `error()`       | Red    | Always       | Critical failures        |
| `step()`        | Blue   | Verbose only | Flow step execution      |
| `expectation()` | Cyan   | Verbose only | Expectation verification |

## Configuration

### Global Verbose Control

```dart
// Enable for development/debugging
FlowLogger.verbose = true;
FlowLogger.enableVerbose();  // Same as above + confirmation log

// Disable for production/CI
FlowLogger.verbose = false;
FlowLogger.disableVerbose();  // Same as above
```

### Per-Runner Control

```dart
// Verbose runner (default)
final runner = FlowRunner(tester, verbose: true);

// Quiet runner
final runner = FlowRunner(tester, verbose: false);
```

## Integration with Screenshots

The FlowLogger automatically integrates with FlowRunner's screenshot-on-failure feature:

1. When a flow step fails, a screenshot is automatically captured
2. The screenshot path is logged using `FlowLogger.error()`
3. Screenshots are saved to `ApplicationDocumentsDirectory/flowtest_screenshots/`
4. Filenames include step number and timestamp for easy identification

## Best Practices

### Development

- Enable verbose logging to see detailed step execution
- Use `FlowLogger.info()` for flow progress tracking
- Use `FlowLogger.warning()` for non-critical issues

### Production/CI

- Disable verbose logging to reduce log noise
- Only critical errors will be shown
- Screenshots will still be captured on failures

### Testing

```dart
testWidgets('My flow test', (tester) async {
  // Enable logging for this specific test
  final runner = FlowRunner(tester, verbose: true);

  try {
    await runner.run(myFlow);
  } catch (e) {
    // Error details and screenshot path will be automatically logged
    rethrow;
  }
});
```
