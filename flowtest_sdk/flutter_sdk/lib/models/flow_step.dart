import 'enums.dart';
import 'expectation.dart';

class FlowStep {
  final FlowAction action;
  final String target; // Widget identifier (e.g. key, type, text)
  final String? value; // For input/wait time
  final List<Expectation>? expects; // Optional chained expectations
  final Map<String, dynamic>? metadata;

  FlowStep({
    required this.action,
    required this.target,
    this.value,
    this.expects,
    this.metadata,
  });

  factory FlowStep.fromJson(Map<String, dynamic> json) => FlowStep(
    action: FlowAction.values.firstWhere(
      (e) => e.toString().split('.').last == json['action'],
    ),
    target: json['target'],
    value: json['value'],
    expects: json['expects'] == null
        ? null
        : (json['expects'] as List)
              .map((e) => Expectation.fromJson(e))
              .toList(),
    metadata: json['metadata'] == null
        ? null
        : Map<String, dynamic>.from(json['metadata']),
  );

  Map<String, dynamic> toJson() => {
    'action': action.toString().split('.').last,
    'target': target,
    if (value != null) 'value': value,
    if (expects != null) 'expects': expects!.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };
}
