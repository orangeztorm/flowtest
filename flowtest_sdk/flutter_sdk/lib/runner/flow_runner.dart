import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import '../models/flow_step.dart';
import '../models/test_flow.dart';
import '../models/enums.dart';
import '../models/expectation.dart';
import '../utils/flow_logger.dart';
import 'target_resolver.dart';
import 'expectation_matcher.dart';

/// Executes recorded test flows using WidgetTester with logging and screenshot support
class FlowRunner {
  final WidgetTester tester;

  FlowRunner(this.tester, {bool verbose = kDebugMode}) {
    FlowLogger.verbose = verbose;
  }

  /// Run a complete test flow
  Future<void> run(TestFlow flow) async {
    FlowLogger.info('🚀 Starting flow: ${flow.flowId}');
    final matcher = ExpectationMatcher(tester);

    for (var i = 0; i < flow.steps.length; i++) {
      final step = flow.steps[i];
      FlowLogger.step(
        '[${i + 1}/${flow.steps.length}] ${step.action} on "${step.target}"',
      );

      try {
        await _executeStep(step);

        // Execute chained expectations right after the action
        if (step.expects != null) {
          FlowLogger.expectation(
            'Verifying ${step.expects!.length} expectation(s)...',
          );
          for (final exp in step.expects!) {
            await matcher.match(exp);
          }
        }

        FlowLogger.success('Step ${i + 1}/${flow.steps.length} passed');
      } catch (e, st) {
        // Take screenshot on failure
        final screenshotPath = await _takeScreenshot('failure_step_${i + 1}');
        FlowLogger.error(
          'Step ${i + 1}/${flow.steps.length} failed (${step.action} → ${step.target})',
        );
        FlowLogger.error('Screenshot saved to: $screenshotPath');

        throw TestFailure(
          'Step ${i + 1}/${flow.steps.length} failed (${step.action} → ${step.target}). Screenshot: $screenshotPath\n\nOriginal Error: $e\n$st',
        );
      }
    }

    FlowLogger.success('🎉 Flow "${flow.flowId}" completed successfully!');
  }

  /// Take a screenshot on test failure for debugging
  Future<String> _takeScreenshot(String name) async {
    try {
      final binding = WidgetsBinding.instance;

      // Only capture actual screenshots in integration test environment
      // Use safer type checking instead of string comparison
      final bindingTypeName = binding.runtimeType.toString();
      if (bindingTypeName.contains('IntegrationTest')) {
        final directory = await getApplicationDocumentsDirectory();
        final screenshotsDir = Directory(
          '${directory.path}/flowtest_screenshots',
        );
        if (!await screenshotsDir.exists()) {
          await screenshotsDir.create(recursive: true);
        }
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${screenshotsDir.path}/${name}_$timestamp.png';

        // Use dynamic call for integration test screenshot
        try {
          await (binding as dynamic).takeScreenshot(path);
          return path;
        } catch (e) {
          FlowLogger.warning('Integration test screenshot failed: $e');
        }
      }

      // Fallback for regular tests - just log the intended path
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/flowtest_screenshots/${name}_${DateTime.now().millisecondsSinceEpoch}.png';
      FlowLogger.warning(
        'Screenshot capture only works in integration tests. Would save to: $path',
      );
      return path;
    } catch (e) {
      FlowLogger.warning('Screenshot path generation failed: $e');
      return 'Screenshot failed: $e';
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
    final finder = TargetResolver.resolve(step.target);

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
