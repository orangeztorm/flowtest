import 'package:flutter/foundation.dart';
import '../models/flow_step.dart';
import '../models/test_flow.dart';
import '../models/enums.dart';
import '../models/expectation.dart';
import '../utils/storage_service.dart';

/// Singleton controller for managing flow recording
/// Handles recording state, step collection, and export functionality
class RecorderController {
  static final RecorderController instance = RecorderController._internal();
  RecorderController._internal();

  final List<FlowStep> _steps = [];

  // Observable recording state for UI updates
  final ValueNotifier<bool> recordingNotifier = ValueNotifier(false);

  // Track the last recorded action to avoid duplicates
  FlowStep? _lastStep;
  int _lastStepTimestamp = 0;
  static const int _duplicateThresholdMs =
      100; // Ignore duplicate actions within 100ms

  // Getters
  List<FlowStep> get steps => List.unmodifiable(_steps);
  bool get isRecording => recordingNotifier.value;
  int get stepCount => _steps.length;

  /// Start a new recording session
  void startRecording() {
    recordingNotifier.value = true;
    _steps.clear();
    _lastStep = null;
    _lastStepTimestamp = 0;
    debugPrint('🔴 Recording started');
  }

  /// Stop the current recording session
  void stopRecording() {
    recordingNotifier.value = false;
    debugPrint('⏹️ Recording stopped. ${_steps.length} steps recorded.');
    _printRecordedSteps();
  }

  /// Toggle recording on/off
  void toggleRecording() {
    if (recordingNotifier.value) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  /// Record a new step (with duplicate detection)
  void recordStep(FlowStep step) {
    if (!recordingNotifier.value) return;

    // Check for duplicate steps (same action and target within threshold)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastStep != null &&
        _lastStep!.action == step.action &&
        _lastStep!.target == step.target &&
        (now - _lastStepTimestamp) < _duplicateThresholdMs) {
      debugPrint(
        '⚠️ Skipping duplicate step: ${step.action} -> ${step.target}',
      );
      return;
    }

    _steps.add(step);
    _lastStep = step;
    _lastStepTimestamp = now;

    debugPrint(
      '🔴 Recorded [${_steps.length}]: ${step.action} -> ${step.target}'
      '${step.value != null ? ' (${step.value})' : ''}',
    );
  }

  /// Add an expectation to the last recorded step
  void addExpectationToLastStep(Expectation expectation) {
    if (_steps.isEmpty) return;

    final lastStep = _steps.last;
    final updatedExpectations = [...(lastStep.expects ?? []), expectation];

    _steps[_steps.length - 1] = FlowStep(
      action: lastStep.action,
      target: lastStep.target,
      value: lastStep.value,
      expects: updatedExpectations as List<Expectation>?,
      metadata: lastStep.metadata,
    );

    debugPrint(
      '🔎 Added expectation to step ${_steps.length}: '
      '${expectation.target} ${expectation.condition}',
    );
  }

  /// Insert a wait step
  void insertWaitStep(int milliseconds) {
    if (!recordingNotifier.value) return;

    final waitStep = FlowStep(
      action: FlowAction.wait,
      target: 'wait',
      value: milliseconds.toString(),
    );

    recordStep(waitStep);
  }

  /// Clear all recorded steps
  void clearSteps() {
    _steps.clear();
    _lastStep = null;
    _lastStepTimestamp = 0;
    debugPrint('🗑️ Cleared all recorded steps');
  }

  /// Remove the last recorded step (undo functionality)
  void undoLastStep() {
    if (_steps.isNotEmpty) {
      final removed = _steps.removeLast();
      debugPrint('↩️ Removed step: ${removed.action} -> ${removed.target}');

      if (_steps.isNotEmpty) {
        _lastStep = _steps.last;
      } else {
        _lastStep = null;
      }
    }
  }

  /// Export the recorded flow to JSON
  Map<String, dynamic> exportToJson() {
    final timestamp = DateTime.now();
    return {
      'flowId': 'flow_${timestamp.millisecondsSinceEpoch}',
      'name': 'Recorded Flow ${_formatDateTime(timestamp)}',
      'description': 'Flow recorded on ${_formatDateTime(timestamp)}',
      'steps': _steps.map((step) => step.toJson()).toList(),
      'recordedAt': timestamp.toIso8601String(),
      'metadata': {
        'stepCount': _steps.length,
        'version': '1.0.0',
        'platform': defaultTargetPlatform.toString().split('.').last,
      },
    };
  }

  /// Export and save the flow to storage
  Future<String> exportAndSave() async {
    if (_steps.isEmpty) {
      throw Exception('No steps to export');
    }

    final flowData = exportToJson();
    final testFlow = TestFlow.fromJson(flowData);

    // Use StorageService to save the flow
    final filePath = await StorageService.saveFlow(testFlow);

    debugPrint('📁 Flow exported to: $filePath');
    debugPrint('📊 Total steps: ${_steps.length}');

    return filePath;
  }

  /// Save flow with a custom name
  Future<String> exportAndSaveWithName(String name) async {
    if (_steps.isEmpty) {
      throw Exception('No steps to export');
    }

    final flowData = exportToJson();
    flowData['name'] = name;
    flowData['flowId'] = name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();

    final testFlow = TestFlow.fromJson(flowData);
    final filePath = await StorageService.saveFlowWithName(testFlow, name);

    debugPrint('📁 Flow exported as "$name" to: $filePath');
    return filePath;
  }

  /// Get a summary of the recorded flow
  String getFlowSummary() {
    if (_steps.isEmpty) return 'No steps recorded';

    final actionCounts = <FlowAction, int>{};
    for (final step in _steps) {
      actionCounts[step.action] = (actionCounts[step.action] ?? 0) + 1;
    }

    final summary = StringBuffer();
    summary.writeln('Flow Summary:');
    summary.writeln('• Total steps: ${_steps.length}');

    actionCounts.forEach((action, count) {
      final actionName = action.toString().split('.').last;
      summary.writeln('• $actionName: $count');
    });

    return summary.toString();
  }

  /// Print all recorded steps for debugging
  void _printRecordedSteps() {
    if (_steps.isEmpty) {
      debugPrint('📝 No steps recorded');
      return;
    }

    debugPrint('📝 Recorded Steps:');
    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      final actionName = step.action.toString().split('.').last;
      debugPrint(
        '  ${i + 1}. $actionName -> ${step.target}'
        '${step.value != null ? ' (${step.value})' : ''}',
      );

      if (step.expects != null) {
        for (final exp in step.expects!) {
          final conditionName = exp.condition.toString().split('.').last;
          debugPrint(
            '      ↳ Expect: ${exp.target} $conditionName'
            '${exp.value != null ? ' = ${exp.value}' : ''}',
          );
        }
      }
    }
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Check if we have steps to export
  bool get canExport => _steps.isNotEmpty;

  /// Cleanup method (call in dispose if needed)
  void dispose() {
    recordingNotifier.dispose();
  }
}
