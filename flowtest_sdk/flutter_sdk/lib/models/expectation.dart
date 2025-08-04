import 'enums.dart';

class Expectation {
  final String target; // e.g. "@loginBtn", "text:Welcome", "type:TextField"
  final ExpectCondition condition;
  final String? value; // For hasText, containsText, etc.

  Expectation({required this.target, required this.condition, this.value});

  factory Expectation.fromJson(Map<String, dynamic> json) => Expectation(
    target: json['target'],
    condition: ExpectCondition.values.firstWhere(
      (e) => e.toString().split('.').last == json['condition'],
    ),
    value: json['value'],
  );

  Map<String, dynamic> toJson() => {
    'target': target,
    'condition': condition.toString().split('.').last,
    if (value != null) 'value': value,
  };
}
