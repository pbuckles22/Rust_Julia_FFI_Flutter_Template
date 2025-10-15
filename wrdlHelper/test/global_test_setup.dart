import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

/// Global test setup for FFI optimization
/// 
/// This file provides a centralized way to initialize FFI services once
/// and reuse them across all tests, dramatically improving performance.
class GlobalTestSetup {
  static bool _isInitialized = false;

  /// Initialize FFI services once for all tests
  /// 
  /// This should be called in setUpAll() of test files that need FFI
  /// Uses comprehensive algorithm-testing word list (250 words)
  static Future<void> initializeOnce() async {
    if (_isInitialized) {
      return; // Already initialized
    }
    
    try {
      // Initialize services once globally with algorithm-testing word list
      await setupTestServices();
      _isInitialized = true;
      
      DebugLogger.info(
        '🚀 Global FFI initialization complete with comprehensive '
        'algorithm-testing word list',
        tag: 'Setup',
      );
    } catch (e) {
      DebugLogger.error('❌ Global FFI initialization failed: $e', tag: 'Setup');
      rethrow;
    }
  }

  /// Reset services for individual test isolation
  /// 
  /// This should be called in setUp() of individual tests
  static void resetForTest() {
    if (_isInitialized) {
      resetAllServices();
      
      // Re-initialize with algorithm-testing word list
      setupTestServices();
    }
  }

  /// Clean up global resources
  /// 
  /// This should be called in tearDownAll() of test files
  static void cleanup() {
    if (_isInitialized) {
      resetAllServices();
      _isInitialized = false;
      DebugLogger.info('🧹 Global FFI cleanup complete', tag: 'Setup');
    }
  }

  /// Check if FFI is initialized
  static bool get isInitialized => _isInitialized;
}
