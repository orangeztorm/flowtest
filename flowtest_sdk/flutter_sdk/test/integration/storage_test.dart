import 'package:flutter_test/flutter_test.dart';
import 'package:flowtest_sdk/main.dart' as app;

import '../../lib/runner/flow_loader.dart';
import '../../lib/runner/flow_runner.dart';
import '../../lib/utils/storage_service.dart';

void main() {
  group('StorageService Integration Tests', () {
    testWidgets('Load flow from assets and run it', (
      WidgetTester tester,
    ) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      try {
        // Load a flow from assets using the new method
        final flow = await FlowLoader.fromAsset(
          'test_flows/sample_login_flow.json',
        );

        // Verify the flow loaded correctly
        expect(flow.steps, isNotEmpty);
        print('Successfully loaded flow: ${flow.flowId}');
        print('Flow has ${flow.steps.length} steps');

        // Create and run the flow
        final runner = FlowRunner(tester);
        await runner.run(flow);

        print('✅ Flow executed successfully!');
      } catch (e) {
        print('❌ Test failed: $e');
        rethrow;
      }
    });

    testWidgets('Storage service directory operations', (
      WidgetTester tester,
    ) async {
      try {
        // Get the flows directory path
        final dirPath = await StorageService.getFlowsDirectoryPath();
        print('Flows directory: $dirPath');

        // List any existing flows
        final existingFlows = await StorageService.listSavedFlows();
        print('Existing flows: ${existingFlows.length}');

        for (final flowName in existingFlows) {
          print('  - $flowName');
        }

        expect(dirPath, isNotEmpty);
        print('✅ Storage service operations working correctly!');
      } catch (e) {
        print('❌ Storage test failed: $e');
        rethrow;
      }
    });
  });
}
