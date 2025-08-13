import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _FlowRecorderOverlayState extends State<FlowRecorderOverlay>
    with TickerProviderStateMixin {
  // Focus management
  FocusNode? _activeFocusNode;
  BuildContext? _activeContext;

  // Bubble state
  late AnimationController _snapController;
  late AnimationController _hideController;
  late Animation<double> _hideAnimation;
  final GlobalKey _bubbleKey = GlobalKey();
  Offset _bubblePos = const Offset(20, 200);
  final Size _bubbleSize = const Size(56, 56);
  bool _isDockedLeft = true;
  bool _isHidden = false;
  bool _isDragging = false;
  int _hideEpoch = 0; // Guard against stale auto-hide timers

  // Tap detection state
  Offset? _downPos;
  int _downMs = 0;
  static const double _tapSlop = 12; // px tolerance
  static const int _tapMaxMs = 350; // max ms for tap

  // Recording state listener
  late final ValueNotifier<bool> _recordingNotifier;

  // Export state
  bool _exporting = false;

  // Constants
  static const double _peekVisible = 20;
  static const double _hiddenPeek = 8;
  EdgeInsets _safePadding = EdgeInsets.zero;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handleFocusChange);

    // Listen to recording state changes from controller
    _recordingNotifier = RecorderController.instance.recordingNotifier;
    _recordingNotifier.addListener(_onRecordingStateChanged);

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _hideAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _hideController, curve: Curves.easeInOut),
    );

    _loadSavedPosition();
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    _recordingNotifier.removeListener(_onRecordingStateChanged);
    _snapController.dispose();
    _hideController.dispose();
    super.dispose();
  }

  void _onRecordingStateChanged() {
    if (mounted) setState(() {});

    // Stop recording automatically when overlay is disabled
    if (!widget.enabled && _recordingNotifier.value) {
      RecorderController.instance.stopRecording();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Recording stopped - overlay disabled'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
      }
    }
  }

  Future<void> _loadSavedPosition() async {
    // Optional: implement with SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _bubblePos = Offset(
    //     prefs.getDouble('bubble_x') ?? 20,
    //     prefs.getDouble('bubble_y') ?? 200,
    //   );
    // });
  }

  Future<void> _savePosition() async {
    // Optional: implement with SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setDouble('bubble_x', _bubblePos.dx);
    // await prefs.setDouble('bubble_y', _bubblePos.dy);
  }

  // ------------------------ Global Bubble Hit Test ------------------------

  Rect _bubbleGlobalRect() {
    final box = _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;

    final topLeft = box.localToGlobal(Offset.zero);
    final size = box.size;
    return Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
  }

  bool _isPointerOverBubble(Offset globalPos) {
    return _bubbleGlobalRect().contains(globalPos);
  }

  // ------------------------ Focus Management ------------------------

  void _handleFocusChange() {
    if (!_recordingNotifier.value) return;

    final focusedNode = FocusManager.instance.primaryFocus;
    final focusedContext = focusedNode?.context;

    // Capture text when focus leaves a text field
    if (_activeFocusNode != null &&
        _activeContext != null &&
        focusedNode != _activeFocusNode) {
      _captureTextInput();
      _activeFocusNode = null;
      _activeContext = null;
    }

    // Track new text field focus
    if (focusedContext != null) {
      final widget = focusedContext.widget;
      if (widget is TextField || widget is TextFormField) {
        _activeFocusNode = focusedNode;
        _activeContext = focusedContext;
      }
    }
  }

  void _captureTextInput() {
    final c = _activeContext;
    if (c == null) return;

    String? textValue;
    final w = c.widget;

    // Try to get text from controller
    if (w is TextField && w.controller != null) {
      textValue = w.controller!.text;
    } else if (w is TextFormField && w.controller != null) {
      textValue = w.controller!.text;
    }

    // If focus is on the internal EditableText itself
    if (textValue == null && w is EditableText) {
      try {
        final st = (c as StatefulElement).state as EditableTextState;
        textValue = st.textEditingValue.text;
      } catch (_) {
        // Ignore cast errors
      }
    }

    // Or if we held the TextField context, try finding the descendant state
    textValue ??= c
        .findAncestorStateOfType<EditableTextState>()
        ?.textEditingValue
        .text;

    if (textValue == null || textValue.isEmpty) return;

    final step = RecorderUtils.buildFlowStepFromContext(
      context: c,
      action: FlowAction.input,
      value: textValue,
    );
    RecorderController.instance.recordStep(step);
  }

  // ------------------------ Tap Detection ------------------------

  void _handlePointerDown(PointerDownEvent event) {
    _downPos = event.position;
    _downMs = DateTime.now().millisecondsSinceEpoch;

    // Don't unhide on any tap - let the bubble handle its own reveal
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_recordingNotifier.value || _isPointerOverBubble(event.position)) {
      _downPos = null;
      return;
    }

    // Check if this is a real tap (not a drag/scroll)
    if (_downPos != null) {
      final moved = (event.position - _downPos!).distance;
      final dt = DateTime.now().millisecondsSinceEpoch - _downMs;

      if (moved <= _tapSlop && dt <= _tapMaxMs) {
        _recordTap(event.position);
      }
    }

    _downPos = null;
  }

  void _recordTap(Offset globalPosition) {
    final targetContext = RecorderUtils.findContextAt(globalPosition, context);
    if (targetContext != null) {
      final step = RecorderUtils.buildFlowStepFromContext(
        context: targetContext,
        action: FlowAction.tap,
      );
      RecorderController.instance.recordStep(step);
    }
  }

  // ------------------------ Bubble Movement ------------------------

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      if (_isHidden) _isHidden = false; // Fix: Update flag when revealing
    });
    _hideController.reverse();
  }

  void _onDragUpdate(DragUpdateDetails details, Size canvasSize) {
    final newX = (_bubblePos.dx + details.delta.dx).clamp(
      _safePadding.left - _bubbleSize.width + _hiddenPeek,
      canvasSize.width - _safePadding.right - _hiddenPeek,
    );

    final newY = (_bubblePos.dy + details.delta.dy).clamp(
      _safePadding.top,
      canvasSize.height - _bubbleSize.height - _safePadding.bottom,
    );

    setState(() => _bubblePos = Offset(newX, newY));
  }

  void _onDragEnd(DragEndDetails details, Size canvasSize) {
    setState(() => _isDragging = false);
    _snapToEdge(canvasSize, velocity: details.velocity.pixelsPerSecond);
    _savePosition();
  }

  void _snapToEdge(Size canvasSize, {Offset velocity = Offset.zero}) {
    final centerX = _bubblePos.dx + _bubbleSize.width / 2;
    final screenCenterX = canvasSize.width / 2;

    bool shouldDockLeft = centerX < screenCenterX;
    if ((centerX - screenCenterX).abs() < 50 && velocity != Offset.zero) {
      shouldDockLeft = velocity.dx < 0;
    }

    setState(() => _isDockedLeft = shouldDockLeft);

    double targetX;
    if (shouldDockLeft) {
      targetX = _safePadding.left - _bubbleSize.width + _peekVisible;
    } else {
      targetX = canvasSize.width - _safePadding.right - _peekVisible;
    }

    final targetY = _bubblePos.dy.clamp(
      _safePadding.top,
      canvasSize.height - _bubbleSize.height - _safePadding.bottom,
    );

    _animateToPosition(Offset(targetX, targetY));

    // Auto-hide after snapping with epoch guard
    final myEpoch = ++_hideEpoch;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _isDragging) return;
      if (myEpoch != _hideEpoch) return; // User interacted since scheduling
      _hideController.forward();
      setState(() => _isHidden = true);
    });
  }

  void _animateToPosition(Offset target) {
    final animation = Tween<Offset>(begin: _bubblePos, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );

    void listener() {
      if (mounted) {
        setState(() => _bubblePos = animation.value);
      }
    }

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _snapController.removeListener(listener);
        _snapController.removeStatusListener(statusListener);
      }
    }

    _snapController
      ..reset()
      ..addListener(listener)
      ..addStatusListener(statusListener)
      ..forward();
  }

  void _clampPositionToCanvas(Size canvasSize) {
    final dx = _bubblePos.dx.clamp(
      _safePadding.left - _bubbleSize.width + _hiddenPeek,
      canvasSize.width - _safePadding.right - _hiddenPeek,
    );
    final dy = _bubblePos.dy.clamp(
      _safePadding.top,
      canvasSize.height - _bubbleSize.height - _safePadding.bottom,
    );

    if (dx != _bubblePos.dx || dy != _bubblePos.dy) {
      setState(() => _bubblePos = Offset(dx, dy));
    }
  }

  // ------------------------ Bubble Actions ------------------------

  void _onBubbleTap() {
    HapticFeedback.lightImpact();

    if (_isHidden) {
      _hideController.reverse();
      setState(() => _isHidden = false);
    } else {
      _toggleRecording();
    }
  }

  void _toggleRecording() {
    if (_recordingNotifier.value) {
      RecorderController.instance.stopRecording();
      _showRecordingStopped();
    } else {
      RecorderController.instance.startRecording();
      _showRecordingStarted();
    }
  }

  void _showRecordingStarted() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('Recording started'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green.shade600,
        ),
      );
  }

  void _showRecordingStopped() {
    final stepCount = RecorderController.instance.steps.length;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Recording stopped. $stepCount steps recorded.'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.grey.shade800,
          action: stepCount > 0
              ? SnackBarAction(
                  label: 'EXPORT',
                  textColor: Colors.white,
                  onPressed: _exportFlow,
                )
              : null,
        ),
      );
  }

  void _exportFlow() async {
    if (_exporting) return; // Debounce: prevent double triggers
    _exporting = true;

    try {
      final filePath = await RecorderController.instance.exportAndSave();
      final fileName = filePath.split('/').last;

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('Flow exported: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('Export failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } finally {
      _exporting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final mediaQuery = MediaQuery.of(context);
    // Use viewPadding to respect system UI that doesn't change with keyboard
    _safePadding = mediaQuery.viewPadding + const EdgeInsets.all(8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Clamp position after layout changes (rotation, split view, etc)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _clampPositionToCanvas(canvasSize);
        });

        return Stack(
          children: [
            // Main app content with tap detection
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _handlePointerDown,
                onPointerUp: _handlePointerUp,
                onPointerCancel: (_) => _downPos = null, // Fix: Clear on cancel
                child: widget.child,
              ),
            ),

            // Recording bubble
            Positioned(
              left: _bubblePos.dx,
              top: _bubblePos.dy,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _hideAnimation,
                  _recordingNotifier,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isHidden ? 0.85 : 1.0,
                    child: SizedBox(
                      // Attach key to the scaled box for perfect hit-test
                      key: _bubbleKey,
                      width: _bubbleSize.width,
                      height: _bubbleSize.height,
                      child: AnimatedOpacity(
                        opacity: _isHidden ? _hideAnimation.value : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: child,
                      ),
                    ),
                  );
                },
                child: _RecorderBubble(
                  size: _bubbleSize,
                  recording: _recordingNotifier.value,
                  dockedLeft: _isDockedLeft,
                  isHidden: _isHidden,
                  isDragging: _isDragging,
                  onTap: _onBubbleTap,
                  onPanStart: _onDragStart,
                  onPanUpdate: (details) => _onDragUpdate(details, canvasSize),
                  onPanEnd: (details) => _onDragEnd(details, canvasSize),
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    _exportFlow();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecorderBubble extends StatelessWidget {
  final Size size;
  final bool recording;
  final bool dockedLeft;
  final bool isHidden;
  final bool isDragging;
  final VoidCallback onTap;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final VoidCallback onLongPress;

  const _RecorderBubble({
    required this.size,
    required this.recording,
    required this.dockedLeft,
    required this.isHidden,
    required this.isDragging,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Toggle recording',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: recording
                ? Colors.red.shade600
                : (isHidden ? Colors.black54 : Colors.black87),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: isDragging ? 16 : 8,
                spreadRadius: isDragging ? 2 : 0,
                offset: const Offset(0, 3),
                color: Colors.black.withOpacity(isDragging ? 0.4 : 0.3),
              ),
            ],
            border: Border.all(
              color: recording
                  ? Colors.white
                  : (isHidden ? Colors.white24 : Colors.white38),
              width: recording ? 2 : 1.5,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    recording
                        ? Icons.stop_rounded
                        : (isHidden ? Icons.circle : Icons.fiber_manual_record),
                    key: ValueKey('icon_$recording'),
                    size: recording ? 28 : 24,
                    color: Colors.white,
                  ),
                ),
              ),

              // Wrapped in TickerMode for performance
              if (recording)
                TickerMode(
                  enabled: recording && !isHidden,
                  child: const Positioned.fill(child: _PulseAnimation()),
                ),

              if (!isHidden && !isDragging)
                Align(
                  alignment: dockedLeft
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 4,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseAnimation extends StatefulWidget {
  const _PulseAnimation();

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(1.0 - _animation.value),
              width: 2.0 * (1.0 - _animation.value),
            ),
          ),
        );
      },
    );
  }
}
