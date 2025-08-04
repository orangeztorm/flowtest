import 'dart:io';
import 'package:flutter/foundation.dart';

/// ANSI escape codes for colored console output
const String _reset = '\x1B[0m';
const String _green = '\x1B[32m';
const String _red = '\x1B[31m';
const String _yellow = '\x1B[33m';
const String _cyan = '\x1B[36m';
const String _blue = '\x1B[34m';

/// Development logger for FlowTest SDK with colored console output
/// Provides different log levels with visual feedback for debugging flows
class FlowLogger {
  /// Global verbose flag - controls whether info/warning logs are shown
  /// Errors are always displayed regardless of this setting
  static bool verbose = false;

  /// Check if terminal supports ANSI escape codes
  static bool get _supportsAnsi {
    try {
      return stdout.supportsAnsiEscapes;
    } catch (e) {
      return false; // Fallback for environments where stdout isn't available
    }
  }

  /// Apply color codes only if terminal supports ANSI
  static String _colorize(String text, String colorCode) {
    return _supportsAnsi ? '$colorCode$text$_reset' : text;
  }

  /// Log general information (only shown when verbose=true)
  static void info(String message) {
    if (verbose) debugPrint(_colorize('[FlowTest] $message', _cyan));
  }

  /// Log success messages (only shown when verbose=true)
  static void success(String message) {
    if (verbose) debugPrint(_colorize('[FlowTest] ✅ $message', _green));
  }

  /// Log error messages (always shown regardless of verbose setting)
  static void error(String message) {
    debugPrint(_colorize('[FlowTest] ❌ $message', _red));
  }

  /// Log warning messages (only shown when verbose=true)
  static void warning(String message) {
    if (verbose) debugPrint(_colorize('[FlowTest] ⚠️ $message', _yellow));
  }

  /// Log step execution details (only shown when verbose=true)
  static void step(String message) {
    if (verbose) debugPrint(_colorize('[FlowTest] ▶️ $message', _blue));
  }

  /// Log expectation verification (only shown when verbose=true)
  static void expectation(String message) {
    if (verbose) debugPrint(_colorize('[FlowTest] 🔎 $message', _cyan));
  }

  /// Enable verbose logging for development/debugging
  static void enableVerbose() {
    verbose = true;
    info('Verbose logging enabled');
  }

  /// Disable verbose logging for production/CI
  static void disableVerbose() {
    verbose = false;
  }
}
