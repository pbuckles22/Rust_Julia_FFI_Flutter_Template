import 'dart:math';

import '../exceptions/game_exceptions.dart';
import '../exceptions/service_exceptions.dart';
import '../models/game_state.dart';
import '../models/guess_result.dart';
import '../models/word.dart';
import '../utils/debug_logger.dart';
import 'ffi_service.dart';

/// Game progress analysis result
class GameProgressAnalysis {
  /// The current guess number (1-based)
  final int currentGuess;
  
  /// The maximum number of guesses allowed
  final int maxGuesses;
  
  /// The number of guesses remaining
  final int remainingGuesses;
  
  /// Whether the game is over
  final bool isGameOver;
  
  /// Whether the game was won
  final bool isWon;
  
  /// Whether the game was lost
  final bool isLost;
  
  /// Human-readable game status string
  final String gameStatus;
  
  /// Total number of guesses made
  final int guessCount;
  
  /// Game duration in seconds
  final int gameDuration;

  /// Creates a new game progress analysis
  const GameProgressAnalysis({
    required this.currentGuess,
    required this.maxGuesses,
    required this.remainingGuesses,
    required this.isGameOver,
    required this.isWon,
    required this.isLost,
    required this.gameStatus,
    required this.guessCount,
    required this.gameDuration,
  });
}

/// Guess effectiveness analysis result
class GuessEffectivenessAnalysis {
  /// Number of green (correct position) letters
  final int greenCount;
  
  /// Number of yellow (correct letter, wrong position) letters
  final int yellowCount;
  
  /// Number of gray (not in word) letters
  final int grayCount;
  
  /// Whether the guess was completely correct
  final bool isCorrect;
  
  /// Whether the guess has any correct letters
  final bool hasCorrectLetters;
  
  /// Whether the guess was effective for narrowing down possibilities
  final bool isEffective;

  /// Creates a new guess effectiveness analysis
  const GuessEffectivenessAnalysis({
    required this.greenCount,
    required this.yellowCount,
    required this.grayCount,
    required this.isCorrect,
    required this.hasCorrectLetters,
    required this.isEffective,
  });
}

/// GameService for managing Wordle game logic
///
/// Handles game creation, guess processing, and game state management
/// following TDD principles.
class GameService {
  GameState? _currentGame;

  /// Whether the service is initialized
  bool get isInitialized => FfiService.isInitialized;

  /// Current game state
  GameState? get currentGame => _currentGame;

  /// Whether there's an active game
  bool get hasActiveGame => _currentGame != null && !_currentGame!.isGameOver;

  /// Constructor
  GameService();

  /// Initializes the service
  Future<void> initialize() async {
    DebugLogger.info(
      '🔧 GameService: Starting initialization...',
      tag: 'GameService',
    );

    // GameService now uses centralized FFI for word validation
    // FFI service is responsible for loading word lists
    // GameService just needs to ensure FFI service is initialized
    DebugLogger.info(
      '🔧 GameService: Checking FFI service status...',
      tag: 'GameService',
    );

    // Initialize FFI service if not already initialized
    await FfiService.initialize();

    DebugLogger.success(
      '✅ GameService: Initialization complete!',
      tag: 'GameService',
    );
  }

  /// Creates a new game with a random target word
  GameState createNewGame({
    int maxGuesses = 5,
    Word? targetWord,
    List<Word>? wordList,
  }) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    // Select target word
    Word selectedTarget;
    if (targetWord != null) {
      selectedTarget = targetWord;
    } else if (wordList != null && wordList.isNotEmpty) {
      selectedTarget = _selectRandomTargetWordFromList(wordList);
    } else {
      selectedTarget = _selectRandomTargetWord();
    }

    // Create new game state
    _currentGame = GameState.newGame(
      targetWord: selectedTarget,
      maxGuesses: maxGuesses,
    );

