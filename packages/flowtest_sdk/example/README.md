# FlowTest SDK Examples

This directory contains example applications demonstrating how to use the FlowTest SDK.

## Current Examples

### basic_example (main.dart)

A simple Flutter app wrapped with `FlowRecorderOverlay` to demonstrate:

- Basic SDK integration
- Recording setup during development
- Simple UI interactions for testing

## Running Examples

```bash
cd example
flutter run
```

## Recording Flows

1. Run the example app in debug mode
2. Look for the red "REC" button overlay
3. Tap to start/stop recording
4. Recorded flows will be saved to `test_flows/` directory

## Future Examples

This directory is prepared for additional demo applications such as:

- Weather app with API integration
- E-commerce flow examples
- Form validation scenarios
- Navigation patterns

## Integration Testing

See the `integration_test/` directory in the parent package for examples of how to replay recorded flows in automated tests.
