import 'package:flutter_test/flutter_test.dart';
import '../../example/main.dart' as app;
import '../../lib/runner/runner.dart';

void main() {
  group('Flow Playback Tests', () {
    testWidgets('run recorded login flow', (tester) async {
      // Launch the example app
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();

      // Load and run a recorded flow
      final flow = await FlowLoader.fromFile('test_flows/login_flow.json');
      final runner = FlowRunner(tester);

      await runner.run(flow);

      // Additional assertions can be added here
      expect(find.text('Login successful'), findsOneWidget);
    });

    testWidgets('run flow with expectations', (tester) async {
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();

      // This would be a flow with embedded expectations
      final flow = await FlowLoader.fromFile(
        'test_flows/flow_with_expectations.json',
      );
      final runner = FlowRunner(tester);

      await runner.run(flow);
    });

    testWidgets('run multiple flows from directory', (tester) async {
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();

      // Load all flows from a directory
      final flows = await FlowLoader.fromDirectory('test_flows');
      final runner = FlowRunner(tester);

      for (final flow in flows) {
        await runner.run(flow);
        // Reset app state between flows if needed
        await tester.pumpWidget(app.MyApp());
        await tester.pumpAndSettle();
      }
    });
  });
}
