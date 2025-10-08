import '../utils/debug_logger.dart';
import 'ffi_service.dart';
import 'game_service.dart';

/// Centralized service for app initialization
///
/// This service handles the initialization of all other services
/// in the correct order, ensuring proper dependency management.
class AppService {
  // REMOVED: Static singleton pattern to eliminate global state
  AppService();

  GameService? _gameService;

  bool _isInitialized = false;


  /// Get the singleton GameService instance
  GameService get gameService {
    if (_gameService == null) {
      throw StateError('AppService not initialized. Call initialize() first.');
    }
    return _gameService!;
  }

  /// Whether the app services are initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all app services in the correct order
  Future<void> initialize() async {
    if (_isInitialized) {
      return; // Already initialized
    }

    try {
      // Always use comprehensive word list for algorithm testing
      // This maintains the spirit of Shannon Entropy and statistical analysis
      // while being fast enough for 800+ test suite
      DebugLogger.info('🚀 Initializing with comprehensive algorithm-testing word list', tag: 'AppService');

      DebugLogger.info(
        '🔧 Step 0: Initializing FFI Service...',
        tag: 'AppService',
      );
      // Step 0: Initialize FFI service first (required for all other services)
      await FfiService.initialize();
      DebugLogger.success(
        '✅ FFI Service initialized successfully',
        tag: 'AppService',
      );

      DebugLogger.info('🔧 Step 1: Word lists already loaded by FFI Service...', tag: 'AppService');
      // Step 1: Word lists are already loaded by FFI Service during initialization
      // No need to create WordService or load word lists manually
      DebugLogger.success('✅ Word lists available via centralized FFI', tag: 'AppService');

      DebugLogger.info('🔧 Step 6: Creating GameService...', tag: 'AppService');
      // Step 6: Initialize GameService (now uses centralized FFI)
      _gameService = GameService();

      DebugLogger.info(
        '🔧 Step 7: Initializing GameService...',
        tag: 'AppService',
      );
      await _gameService!.initialize();
      DebugLogger.success(
        '✅ GameService initialized successfully',
        tag: 'AppService',
      );

      _isInitialized = true;
      DebugLogger.success(
        '🎉 All app services initialized successfully!',
        tag: 'AppService',
      );
    } catch (e, stackTrace) {
      DebugLogger.error(
        '❌ CRITICAL: Failed to initialize app services: $e',
        tag: 'AppService',
      );
      DebugLogger.error('Stack trace: $stackTrace', tag: 'AppService');
      rethrow;
    }
  }

  /// Reset all services (useful for testing)
  void reset() {
    _isInitialized = false;
    _gameService = null;
    // Services will be recreated on next initialize() call
  }

  /// Initialize AppService for testing with pre-created services
  /// This allows tests to use algorithm-testing word lists instead of full production lists
  Future<void> initializeForTesting(GameService gameService) async {
    if (_isInitialized) {
      return; // Already initialized
    }

    try {
      DebugLogger.info('🧪 Initializing AppService for testing with centralized FFI', tag: 'AppService');

      _gameService = gameService;
      _isInitialized = true;

      DebugLogger.success('🎉 AppService initialized for testing successfully!', tag: 'AppService');
    } catch (e, stackTrace) {
      DebugLogger.error('❌ CRITICAL: App service test initialization failed: $e', tag: 'AppService');
      DebugLogger.error('Stack trace: $stackTrace', tag: 'AppService');
      rethrow;
    }
  }
}
