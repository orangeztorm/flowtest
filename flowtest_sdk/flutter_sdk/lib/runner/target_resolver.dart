import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TargetResolver {
  /// Resolves a target string to a Flutter Finder
  ///
  /// Supported formats:
  /// - "@keyName" -> find.byKey(Key('keyName'))
  /// - "text:Login" -> find.text('Login')
  /// - "button:Continue[1]" -> find.widgetWithText(ElevatedButton, 'Continue').at(1)
  /// - "type:TextField" -> find.byType(TextField)
  static Finder resolve(String target) {
    if (target.startsWith('@')) {
      // Key-based targeting: "@keyName"
      final keyName = target.substring(1);
      return find.byKey(Key(keyName));
    }

    if (target.startsWith('text:')) {
      // Text-based targeting: "text:Login"
      final text = target.substring(5);
      return find.text(text);
    }

    if (target.startsWith('button:')) {
      // Button targeting: "button:Continue[1]" or "button:Continue"
      final buttonText = target.substring(7);
      if (buttonText.contains('[') && buttonText.contains(']')) {
        final parts = buttonText.split('[');
        final text = parts[0];
        final index = int.parse(parts[1].replaceAll(']', ''));
        return find.widgetWithText(ElevatedButton, text).at(index);
      } else {
        return find.widgetWithText(ElevatedButton, buttonText);
      }
    }

    if (target.startsWith('type:')) {
      // Type-based targeting: "type:TextField"
      final typeName = target.substring(5);
      // This is a simplified version - in practice you'd need a mapping
      // from string names to actual widget types
      throw UnimplementedError(
        'Type-based targeting not yet implemented: $typeName',
      );
    }

    // Default: treat as text
    return find.text(target);
  }

  /// Validates if a target string is in a supported format
  static bool isValidTarget(String target) {
    return target.startsWith('@') ||
        target.startsWith('text:') ||
        target.startsWith('button:') ||
        target.startsWith('type:') ||
        target.isNotEmpty;
  }
}
