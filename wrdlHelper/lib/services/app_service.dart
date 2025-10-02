import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

/// Centralized service for app initialization
///
/// This service handles the initialization of all other services
/// in the correct order, ensuring proper dependency management.
class AppService {
  // REMOVED: Static singleton pattern to eliminate global state
  AppService();

  WordService? _wordService;
  GameService? _gameService;

  bool _isInitialized = false;

  /// Get the singleton WordService instance
  WordService get wordService {
    if (_wordService == null) {
      throw StateError('AppService not initialized. Call initialize() first.');
    }
    return _wordService!;
  }

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

      DebugLogger.info('🔧 Step 1: Creating WordService...', tag: 'AppService');
      // Step 1: Initialize WordService first (loads word lists)
      _wordService = WordService();

      DebugLogger.info(
        '🔧 Step 2: Loading word list from JSON...',
        tag: 'AppService',
      );
      // Load the comprehensive word list for target words
      await _wordService!.loadWordList(
        'assets/word_lists/official_wordle_words.json',
      );
      DebugLogger.success('✅ Word list loaded successfully', tag: 'AppService');

      DebugLogger.info(
        '🔧 Step 3: Loading guess words from TXT...',
        tag: 'AppService',
      );
      // Load the big list for filtering (12k+ words)
      await _wordService!.loadGuessWords(
        'assets/word_lists/official_guess_words.txt',
      );
      DebugLogger.success(
        '✅ Guess words loaded successfully',
        tag: 'AppService',
      );

      DebugLogger.info(
        '🔧 Step 4: Loading answer words from JSON...',
        tag: 'AppService',
      );
      // Load the answer list for suggestions (2.3k words)
      await _wordService!.loadAnswerWords(
        'assets/word_lists/official_wordle_words.json',
      );
      DebugLogger.success(
        '✅ Answer words loaded successfully',
        tag: 'AppService',
      );

      DebugLogger.info('🔧 Step 5: Loading word lists to Rust...', tag: 'AppService');
      // Step 5: Load word lists to Rust for optimal performance
      FfiService.loadWordListsToRust(
        _wordService!.answerWords.map((w) => w.value).toList(),
        _wordService!.guessWords.map((w) => w.value).toList(),
      );
      DebugLogger.success('✅ Word lists loaded to Rust successfully', tag: 'AppService');

      DebugLogger.info('🔧 Step 6: Creating GameService...', tag: 'AppService');
      // Step 6: Initialize GameService (depends on WordService)
      _gameService = GameService(wordService: _wordService!);

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
    _wordService = null;
    _gameService = null;
    // Services will be recreated on next initialize() call
  }
}
