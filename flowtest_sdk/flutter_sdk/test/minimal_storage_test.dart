import 'package:flutter_test/flutter_test.dart';
import '../lib/models/test_flow.dart';
import '../lib/models/flow_step.dart';
import '../lib/models/enums.dart';
import '../lib/utils/storage_service.dart';

void main() {
  group('StorageService Platform Channel Test', () {
    test('Should handle platform channel unavailability gracefully', () async {
      // Create a simple test flow
      final testFlow = TestFlow(
        flowId: 'simple_test',
        steps: [
          FlowStep(action: FlowAction.wait, target: 'test', value: '100'),
        ],
      );

      // Test save operation
      final savedPath = await StorageService.saveFlowWithName(
        testFlow,
        'simple_test_flow',
      );

      print('Saved to: $savedPath');
      expect(savedPath, isNotNull);

      // Test load operation
      final loadedFlow = await StorageService.loadFlow('simple_test_flow.json');
      expect(loadedFlow, isNotNull);
      expect(loadedFlow!.flowId, equals('simple_test'));

      print('✅ StorageService platform channel fallback works!');
    });
  });
}