    return _currentGame!;
  }

  /// Creates a new game with a specific target word
  GameState createNewGameWithTarget(Word targetWord, {int maxGuesses = 5}) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    // Target word is pre-validated during word list loading

    // Create new game state
    _currentGame = GameState.newGame(
      targetWord: targetWord,
      maxGuesses: maxGuesses,
    );

    return _currentGame!;
  }

  /// Processes a guess and returns the result
  GuessResult processGuess(GameState? gameState, Word? guess) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    if (gameState == null) {
      throw const InvalidGameStateException('Game state cannot be null');
    }

    if (guess == null) {
      throw const InvalidGuessException('Guess cannot be null');
    }

    // Guess word is pre-validated during word list loading

    // Check if guess is in the guess words list (not the smaller answer list)
    if (!FfiService.isValidWord(guess.value)) {
      throw const InvalidGuessException('Guess word not in word list');
    }

    // Check if target word exists
    if (gameState.targetWord == null) {
      throw const InvalidGameStateException('Game state has no target word');
    }

    // Create guess result
    final result = _evaluateGuess(guess, gameState.targetWord!);

    return result;
  }

  /// Adds a guess to the game state
  void addGuessToGame(GameState gameState, Word guess, GuessResult result) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    // Add guess to game state
    gameState.addGuess(guess, result);
  }

  /// Validates if a word is valid using centralized Rust validation
  bool isValidWord(Word word) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException('FFI service not initialized');
    }

    try {
      // Use centralized Rust validation - check if word exists in word list
      return FfiService.isValidWord(word.value);
    } catch (e) {
      DebugLogger.error(
        '❌ CRITICAL: Centralized word validation failed: $e',
        tag: 'GameService',
      );

      // HARD FAILURE: No fallback allowed - centralized validation must work
      throw Exception(
        'CRITICAL FAILURE: Centralized word validation is not working. '
        'This is a fatal error - the app cannot function without proper '
        'word validation. Error: $e',
      );
    }
  }

  /// Validates if a word has valid length
  bool isValidWordLength(Word word) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    try {
      return word.isValidLength;
    } on Exception catch (e) {
      return false;
    }
  }

  /// Validates if a word has valid characters
  bool isValidWordCharacters(Word word) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    try {
      return word.isValidCharacters;
    } on Exception catch (e) {
      return false;
    }
  }

  /// Validates if a word is not empty
  bool isValidWordNotEmpty(Word word) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    try {
      return word.isNotEmpty;
    } on Exception catch (e) {
      return false;
    }
  }

  /// Analyzes game progress
  GameProgressAnalysis analyzeGameProgress(GameState gameState) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    return GameProgressAnalysis(
      currentGuess: gameState.currentGuess,
      maxGuesses: gameState.maxGuesses,
      remainingGuesses: gameState.remainingGuesses,
      isGameOver: gameState.isGameOver,
      isWon: gameState.isWon,
      isLost: gameState.isLost,
      gameStatus: gameState.gameStatus.toString(),
      guessCount: gameState.guesses.length,
      gameDuration: gameState.gameDuration.inMilliseconds,
    );
  }

  /// Analyzes letter frequency in the game
  Map<String, int> analyzeLetterFrequency(GameState gameState) {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    final frequency = <String, int>{};

    for (final guessEntry in gameState.guesses) {
      for (final letter in guessEntry.word.value.split('')) {
        frequency[letter] = (frequency[letter] ?? 0) + 1;
      }
    }

    return frequency;
  }

  /// Analyzes guess effectiveness
  GuessEffectivenessAnalysis analyzeGuessEffectiveness(GuessResult result) => GuessEffectivenessAnalysis(
      greenCount: result.greenCount,
      yellowCount: result.yellowCount,
      grayCount: result.grayCount,
      isCorrect: result.isCorrect,
      hasCorrectLetters: result.hasCorrectLetters,
      isEffective:
          (result.greenCount + result.yellowCount) /
              result.letterStates.length >
          0.5,
    );

  /// Suggests the next guess
  Word? suggestNextGuess(GameState gameState) {
    DebugLogger.debug('suggestNextGuess called', tag: 'GameService');

    if (!isInitialized) {
      DebugLogger.error('GameService not initialized', tag: 'GameService');
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    DebugLogger.debug(
      'GameState: guesses=${gameState.guesses.length}, '
      'isGameOver=${gameState.isGameOver}',
      tag: 'GameService',
    );

    try {
      final suggestion = getBestNextGuess(gameState);
      if (suggestion != null) {
        DebugLogger.success(
          'Generated suggestion: ${suggestion.value}',
          tag: 'GameService',
        );
      } else {
        DebugLogger.warning(
          'getBestNextGuess returned null',
          tag: 'GameService',
        );
      }
      return suggestion;
    } on Exception catch (e, stackTrace) {
      DebugLogger.error(
        'Error in suggestNextGuess: $e',
        tag: 'GameService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Makes a guess in the current game
  Future<GuessResult> makeGuess(String guessWord) async {
    if (!isInitialized) {
      throw const ServiceNotInitializedException(
        'Word service not initialized',
      );
    }

    if (_currentGame == null) {
      throw const InvalidGameStateException('No active game');
    }

    if (_currentGame!.isGameOver) {
      throw const GameOverException('Game is over');
    }

    // Validate guess word
    final guess = Word.fromString(guessWord);
    // Guess word is pre-validated during word list loading

    // Check if guess is in the guess words list (not the smaller answer list)
    if (!FfiService.isValidWord(guessWord)) {
      throw const InvalidGuessException('Guess word not in word list');
    }

    // Create guess result
    final result = _evaluateGuess(guess, _currentGame!.targetWord!);

    // Add guess to game state
    _currentGame!.addGuess(guess, result);

    return result;
  }

  /// Evaluates a guess against the target word
  GuessResult _evaluateGuess(Word guess, Word target) {
    final letterStates = <LetterState>[];
    final targetLetters = target.value.split('');
    final guessLetters = guess.value.split('');

    // First pass: mark exact matches (green)
    for (var i = 0; i < guessLetters.length; i++) {
      if (i < targetLetters.length && guessLetters[i] == targetLetters[i]) {
        letterStates.add(LetterState.green);
        targetLetters[i] = ''; // Mark as used
      } else {
        letterStates.add(LetterState.gray); // Will be updated in second pass
      }
    }

    // Second pass: mark partial matches (yellow)
    for (var i = 0; i < guessLetters.length; i++) {
      if (i < letterStates.length && letterStates[i] == LetterState.gray) {
        final letter = guessLetters[i];
        final targetIndex = targetLetters.indexOf(letter);
        if (targetIndex != -1) {
          letterStates[i] = LetterState.yellow;
          targetLetters[targetIndex] = ''; // Mark as used
        }
      }
    }

    return GuessResult(word: guess, letterStates: letterStates);
  }

  /// Selects a random target word from the word list
  Word _selectRandomTargetWord() {
    // Use centralized Rust word list instead of WordService
    final answerWords = FfiService.getAnswerWords();
    if (answerWords.isEmpty) {
      throw const InvalidGameStateException('No words available');
    }

    final random = Random();
    final selectedWord = answerWords[random.nextInt(answerWords.length)];
    return Word.fromString(selectedWord);
  }

  /// Selects a random target word from a provided word list
  Word _selectRandomTargetWordFromList(List<Word> wordList) {
    final random = Random();
    return wordList[random.nextInt(wordList.length)];
  }

  /// Gets the current game state
  GameState? getGameState() => _currentGame;

  /// Resets the current game
  void resetGame() {
    _currentGame = null;
  }

  /// Gets game statistics
  Map<String, dynamic> getGameStatistics() {
    if (_currentGame == null) {
      throw const InvalidGameStateException('No active game');
    }

    return {
      'currentGuess': _currentGame!.currentGuess,
      'maxGuesses': _currentGame!.maxGuesses,
      'isGameOver': _currentGame!.isGameOver,
      'isWon': _currentGame!.isWon,
      'isLost': _currentGame!.isLost,
      'gameStatus': _currentGame!.gameStatus.toString(),
      'guesses': _currentGame!.guesses.length,
    };
  }

  /// Gets available words for guessing
  List<Word> getAvailableWords() {
    if (!isInitialized) {
      throw const ServiceNotInitializedException('FFI service not initialized');
    }

    // Use centralized Rust word list instead of WordService
    final guessWords = FfiService.getGuessWords();
    return guessWords.map(Word.fromString).toList();
  }

  /// Filters the word list based on the current game state's guess history.
  /// This method now correctly uses the high-performance Rust filtering
  /// function.
  List<Word> getFilteredWords([GameState? gameState]) {
    final state = gameState ?? _currentGame;
    if (state == null || state.guesses.isEmpty) {
      // If no guesses have been made, all words are possible
      // Use centralized Rust word list instead of WordService
      // Use answer words (2,300) to match Rust benchmark behavior
      final answerWords = FfiService.getAnswerWords();
      return answerWords.map(Word.fromString).toList();
    }

    // Convert the game state's guesses into the format required by the FFI
    // function
    final ffiGuessResults = state.guesses.map((guessEntry) {
      final pattern = guessEntry.result.letterStates.map((state) {
        switch (state) {
          case LetterState.gray:
            return 'X';
          case LetterState.yellow:
            return 'Y';
          case LetterState.green:
            return 'G';
        }
      }).toList();
      return (guessEntry.word.value, pattern);
    }).toList();

    // Call the WORKING Rust filter function
    // Use answer words (2,300) to match Rust benchmark behavior
    final filteredWordStrings = FfiService.filterWords(
      FfiService.getAnswerWords(),
      ffiGuessResults,
    );

    // Convert the filtered strings back to Word objects
    return filteredWordStrings
        .map(Word.fromString)
        .toList();
  }

  /// Gets the best next guess based on current game state using Rust FFI
  /// intelligent solver
  Word? getBestNextGuess([GameState? gameState]) {
    final state = gameState ?? _currentGame;
    if (state == null) {
      return null;
    }

    try {
      // Use Rust FFI intelligent solver for world-class performance
      return _getIntelligentGuess(state);
    } catch (e) {
      DebugLogger.error(
        '❌ CRITICAL: FFI intelligent solver failed: $e',
        tag: 'GameService',
      );

      // HARD FAILURE: No fallback allowed - FFI solver must work
      throw Exception(
        'CRITICAL FAILURE: FFI intelligent solver is not working. '
        'This is a fatal error - the app cannot function without the Rust '
        'algorithm. Error: $e',
      );
    }
  }

  /// Gets intelligent guess using new client-server architecture
  /// Client passes game state, server handles all filtering and logic
  Word? _getIntelligentGuess(GameState gameState) {
    // Convert game state to FFI format
    final guessResults = gameState.guesses.map((guessEntry) {
      final pattern = guessEntry.result.letterStates.map((state) {
        switch (state) {
          case LetterState.gray:
            return 'X';
          case LetterState.yellow:
            return 'Y';
          case LetterState.green:
            return 'G';
        }
      }).toList();
      return (guessEntry.word.value, pattern);
    }).toList();

    // DEBUG: Show complete game state payload (same as benchmark)
    print('🔍 DART GAME STATE PAYLOAD - Attempt ${gameState.currentGuess}');
    print('  • Total constraints: ${guessResults.length}');
    print('  • Complete payload structure:');
    print('    guess_results: Vec<(String, List<String>)> = [');
    for (int i = 0; i < guessResults.length; i++) {
      final (word, pattern) = guessResults[i];
      print('      ("$word", ${pattern}), // constraint ${i + 1}');
    }
    print('    ]');
    print('  • This is the EXACT payload passed to: FfiService.getBestGuess(guessResults)');

    // NEW ARCHITECTURE: Pass game state to server, server handles everything
    String? suggestion;
    try {
      // For first guess (no constraints), use optimal first guess
      if (guessResults.isEmpty) {
        print('  • First guess - using optimal first guess');
        suggestion = FfiService.getOptimalFirstGuess();
      }
      
      // For subsequent guesses, use main algorithm with server-side filtering
      if (suggestion == null) {
        print('  • Subsequent guess - using server-side algorithm');
        suggestion = FfiService.getBestGuess(guessResults);
      }
      
      if (suggestion != null) {
        print('  • Algorithm suggested: $suggestion');
      } else {
        print('  • Algorithm returned null');
      }
    } on Exception catch (e) {
      print('  • FFI solver failed: $e');
      DebugLogger.warning(
        'FFI solver failed: $e',
        tag: 'GameService',
      );
      return null;
    }

    if (suggestion != null) {
      return Word.fromString(suggestion);
    }

    return null;
  }

  // REMOVED: All naive strategy methods
  // No fallback strategies allowed - FFI solver must work
  // This ensures we never silently degrade to inferior algorithms

  /// Validates a guess word
  bool isValidGuess(String guessWord) {
    if (!isInitialized) {
      return false;
    }

    try {
      // Validate against the guess words list using centralized FFI
      return FfiService.isValidWord(guessWord);
    } on Exception catch (e) {
      return false;
    }
  }

  /// Gets game hints
  Map<String, dynamic> getGameHints() {
    if (_currentGame == null) {
      throw const InvalidGameStateException('No active game');
    }

    final hints = <String, dynamic>{
      'availableWords': getFilteredWords().length,
      'bestGuess': getBestNextGuess()?.value,
      'gameProgress': {
        'currentGuess': _currentGame!.currentGuess,
        'maxGuesses': _currentGame!.maxGuesses,
        'remainingGuesses':
            _currentGame!.maxGuesses - _currentGame!.currentGuess,
      },
    };

    return hints;
  }
}
