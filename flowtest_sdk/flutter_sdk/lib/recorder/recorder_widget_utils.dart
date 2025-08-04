import 'package:flutter/material.dart';
import 'dart:developer';
import '../models/flow_step.dart';
import '../models/enums.dart';
import 'recorder_overlay.dart';
import 'recorder_toggle.dart';

class RecorderUtils {
  /// Returns the deepest BuildContext under [globalPosition], or null.
  ///
  /// This method traverses the Element tree to find the widget at the given
  /// global position, filtering out the recorder overlay itself and ensuring
  /// the widget is actually visible at the tap point.
  static BuildContext? findContextAt(
    Offset globalPosition,
    BuildContext rootContext,
  ) {
    return Timeline.timeSync('findContextAt', () {
      BuildContext? hit;

      void visitor(Element element) {
        final renderObject = element.renderObject;
        if (renderObject is RenderBox) {
          // Check if the widget is actually visible at the tap point
          final rect =
              renderObject.localToGlobal(Offset.zero) & renderObject.size;

          if (rect.contains(globalPosition)) {
            // Ignore the overlay itself and other recorder components
            if (element.widget is! FlowRecorderOverlay &&
                element.widget is! RecorderToggle) {
              // Get the context by finding the nearest BuildContext
              final context = _findBuildContext(element);
              if (context != null) {
                hit = context;
              }
              // Keep diving – the last match will be the deepest
              element.visitChildren(visitor);
            }
          }
        } else {
          element.visitChildren(visitor);
        }
      }

      (rootContext as Element).visitChildren(visitor);
      return hit;
    });
  }

  /// Helper method to find a BuildContext from an Element
  static BuildContext? _findBuildContext(Element element) {
    // Try to find a BuildContext by looking for StatefulElement or StatelessElement
    if (element is StatefulElement || element is StatelessElement) {
      return element;
    }

    // For other element types, we need to find a parent that provides context
    // This is a simplified approach - in practice, you might need more sophisticated logic
    return null;
  }

  /// Builds a FlowStep from a widget context
  static FlowStep buildFlowStepFromContext({
    required BuildContext context,
    required FlowAction action,
    String? value,
  }) {
    final target = _extractTargetFromContext(context);

    return FlowStep(action: action, target: target, value: value);
  }

  /// Extracts a target identifier from a widget context
  ///
  /// This method tries to find the most meaningful identifier for a widget,
  /// prioritizing keys, then text content, then widget types.
  static String _extractTargetFromContext(BuildContext context) {
    final widget = context.widget;

    // Try to get key first (most reliable)
    if (widget.key != null) {
      final keyString = widget.key.toString();
      if (keyString.startsWith('Key(') && keyString.endsWith(')')) {
        final keyValue = keyString.substring(4, keyString.length - 1);
        return '@$keyValue';
      }
    }

    // Try to get text content
    if (widget is Text) {
      return 'text:${widget.data}';
    }

    // Try to get button text
    if (widget is ElevatedButton) {
      final child = widget.child;
      if (child is Text) {
        return 'button:${child.data}';
      }
    }

    if (widget is TextButton) {
      final child = widget.child;
      if (child is Text) {
        return 'button:${child.data}';
      }
    }

    if (widget is OutlinedButton) {
      final child = widget.child;
      if (child is Text) {
        return 'button:${child.data}';
      }
    }

    // Try to get input field hint or label
    if (widget is TextField) {
      final decoration = widget.decoration;
      if (decoration?.hintText != null) {
        return 'input:${decoration!.hintText}';
      }
      if (decoration?.labelText != null) {
        return 'input:${decoration!.labelText}';
      }
    }

    // Try to find actionable parent widget
    final actionableTarget = _findActionableParent(context);
    if (actionableTarget != null) {
      return actionableTarget;
    }

    // Fallback to widget type
    return 'type:${widget.runtimeType.toString().split('.').last}';
  }

  /// Walks up the element tree to find an actionable parent widget
  ///
  /// This helps when tapping on nested widgets (e.g., Icon inside Button)
  /// by finding the parent that should actually be the target.
  static String? _findActionableParent(BuildContext context) {
    // For now, we'll use a simpler approach that doesn't rely on Element.parent
    // This can be enhanced later with more sophisticated parent traversal
    return null;
  }
}
