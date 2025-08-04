import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../models/expectation.dart';
import '../models/enums.dart';
import 'finder_factory.dart';

/// Matches expectations against the current widget state
class ExpectationMatcher {
  final WidgetTester tester;

  ExpectationMatcher(this.tester);

  /// Match a single expectation
  Future<void> match(Expectation exp) async {
    final finder = FinderFactory.fromTarget(exp.target);

    switch (exp.condition) {
      case ExpectCondition.isVisible:
        expect(finder, findsOneWidget);
        break;
      case ExpectCondition.isHidden:
        expect(finder, findsNothing);
        break;
      case ExpectCondition.exists:
        expect(finder, findsWidgets);
        break;
      case ExpectCondition.notExists:
        expect(finder, findsNothing);
        break;
      case ExpectCondition.isEnabled:
        final widget = tester.widget(finder);
        expect(_isWidgetEnabled(widget), isTrue);
        break;
      case ExpectCondition.isDisabled:
        final widget = tester.widget(finder);
        expect(_isWidgetEnabled(widget), isFalse);
        break;
      case ExpectCondition.hasText:
        expect(_extractText(finder), equals(exp.value));
        break;
      case ExpectCondition.containsText:
        expect(_extractText(finder), contains(exp.value));
        break;
      case ExpectCondition.matchesRegex:
        final re = RegExp(exp.value ?? '');
        expect(re.hasMatch(_extractText(finder)), isTrue);
        break;
    }
  }

  /// Match multiple expectations
  Future<void> matchAll(List<Expectation> expectations) async {
    for (final exp in expectations) {
      await match(exp);
    }
  }

  /// Check if a widget is enabled
  bool _isWidgetEnabled(Widget widget) {
    if (widget is ButtonStyleButton) {
      return widget.onPressed != null;
    }
    if (widget is IconButton) {
      return widget.onPressed != null;
    }
    if (widget is TextField) {
      return widget.enabled ?? true;
    }
    if (widget is TextFormField) {
      // return widget.enabled ?? true;
      return widget.enabled;
    }
    return true; // assume enabled if we don't know how to check yet
  }

  /// Extract text from a widget
  String _extractText(Finder finder) {
    final widget = tester.widget(finder);

    if (widget is Text) {
      return widget.data ?? '';
    }

    if (widget is EditableText) {
      return widget.controller.text;
    }

    if (widget is TextField) {
      return widget.controller?.text ?? '';
    }

    if (widget is TextFormField) {
      return widget.controller?.text ?? '';
    }

    // Fallback: return widget string representation
    return widget.toString();
  }
}
