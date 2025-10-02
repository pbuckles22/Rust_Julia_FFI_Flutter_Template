import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized debug logging system for the Wordle Helper app
///
/// Provides consistent debug messaging with global enable/disable control
/// Automatically disabled in release builds for production
class DebugLogger {
  // Automatically disable in release builds, enable in debug builds
  static bool _isEnabled = !kReleaseMode;

  // Override for testing or manual control
  static bool _manualOverride = false;

  /// Enable or disable all debug messages globally
  static void setEnabled(bool enabled) {
    _manualOverride = true;
    _isEnabled = enabled;
  }

  /// Check if debug logging is enabled
  static bool get isEnabled => _manualOverride ? _isEnabled : !kReleaseMode;

  /// Log debug information
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isEnabled) return;

    final tagPrefix = tag != null ? '[$tag]' : '[DEBUG]';
    final logMessage = '$tagPrefix $message';

    developer.log(
      logMessage,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log info messages
  static void info(String message, {String? tag}) {
    if (!isEnabled) return;

    final tagPrefix = tag != null ? '[$tag]' : '[INFO]';
    final logMessage = '$tagPrefix $message';

    developer.log(logMessage, time: DateTime.now());
  }

  /// Log warning messages
  static void warning(String message, {String? tag, Object? error}) {
    if (!isEnabled) return;

    final tagPrefix = tag != null ? '[$tag]' : '[WARNING]';
    final logMessage = '$tagPrefix $message';

    developer.log(logMessage, time: DateTime.now(), error: error);
  }

  /// Log error messages
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isEnabled) return;

    final tagPrefix = tag != null ? '[$tag]' : '[ERROR]';
    final logMessage = '$tagPrefix $message';

    developer.log(
      logMessage,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log success messages
  static void success(String message, {String? tag}) {
    if (!isEnabled) return;

    final tagPrefix = tag != null ? '[$tag]' : '[SUCCESS]';
    final logMessage = '$tagPrefix $message';

    developer.log(logMessage, time: DateTime.now());
  }

  /// Convenience method for test environments that need console output
  /// Only use this in test files when you need to see output during testing
  static void testPrint(String message, {String? tag}) {
    if (!isEnabled) return;

    final tagPrefix = tag != null ? '[$tag]' : '[TEST]';
    final logMessage = '$tagPrefix $message';

    // In test environments, we may need console output
    developer.log(logMessage, time: DateTime.now());
  }
}
