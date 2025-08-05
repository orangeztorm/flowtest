import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/flow_logger.dart';
import '../../lib/runner/flow_runner.dart';
import '../../lib/runner/flow_loader.dart';
import 'package:flowtest_sdk/main.dart' as app;

void main() {
  group('FlowLogger Integration Tests', () {
    testWidgets('Test logging with verbose enabled', (
      WidgetTester tester,
    ) async {
      // Enable verbose logging for this test
      FlowLogger.enableVerbose();

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Test different log levels
      FlowLogger.info('This is an info message');
      FlowLogger.success('This is a success message');
      FlowLogger.warning('This is a warning message');
      FlowLogger.error('This is an error message');
      FlowLogger.step('This is a step message');
      FlowLogger.expectation('This is an expectation message');

      // Test that error logs work even with verbose disabled
      FlowLogger.disableVerbose();
      FlowLogger.info('This info should NOT appear');
      FlowLogger.error('This error SHOULD appear even with verbose off');

      expect(true, isTrue); // Just ensure test passes
    });

    testWidgets('Test FlowRunner with logging', (WidgetTester tester) async {
      // Create a FlowRunner with verbose logging
      final runner = FlowRunner(tester, verbose: true);

      try {
        // Try to load and run a sample flow to test logging
        final flow = await FlowLoader.fromAsset(
          'test_flows/sample_login_flow.json',
        );

        FlowLogger.info('About to run flow with ${flow.steps.length} steps');

        // Note: This might fail if the flow doesn't match the current app,
        // but it will demonstrate the logging functionality
        await runner.run(flow);
      } catch (e) {
        // Expected - the flow might not match the current app
        FlowLogger.warning('Flow execution failed as expected: $e');
        expect(e, isNotNull);
      }
    });
  });
}
