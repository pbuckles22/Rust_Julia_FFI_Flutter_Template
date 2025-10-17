import '../exceptions/service_exceptions.dart';
import '../src/rust/api/simple.dart' as ffi;
import '../src/rust/frb_generated.dart';
import '../utils/debug_logger.dart';

/// Configuration class for FFI settings
class FfiConfiguration {
  /// Whether to use reference mode for optimal performance
  final bool referenceMode;
  
  /// Whether to include killer words in analysis
  final bool includeKillerWords;
  
  /// Maximum number of candidates to consider
  final int candidateCap;
  
  /// Whether early termination is enabled
  final bool earlyTerminationEnabled;
  
  /// Threshold for early termination
  final double earlyTerminationThreshold;
  
  /// Whether to use entropy-only scoring
  final bool entropyOnlyScoring;

  /// Creates a new FFI configuration
  const FfiConfiguration({
    required this.referenceMode,
    required this.includeKillerWords,
    required this.candidateCap,
    required this.earlyTerminationEnabled,
    required this.earlyTerminationThreshold,
    required this.entropyOnlyScoring,
  });
}

/// FFI Service for calling Rust functions from Flutter
///
/// This service provides a clean interface to the Rust FFI functions,
/// handling initialization, error conversion, and type mapping.
class FfiService {
  static bool _isInitialized = false;
  static FfiConfiguration _currentConfig = const FfiConfiguration(
    referenceMode: false,
    includeKillerWords: false,
    candidateCap: 200,
    earlyTerminationEnabled: true,
    earlyTerminationThreshold: 5,
    entropyOnlyScoring: false,
  );

  /// Whether the FFI service is initialized (static getter)
  static bool get isInitialized => _isInitialized;

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
        if (e.toString().contains(
          'Should not initialize flutter_rust_bridge twice',
        )) {
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

  /// Get best guess using the REFERENCE algorithm (99.8% success rate)
  /// 
  /// This uses the exact same algorithm that achieved 99.8% success rate
  /// in the Rust benchmark. This is the high-performance reference
  /// implementation.
  static String? getBestGuessReference(
    List<String> remainingWords,
    List<(String, List<String>)> guessResults,
  ) {
    _ensureInitialized();
    try {
      return ffi.getIntelligentGuessReference(
        remainingWords: remainingWords,
        guessResults: guessResults,
      );
    } catch (e) {
      throw AssetLoadException('Failed to get best guess (reference): $e');
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
      DebugLogger.success(
        '✅ Successfully loaded ${answerWords.length} answer words and '
        '${guessWords.length} guess words to Rust',
        tag: 'FfiService',
      );
    } catch (e) {
      throw AssetLoadException('Failed to load word lists to Rust: $e');
    }
  }


  /// Validate that a word is valid (5 letters, all uppercase)
  /// Returns true if valid, false otherwise
  static bool validateWord(String word) {
    _ensureInitialized();

    try {
      // First check basic format - 5 letters, all uppercase
      if (word.length != 5 ||
          word != word.toUpperCase() ||
          !word.contains(RegExp(r'^[A-Z]+$'))) {
        return false;
      }
      
      // For now, just check basic format - the word list validation will be
      // handled
      // by the game service when it processes guesses
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  /// Ensure the service is initialized
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw const ServiceNotInitializedException(
        'FFI service not initialized. Call FfiService.initialize() first.',
      );
    }
  }

  // ===========================================================================
  // Configuration Methods
  // ===========================================================================

  /// Get the current configuration
  static FfiConfiguration getConfiguration() => _currentConfig;

  /// Set the configuration
  static void setConfiguration(FfiConfiguration config) {
    _currentConfig = config;
    
    // Configuration is now handled entirely in Dart
    // The Rust solver uses its own internal configuration
  }

  /// Apply reference mode preset configuration
  static void applyReferenceModePreset() {
    _currentConfig = const FfiConfiguration(
      referenceMode: true,
      includeKillerWords: true,
      candidateCap: 1000,
      earlyTerminationEnabled: false,
      earlyTerminationThreshold: 10.0,
      entropyOnlyScoring: true,
    );
  }

  /// Reset to default configuration
  static void resetToDefaultConfiguration() {
    _currentConfig = const FfiConfiguration(
      referenceMode: false,
      includeKillerWords: false,
      candidateCap: 200,
      earlyTerminationEnabled: true,
      earlyTerminationThreshold: 5,
      entropyOnlyScoring: false,
    );
  }

  /// Get answer words from Rust (centralized word list management)
  /// 
  /// This eliminates the need for Flutter to manage word lists.
  /// All word list management is now centralized in Rust.
  static List<String> getAnswerWords() {
    _ensureInitialized();
    try {
      return ffi.getAnswerWords();
    } catch (e) {
      throw AssetLoadException('Failed to get answer words: $e');
    }
  }

  /// Get guess words from Rust (centralized word list management)
  /// 
  /// This eliminates the need for Flutter to manage word lists.
  /// All word list management is now centralized in Rust.
  static List<String> getGuessWords() {
    _ensureInitialized();
    try {
      return ffi.getGuessWords();
    } catch (e) {
      throw AssetLoadException('Failed to get guess words: $e');
    }
  }

  /// Check if a word is valid (centralized validation)
  /// 
  /// This eliminates the need for Flutter to manage word validation.
  /// All word validation is now centralized in Rust.
  static bool isValidWord(String word) {
    _ensureInitialized();
    try {
      return ffi.isValidWord(word: word);
    } on Exception catch (e) {
      return false; // Fail gracefully for validation
    }
  }

  // ============================================================================
  // Cargo Benchmark FFI Functions (Exact Match)
  // ============================================================================

  /// Initialize benchmark solver (exactly like Cargo benchmark)
  /// 
  /// This function initializes the solver with all 14,855 words for maximum coverage,
  /// exactly matching the Cargo benchmark approach that achieved 99.8% success rate.
  static void initializeBenchmarkSolver() {
    _ensureInitialized();
    try {
      ffi.initializeBenchmarkSolver();
    } catch (e) {
      throw AssetLoadException('Failed to initialize benchmark solver: $e');
    }
  }


  /// Filter words based on feedback (exactly like Cargo benchmark)
  /// 
  /// This function replicates the Cargo benchmark's filter_words_with_feedback logic:
  /// - word_matches_all_feedback for each word
  /// - Same pattern matching logic as the benchmark
  static List<String> filterBenchmarkWords(
    List<String> words,
    List<(String, List<String>)> guessResults,
  ) {
    _ensureInitialized();
    try {
      return ffi.filterBenchmarkWords(
        words: words,
        guessResults: guessResults,
      );
    } catch (e) {
      throw AssetLoadException('Failed to filter benchmark words: $e');
    }
  }

  // ============================================================================
  // NEW CLIENT-SERVER ARCHITECTURE FUNCTIONS
  // ============================================================================

  /// Get best guess from game state (NEW CLIENT-SERVER ARCHITECTURE)
  /// 
  /// This function takes game state, filters words internally, and returns best guess.
  /// This is the main entry point for the new architecture.
  /// Server handles all filtering internally - client just passes game state.
  static String? getBestGuess(
    List<(String, List<String>)> guessResults,
  ) {
    _ensureInitialized();
    try {
      return ffi.getBestGuess(
        guessResults: guessResults,
      );
    } catch (e) {
      throw AssetLoadException('Failed to get best guess: $e');
    }
  }
}
