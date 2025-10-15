import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

/// Global FFI test helper to prevent test interference
/// 
/// This singleton ensures that FFI is initialized only once across all tests,
/// preventing the "Should not initialize flutter_rust_bridge twice" error
/// and other test interference issues.
class FfiTestHelper {
  static bool _isInitialized = false;
  static bool _isDisposed = false;

  /// Initialize FFI once for all tests
  static Future<void> initializeOnce() async {
    if (_isInitialized || _isDisposed) {
      return;
    }

    try {
      await RustLib.init();
      await FfiService.initialize();
      _isInitialized = true;
    } catch (e) {
      // FFI initialization may fail in test environment, that's OK
      // Tests will handle this gracefully
    }
  }

  /// Dispose FFI resources
  static void dispose() {
    if (!_isInitialized || _isDisposed) {
      return;
    }

    try {
      RustLib.dispose();
      _isDisposed = true;
    } catch (e) {
      // Ignore disposal errors
    }
  }

  /// Reset the helper state (for testing the helper itself)
  static void reset() {
    _isInitialized = false;
    _isDisposed = false;
  }

  /// Check if FFI is available
  static bool get isAvailable => _isInitialized && !_isDisposed;
}
