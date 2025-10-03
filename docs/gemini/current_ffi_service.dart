import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/src/rust/api/simple.dart' as ffi;
import 'package:wrdlhelper/exceptions/service_exceptions.dart';

/// FFI Service for calling Rust functions from Flutter
///
/// This service provides a clean interface to the Rust FFI functions,
/// handling initialization, error conversion, and type mapping.
class FfiService {
  static bool _isInitialized = false;

  /// Whether the FFI service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the FFI service
  /// This must be called before using any FFI functions
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize the FFI bridge (handle case where it's already initialized)
      try {
        await RustLib.init();
      } catch (e) {
        // If FFI is already initialized, that's fine - continue
        if (e.toString().contains('Should not initialize flutter_rust_bridge twice')) {
          // FFI bridge already initialized, continue
        } else {
          rethrow;
        }
      }

      // Initialize word lists in Rust for optimal performance
      ffi.initializeWordLists();

      _isInitialized = true;
    } catch (e) {
      throw ServiceNotInitializedException(
        'Failed to initialize FFI service: $e',
      );
    }
  }

  /// Filter words based on guess results
  /// Returns the filtered list of remaining words
  static List<String> filterWords(
    List<String> allWords,
    List<(String, List<String>)> guessResults,
  ) {
    _ensureInitialized();

    try {
      // Call our filterWords function
      return ffi.filterWords(words: allWords, guessResults: guessResults);
    } catch (e) {
      throw AssetLoadException('Failed to filter words: $e');
    }
  }

  /// Get the best guess suggestion from remaining words
  /// Returns null if no suggestion is available
  static String? getBestGuess(
    List<String> allWords,
    List<String> remainingWords,
    List<(String, List<String>)> guessResults,
  ) {
    _ensureInitialized();

    try {
      // Call our getIntelligentGuess function
      return ffi.getIntelligentGuess(
        allWords: allWords,
        remainingWords: remainingWords,
        guessResults: guessResults,
      );
    } catch (e) {
      throw AssetLoadException('Failed to get best guess: $e');
    }
  }

  /// Get best guess using optimized Rust-managed word lists (much faster)
  static String? getBestGuessFast(
    List<String> remainingWords,
    List<(String, List<String>)> guessResults,
  ) {
    _ensureInitialized();
    try {
      return ffi.getIntelligentGuessFast(
        remainingWords: remainingWords,
        guessResults: guessResults,
      );
    } catch (e) {
      throw AssetLoadException('Failed to get best guess (fast): $e');
    }
  }

  /// Get the optimal first guess (pre-computed at startup)
  /// 
  /// This returns the optimal first guess that was computed once at startup.
  /// This avoids the expensive computation of analyzing all 14,854 words.
  /// 
  /// Performance: < 1ms (just a lookup)
  static String? getOptimalFirstGuess() {
    _ensureInitialized();
    try {
      return ffi.getOptimalFirstGuess();
    } catch (e) {
      throw AssetLoadException('Failed to get optimal first guess: $e');
    }
  }

  /// Calculate entropy for a candidate word
  /// Returns the entropy value
  static double calculateEntropy(
    String candidateWord,
    List<String> remainingWords,
  ) {
    _ensureInitialized();

    try {
      // Call our calculateEntropy function
      return ffi.calculateEntropy(
        candidateWord: candidateWord,
        remainingWords: remainingWords,
      );
    } catch (e) {
      throw AssetLoadException('Failed to calculate entropy: $e');
    }
  }

  /// Simulate guess pattern for a guess and target word
  /// Returns the pattern string (e.g., "GGYXY")
  static String simulateGuessPattern(
    String guess,
    String target,
  ) {
    _ensureInitialized();

    try {
      // Call our simulateGuessPattern function
      return ffi.simulateGuessPattern(guess: guess, target: target);
    } catch (e) {
      throw AssetLoadException('Failed to simulate guess pattern: $e');
    }
  }

  /// Load word lists from JSON file
  /// Returns all words from the JSON file
  static Future<List<String>> loadWordListsFromJsonFile(String jsonPath) async {
    _ensureInitialized();

    try {
      // For now, return a simple hardcoded list
      // TODO: Implement actual JSON loading
      return [
        'CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE', 'CHASE', 'CLOTH', 'CLOUD',
        'SLOTH', 'BLIMP', 'WORLD', 'HELLO', 'FLUTE', 'PRIDE', 'SHINE', 'BRAVE', 'QUICK'
      ];
    } catch (e) {
      throw AssetLoadException('Failed to load word lists from JSON: $e');
    }
  }

  /// Load word lists from Dart to Rust (CRITICAL for performance)
  /// 
  /// This function passes the actual word lists from Dart to Rust,
  /// replacing the hardcoded 18 words with the full 15k+ word lists.
  /// This is essential for the algorithms to work properly.
  static void loadWordListsToRust(
    List<String> answerWords,
    List<String> guessWords,
  ) {
    _ensureInitialized();

    try {
      ffi.loadWordListsFromDart(
        answerWords: answerWords,
        guessWords: guessWords,
      );
      print('✅ Successfully loaded ${answerWords.length} answer words and ${guessWords.length} guess words to Rust');
    } catch (e) {
      throw AssetLoadException('Failed to load word lists to Rust: $e');
    }
  }


  /// Validate that a word is valid (5 letters, all uppercase)
  /// Returns true if valid, false otherwise
  static bool validateWord(String word) {
    _ensureInitialized();

    try {
      // Simple validation - 5 letters, all uppercase
      return word.length == 5 && word == word.toUpperCase() && word.contains(RegExp(r'^[A-Z]+$'));
    } catch (e) {
      return false;
    }
  }

  /// Ensure the service is initialized
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw ServiceNotInitializedException(
        'FFI service not initialized. Call FfiService.initialize() first.',
      );
    }
  }
}