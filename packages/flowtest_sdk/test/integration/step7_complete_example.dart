import 'dart:io';

import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';

import '../../lib/utils/flow_logger.dart';
import '../../lib/runner/flow_runner.dart';
import '../../lib/runner/flow_loader.dart';
import '../../lib/utils/storage_service.dart';
import '../../lib/models/test_flow.dart';
import '../../lib/models/flow_step.dart';
import '../../lib/models/enums.dart';
import '../../lib/models/expectation.dart';
import 'package:flowtest_sdk/main.dart' as app;
import '../test_helpers.dart';

const kSafeSettleTimeout = Duration(seconds: 5);

Future<void> _launchDemo(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(kSafeSettleTimeout);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  // 🔄 Use the integration binding for proper device testing
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// ---- GLOBAL CLEAN-UP --------------------------------------------------
  tearDownAll(() {
    // Ask StorageService to dispose its cached temp dir
    StorageService.cleanupTempDir();

    // Belt-and-suspenders sweep in case other tests created temp dirs
    try {
      Directory.systemTemp
          .listSync()
          .whereType<Directory>()
          .firstWhereOrNull((d) => d.path.contains('flowtest_'))
          ?.deleteSync(recursive: true);
    } catch (_) {
      // Ignore cleanup errors
    }
  });

  /// ---- TESTS ------------------------------------------------------------
  robustTestGroup('Step 7: Example Integration Test', () {
    integrationTest('Load flow from assets and replay with logging', (
      WidgetTester tester,
    ) async {
      await _launchDemo(tester);

      final flow = await FlowLoader.fromAsset(
        'test_flows/sample_login_flow.json',
      );
      expect(flow.steps, isNotEmpty);

      final runner = FlowRunner(tester, verbose: true);
      await runner.run(flow);

      FlowLogger.success('✅ Flow executed successfully in integration test!');
    });

    integrationTest('Create, save, and replay a custom flow', (
      WidgetTester tester,
    ) async {
      await _launchDemo(tester);

      final customFlow = TestFlow(
        flowId: 'integration_test_flow',
        steps: [
          FlowStep(
            action: FlowAction.wait,
            target: 'app_startup',
            value: '500',
          ),
          FlowStep(
            action: FlowAction.expect,
            target: 'type:Scaffold',
            expects: [
              Expectation(
                target: 'type:Scaffold',
                condition: ExpectCondition.exists,
              ),
            ],
          ),
        ],
      );

      final savedPath = await StorageService.saveFlowWithName(
        customFlow,
        'integration_test',
      );
      FlowLogger.info('Saved custom flow to: $savedPath');

      final loadedFlow = await StorageService.loadFlow('integration_test.json');
      expect(loadedFlow, isNotNull);
      expect(loadedFlow!.steps.length, customFlow.steps.length);

      final runner = FlowRunner(tester, verbose: true);
      await runner.run(loadedFlow);

      FlowLogger.success('✅ Custom flow save/load/replay cycle completed!');
    });

    integrationTest('Test screenshot capture on intentional failure', (
      WidgetTester tester,
    ) async {
      await _launchDemo(tester);

      final failingFlow = TestFlow(
        flowId: 'failing_test_flow',
        steps: [
          FlowStep(action: FlowAction.tap, target: '@nonexistent_widget_12345'),
        ],
      );

      final runner = FlowRunner(tester, verbose: true);

      expect(
        () async => await runner.run(failingFlow),
        throwsA(
          predicate<Object>(
            (e) =>
                e.toString().contains('Screenshot') &&
                e.toString().contains('@nonexistent_widget_12345'),
          ),
        ),
      );

      FlowLogger.success('✅ Screenshot capture triggered as expected');
    });

    integrationTest('Test storage service operations', (
      WidgetTester tester,
    ) async {
      // Directory path
      final dirPath = await StorageService.getFlowsDirectoryPath();
      expect(dirPath, isNotEmpty);

      // List existing flows
      final existing = await StorageService.listSavedFlows();
      FlowLogger.info('Existing flows: $existing');

      // Save a flow with special characters
      final special = TestFlow(
        flowId: 'Test Flow / With Special Characters!',
        steps: [
          FlowStep(action: FlowAction.wait, target: 'test', value: '100'),
        ],
      );
      final savedPath = await StorageService.saveFlow(special);
      expect(savedPath, contains('Test%20Flow'));

      FlowLogger.success('✅ Storage service operations completed!');
    });
  });
}
