import '../models/flow_step.dart';

class RecorderController {
  static final RecorderController instance = RecorderController._internal();
  RecorderController._internal();

  final List<FlowStep> _steps = [];
  bool _isRecording = false;

  List<FlowStep> get steps => List.unmodifiable(_steps);
  bool get isRecording => _isRecording;

  void startRecording() {
    _isRecording = true;
    _steps.clear();
  }

  void stopRecording() {
    _isRecording = false;
  }

  void recordStep(FlowStep step) {
    if (_isRecording) {
      _steps.add(step);
      print(
        '🔴 Recorded: ${step.action} -> ${step.target}${step.value != null ? ' (${step.value})' : ''}',
      );
    }
  }

  void clearSteps() {
    _steps.clear();
  }

  Map<String, dynamic> exportToJson() {
    return {
      'flowId': 'recorded_flow_${DateTime.now().millisecondsSinceEpoch}',
      'steps': _steps.map((step) => step.toJson()).toList(),
      'recordedAt': DateTime.now().toIso8601String(),
    };
  }
}
