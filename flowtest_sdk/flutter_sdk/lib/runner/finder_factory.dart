import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Factory for creating Flutter test Finders from target strings
class FinderFactory {
  /// Convert a target string to a Finder
  ///
  /// Supported formats:
  /// - @keyName -> find.byKey(ValueKey('keyName'))
  /// - text:Hello -> find.text('Hello')
  /// - button:Login -> find.widgetWithText(ElevatedButton, 'Login')
  /// - input:Email -> find TextField/TextFormField by label/hint
  /// - type:IconButton -> find.byType(IconButton)
  static Finder fromTarget(String target) {
    // @myKey -> find.byKey(ValueKey('myKey'))
    if (target.startsWith('@')) {
      return find.byKey(ValueKey(target.substring(1)));
    }

    // text:Submit -> find.text('Submit')
    if (target.startsWith('text:')) {
      return find.text(target.substring(5));
    }

    // button:Login -> find.widgetWithText(ElevatedButton, 'Login')
    if (target.startsWith('button:')) {
      return find.widgetWithText(ElevatedButton, target.substring(7));
    }

    // input:Email -> predicate matching TextField/TextFormField by label/hint
    if (target.startsWith('input:')) {
      final lookup = target.substring(6);
      return find.byWidgetPredicate((w) {
        if (w is TextField) {
          return w.decoration?.hintText == lookup ||
              w.decoration?.labelText == lookup;
        }
        // For TextFormField, we'll use a simpler approach for now
        // since the decoration property might not be directly accessible
        return false;
      });
    }

    // type:IconButton -> find.byType(IconButton)
    if (target.startsWith('type:')) {
      return find.byType(_typeFromName(target.substring(5)));
    }

    throw Exception('Unsupported target format: $target');
  }

  /// Convert a widget type name to a Type
  ///
  /// This is a manual mapping for common widget types.
  /// In a production system, you might want to generate this mapping
  /// or use a more sophisticated reflection approach.
  static Type _typeFromName(String name) {
    switch (name) {
      case 'TextButton':
        return TextButton;
      case 'ElevatedButton':
        return ElevatedButton;
      case 'OutlinedButton':
        return OutlinedButton;
      case 'IconButton':
        return IconButton;
      case 'TextField':
        return TextField;
      case 'TextFormField':
        return TextFormField;
      case 'Text':
        return Text;
      case 'Container':
        return Container;
      case 'Column':
        return Column;
      case 'Row':
        return Row;
      case 'ListView':
        return ListView;
      case 'Scaffold':
        return Scaffold;
      case 'AppBar':
        return AppBar;
      case 'Card':
        return Card;
      case 'InkWell':
        return InkWell;
      case 'GestureDetector':
        return GestureDetector;
      default:
        throw Exception('Unknown widget type: $name');
    }
  }
}
