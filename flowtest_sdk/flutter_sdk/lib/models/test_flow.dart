import 'flow_step.dart';

class TestFlow {
  final String flowId;
  final List<FlowStep> steps;

  TestFlow({required this.flowId, required this.steps});

  factory TestFlow.fromJson(Map<String, dynamic> json) => TestFlow(
    flowId: json['flowId'],
    steps: (json['steps'] as List).map((e) => FlowStep.fromJson(e)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'flowId': flowId,
    'steps': steps.map((e) => e.toJson()).toList(),
  };
}
