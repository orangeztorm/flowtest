import 'package:flutter_test/flutter_test.dart';
import '../models/flow_step.dart';
import '../models/test_flow.dart';
import '../models/enums.dart';
import '../models/expectation.dart';
import 'finder_factory.dart';
import 'expectation_matcher.dart';

/// Executes recorded test flows using WidgetTester
class FlowRunner {
  final WidgetTester tester;

  FlowRunner(this.tester);

  /// Run a complete test flow
  Future<void> run(TestFlow flow) async {
    final matcher = ExpectationMatcher(tester);

    for (var i = 0; i < flow.steps.length; i++) {
      final step = flow.steps[i];

      try {
        await _executeStep(step);

        // Execute chained expectations right after the action
        if (step.expects != null) {
          for (final exp in step.expects!) {
            await matcher.match(exp);
          }
        }
      } catch (e, st) {
        // Optionally: take screenshot here in future
        throw TestFailure(
          'Step #$i failed (${step.action} → ${step.target}):\n$e\n$st',
        );
      }
    }
  }

  /// Scrolls a widget into view before interaction
  Future<void> _scrollIntoView(Finder f) async {
    if (!tester.any(f)) throw TestFailure('Target not found: $f');
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
  }

  /// Waits until all expectations pass or timeout
  Future<void> _waitUntil(
    List<Expectation> expects, {
    required int timeoutMs,
  }) async {
    final matcher = ExpectationMatcher(tester);
    final sw = Stopwatch()..start();
    while (sw.elapsedMilliseconds < timeoutMs) {
      try {
        await matcher.matchAll(expects);
        return; // success
      } catch (_) {
        /* ignore and retry */
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    throw TestFailure('wait-until timed out after $timeoutMs ms');
  }

  /// Execute a single flow step
  Future<void> _executeStep(FlowStep step) async {
    final finder = FinderFactory.fromTarget(step.target);

    // Auto-scroll for interactive actions
    if ({
      FlowAction.tap,
      FlowAction.longPress,
      FlowAction.input,
    }.contains(step.action)) {
      await _scrollIntoView(finder);
    }

    switch (step.action) {
      case FlowAction.tap:
        await tester.tap(finder);
        break;
      case FlowAction.longPress:
        await tester.longPress(finder);
        break;
      case FlowAction.scroll:
        final delta = double.tryParse(step.value ?? '0') ?? 0.0;
        await tester.drag(finder, Offset(0, -delta));
        break;
      case FlowAction.input:
        await tester.enterText(finder, step.value ?? '');
        break;
      case FlowAction.wait:
        if (step.expects?.isNotEmpty ?? false) {
          await _waitUntil(
            // step.expects! as List<Expectation>,
            step.expects ?? [],
            timeoutMs: int.tryParse(step.value ?? '5000') ?? 5000,
          );
        } else {
          await tester.pump(
            Duration(milliseconds: int.tryParse(step.value ?? '0') ?? 0),
          );
        }
        break;
      case FlowAction.expect:
        // handled via chained expects; nothing to do here
        break;
    }

    // Ensure UI has settled before next step
    await tester.pumpAndSettle();
  }

  /// Run a single step (useful for debugging)
  Future<void> runStep(FlowStep step) async {
    await _executeStep(step);
  }

  /// Run multiple steps (useful for partial flows)
  Future<void> runSteps(List<FlowStep> steps) async {
    for (final step in steps) {
      await runStep(step);
    }
  }
}
