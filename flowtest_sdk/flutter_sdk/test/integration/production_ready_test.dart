import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/flow_logger.dart';
import '../../lib/runner/flow_runner.dart';
import '../../lib/models/test_flow.dart';
import '../../lib/models/flow_step.dart';
import '../../lib/models/enums.dart';
import '../../../lib/main.dart' as app;

void main() {
  group('Production-Ready FlowRunner Tests', () {
    testWidgets('Test verbose defaults to kDebugMode', (
      WidgetTester tester,
    ) async {
      // Create runner with default verbose setting
      FlowRunner(tester);

      // In debug mode, verbose should be true
      expect(FlowLogger.verbose, isTrue);

      // Test with explicit verbose setting
      FlowRunner(tester, verbose: false);
      expect(FlowLogger.verbose, isFalse);
    });

    testWidgets('Test step progress logging', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Create a simple flow for testing
      final testFlow = TestFlow(
        flowId: 'test_progress',
        steps: [
          FlowStep(action: FlowAction.wait, target: 'test', value: '100'),
          FlowStep(action: FlowAction.wait, target: 'test', value: '100'),
          FlowStep(action: FlowAction.wait, target: 'test', value: '100'),
        ],
      );

      // Enable verbose logging to see progress
      final runner = FlowRunner(tester, verbose: true);

      try {
        await runner.run(testFlow);
        // Should complete successfully with progress logging
        expect(true, isTrue);
      } catch (e) {
        // Unexpected failure
        fail('Flow should have completed successfully: $e');
      }
    });

    testWidgets('Test ANSI color support detection', (
      WidgetTester tester,
    ) async {
      // Test that logger methods work without throwing errors
      FlowLogger.enableVerbose();

      FlowLogger.info('Testing ANSI color support');
      FlowLogger.success('Colors should work on supported terminals');
      FlowLogger.warning('Graceful fallback on unsupported terminals');
      FlowLogger.error('Error messages are always shown');

      // Test the colorization doesn't crash
      expect(true, isTrue);
    });

    testWidgets('Test screenshot path generation', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Create a flow that will fail to test screenshot capture
      final failingFlow = TestFlow(
        flowId: 'failing_test',
        steps: [
          FlowStep(action: FlowAction.tap, target: '@nonexistent_button'),
        ],
      );

      final runner = FlowRunner(tester, verbose: true);

      try {
        await runner.run(failingFlow);
        fail('Flow should have failed due to nonexistent target');
      } catch (e) {
        // Expected failure - check that error contains screenshot info
        expect(e.toString(), contains('Screenshot'));
        expect(e.toString(), contains('failure_step_1'));
      }
    });
  });
}
