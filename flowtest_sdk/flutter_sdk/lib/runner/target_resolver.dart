import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TargetResolver {
  const TargetResolver._();

  static Finder resolve(String target) {
    // 1. Key-based targeting
    if (target.startsWith('@')) {
      return find.byKey(ValueKey(target.substring(1)));
    }

    // 2. Text-based targeting
    if (target.startsWith('text:')) {
      return find.text(target.substring(5));
    }

    // 3. General-purpose Button targeting (with index support)
    if (target.startsWith('button:')) {
      String lookup = target.substring(7);
      int? index;
      if (lookup.contains('[') && lookup.endsWith(']')) {
        final parts = lookup.split('[');
        lookup = parts[0];
        index = int.tryParse(parts[1].replaceAll(']', ''));
      }
      var finder = find.byWidgetPredicate(
        (widget) =>
            (widget is ButtonStyleButton || widget is MaterialButton) &&
            _descTextEquals(widget, lookup),
      );
      if (index != null) {
        return finder.at(index);
      }
      return finder;
    }

    // 4. Input-based targeting
    if (target.startsWith('input:')) {
      final lookup = target.substring(6);
      return find.byWidgetPredicate((w) {
        if (w is TextField) {
          return w.decoration?.hintText == lookup ||
              w.decoration?.labelText == lookup;
        }
        if (w is TextFormField) {
          final dec = (w as dynamic).decoration as InputDecoration?;
          return dec?.hintText == lookup || dec?.labelText == lookup;
        }
        return false;
      });
    }

    // 5. Type-based targeting
    if (target.startsWith('type:')) {
      return find.byType(_typeFromName(target.substring(5)));
    }

    throw Exception('Unsupported target format: $target');
  }

  /// Recursively check if a widget or its descendants contain text
  static bool _descTextEquals(Widget w, String label) {
    if (w is Text && w.data == label) return true;
    if (w is SingleChildRenderObjectWidget && w.child != null) {
      return _descTextEquals(w.child!, label);
    }
    if (w is MultiChildRenderObjectWidget) {
      return w.children.any((c) => _descTextEquals(c, label));
    }
    return false;
  }

  static const Map<String, Type> _typeMap = {
    'TextButton': TextButton,
    'ElevatedButton': ElevatedButton,
    'OutlinedButton': OutlinedButton,
    'IconButton': IconButton,
    'TextField': TextField,
    'TextFormField': TextFormField,
    'Text': Text,
    'Container': Container,
    'Column': Column,
    'Row': Row,
    'ListView': ListView,
    'Scaffold': Scaffold,
    'AppBar': AppBar,
    'Card': Card,
    'InkWell': InkWell,
    'GestureDetector': GestureDetector,
  };

  static Type _typeFromName(String name) {
    final type = _typeMap[name];
    if (type == null) {
      throw Exception('Unknown widget type: $name');
    }
    return type;
  }
}
