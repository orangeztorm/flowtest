import 'package:flutter/material.dart';
import '../models/enums.dart';
import 'recorder_controller.dart';
import 'recorder_widget_utils.dart';

class FlowRecorderOverlay extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const FlowRecorderOverlay({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  State<FlowRecorderOverlay> createState() => _FlowRecorderOverlayState();
}

class _FlowRecorderOverlayState extends State<FlowRecorderOverlay> {
  FocusNode? _activeFocusNode;
  BuildContext? _activeContext;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    final focusedNode = FocusManager.instance.primaryFocus;
    final focusedContext = focusedNode?.context;

    // 🔁 User just unfocused a text field? Capture the input.
    if (_activeFocusNode != null &&
        _activeContext != null &&
        focusedNode != _activeFocusNode) {
      _captureTextInput();
      _activeFocusNode = null;
      _activeContext = null;
    }

    // 📝 User focused a new text field?
    if (focusedContext != null) {
      final widget = focusedContext.widget;
      if (widget is TextField || widget is TextFormField) {
        _activeFocusNode = focusedNode;
        _activeContext = focusedContext;
      }
    }
  }

  void _captureTextInput() {
    if (_activeFocusNode == null || _activeContext == null) return;

    String? textValue;

    // Try to get text from the widget's controller
    final widget = _activeContext!.widget;
    if (widget is TextField && widget.controller != null) {
      textValue = widget.controller!.text;
    } else if (widget is TextFormField && widget.controller != null) {
      textValue = widget.controller!.text;
    }

    // If we couldn't get the text from controller, try to find it in the widget tree
    if (textValue == null || textValue.isEmpty) {
      // This is a fallback - in practice, most text fields have controllers
      // For now, we'll skip recording if we can't get the text
      return;
    }

    // Only record if we have a meaningful text value
    if (textValue.isNotEmpty) {
      final step = RecorderUtils.buildFlowStepFromContext(
        context: _activeContext!,
        action: FlowAction.input,
        value: textValue,
      );
      RecorderController.instance.recordStep(step);
    }
  }

  void _handleTap(TapUpDetails details) {
    final targetContext = RecorderUtils.findContextAt(
      details.globalPosition,
      context,
    );
    if (targetContext != null) {
      final step = RecorderUtils.buildFlowStepFromContext(
        context: targetContext,
        action: FlowAction.tap,
      );
      RecorderController.instance.recordStep(step);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: _handleTap,
          child: widget.child,
        ),
        // Recording indicator
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {}, // prevent tap-through
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '● REC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
