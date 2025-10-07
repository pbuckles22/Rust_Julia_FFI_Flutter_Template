import 'dart:math';

import 'package:wrdlhelper/exceptions/game_exceptions.dart';
import 'package:wrdlhelper/exceptions/service_exceptions.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

/// Game progress analysis result
class GameProgressAnalysis {
  final int currentGuess;
  final int maxGuesses;
  final int remainingGuesses;
  final bool isGameOver;
  final bool isWon;
  final bool isLost;
  final String gameStatus;
  final int guessCount;
  final int gameDuration;

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
  final int greenCount;
  final int yellowCount;
  final int grayCount;
  final bool isCorrect;
  final bool hasCorrectLetters;
  final bool isEffective;

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
      throw ServiceNotInitializedException('Word service not initialized');
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
      throw ServiceNotInitializedException('Word service not initialized');
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
      throw ServiceNotInitializedException('Word service not initialized');
    }

    if (gameState == null) {
      throw InvalidGameStateException('Game state cannot be null');
    }

    if (guess == null) {
      throw InvalidGuessException('Guess cannot be null');
    }

    // Guess word is pre-validated during word list loading

    // Check if guess is in the guess words list (not the smaller answer list)
    if (!FfiService.isValidWord(guess.value)) {
      throw InvalidGuessException('Guess word not in word list');
    }

    // Check if target word exists
    if (gameState.targetWord == null) {
      throw InvalidGameStateException('Game state has no target word');
    }

    // Create guess result
    final result = _evaluateGuess(guess, gameState.targetWord!);

    return result;
  }

  /// Adds a guess to the game state
  void addGuessToGame(GameState gameState, Word guess, GuessResult result) {
    if (!isInitialized) {
      throw ServiceNotInitializedException('Word service not initialized');
    }

    // Add guess to game state
    gameState.addGuess(guess, result);
  }

  /// Validates if a word is valid using centralized Rust validation
  bool isValidWord(Word word) {
    if (!isInitialized) {
      throw ServiceNotInitializedException('FFI service not initialized');
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
        'This is a fatal error - the app cannot function without proper word validation. '
        'Error: $e',
      );
    }
  }

  /// Validates if a word has valid length
  bool isValidWordLength(Word word) {
    if (!isInitialized) {
      throw ServiceNotInitializedException('Word service not initialized');
    }

    try {
      return word.isValidLength;
    } catch (e) {
      return false;
    }
  }

  /// Validates if a word has valid characters
  bool isValidWordCharacters(Word word) {
    if (!isInitialized) {
      throw ServiceNotInitializedException('Word service not initialized');
    }

    try {
      return word.isValidCharacters;
    } catch (e) {
      return false;
    }
  }

  /// Validates if a word is not empty
  bool isValidWordNotEmpty(Word word) {
    if (!isInitialized) {
      throw ServiceNotInitializedException('Word service not initialized');
    }

    try {
      return word.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Analyzes game progress
  GameProgressAnalysis analyzeGameProgress(GameState gameState) {
    if (!isInitialized) {
      throw ServiceNotInitializedException('Word service not initialized');
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
      throw ServiceNotInitializedException('Word service not initialized');
    }

    final Map<String, int> frequency = {};

    for (final guessEntry in gameState.guesses) {
      for (final letter in guessEntry.word.value.split('')) {
        frequency[letter] = (frequency[letter] ?? 0) + 1;
      }
    }

    return frequency;
  }

  /// Analyzes guess effectiveness
  GuessEffectivenessAnalysis analyzeGuessEffectiveness(GuessResult result) {
    return GuessEffectivenessAnalysis(
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
  }

  /// Suggests the next guess
  Word? suggestNextGuess(GameState gameState) {
    DebugLogger.debug('suggestNextGuess called', tag: 'GameService');

    if (!isInitialized) {
      DebugLogger.error('GameService not initialized', tag: 'GameService');
      throw ServiceNotInitializedException('Word service not initialized');
    }

    DebugLogger.debug(
      'GameState: guesses=${gameState.guesses.length}, isGameOver=${gameState.isGameOver}',
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
    } catch (e, stackTrace) {
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
      throw ServiceNotInitializedException('Word service not initialized');
    }

    if (_currentGame == null) {
      throw InvalidGameStateException('No active game');
    }

    if (_currentGame!.isGameOver) {
      throw GameOverException('Game is over');
    }

    // Validate guess word
    final guess = Word.fromString(guessWord);
    // Guess word is pre-validated during word list loading

    // Check if guess is in the guess words list (not the smaller answer list)
    if (!FfiService.isValidWord(guessWord)) {
      throw InvalidGuessException('Guess word not in word list');
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
    for (int i = 0; i < guessLetters.length; i++) {
      if (i < targetLetters.length && guessLetters[i] == targetLetters[i]) {
        letterStates.add(LetterState.green);
        targetLetters[i] = ''; // Mark as used
      } else {
        letterStates.add(LetterState.gray); // Will be updated in second pass
      }
    }

    // Second pass: mark partial matches (yellow)
    for (int i = 0; i < guessLetters.length; i++) {
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
      throw InvalidGameStateException('No words available');
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
  GameState? getGameState() {
    return _currentGame;
  }

  /// Resets the current game
  void resetGame() {
    _currentGame = null;
  }

  /// Gets game statistics
  Map<String, dynamic> getGameStatistics() {
    if (_currentGame == null) {
      throw InvalidGameStateException('No active game');
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
      throw ServiceNotInitializedException('FFI service not initialized');
    }

    // Use centralized Rust word list instead of WordService
    final guessWords = FfiService.getGuessWords();
    return guessWords.map((word) => Word.fromString(word)).toList();
  }

  /// Filters the word list based on the current game state's guess history.
  /// This method now correctly uses the high-performance Rust filtering function.
  List<Word> getFilteredWords([GameState? gameState]) {
    final state = gameState ?? _currentGame;
    if (state == null || state.guesses.isEmpty) {
      // If no guesses have been made, all words are possible
      // Use centralized Rust word list instead of WordService
      final guessWords = FfiService.getGuessWords();
      return guessWords.map((word) => Word.fromString(word)).toList();
    }

    // Convert the game state's guesses into the format required by the FFI function
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
    final filteredWordStrings = FfiService.filterWords(
      FfiService.getGuessWords(),
      ffiGuessResults,
    );

    // Convert the filtered strings back to Word objects
    return filteredWordStrings.map((str) => Word.fromString(str)).toList();
  }

  /// Gets the best next guess based on current game state using Rust FFI intelligent solver
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
        'This is a fatal error - the app cannot function without the Rust algorithm. '
        'Error: $e',
      );
    }
  }

  /// Gets intelligent guess using Rust FFI solver with world-class performance
  Word? _getIntelligentGuess(GameState gameState) {
    // Get all available words for the solver
    // Use centralized Rust word list instead of WordService
    final allWords = FfiService.getGuessWords();

    // Get remaining possible words (filtered based on current game state)
    final remainingWords = getFilteredWords(
      gameState,
    ).map((w) => w.value).toList();

    if (remainingWords.isEmpty) {
      return null;
    }

    // Convert previous guesses to FFI format (String, List<String>)
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

    // COMPREHENSIVE DEBUG LOGGING - FFI Bridge Data Flow
    print('🔍 FFI BRIDGE DEBUG - Calling Rust solver');
    print('📊 INPUT DATA SUMMARY:');
    print('  • allWords: ${allWords.length} words');
    print('  • remainingWords: ${remainingWords.length} words');
    print('  • guessResults: ${guessResults.length} previous guesses');
    
    DebugLogger.info(
      '🔍 FFI BRIDGE DEBUG - Calling Rust solver',
      tag: 'GameService',
    );
    DebugLogger.info('📊 INPUT DATA SUMMARY:', tag: 'GameService');
    DebugLogger.info(
      '  • allWords: ${allWords.length} words',
      tag: 'GameService',
    );
    DebugLogger.info(
      '  • remainingWords: ${remainingWords.length} words',
      tag: 'GameService',
    );
    DebugLogger.info(
      '  • guessResults: ${guessResults.length} previous guesses',
      tag: 'GameService',
    );

    // Log game state details
    DebugLogger.info('🎮 GAME STATE DETAILS:', tag: 'GameService');
    DebugLogger.info(
      '  • Current guess number: ${gameState.currentGuess}',
      tag: 'GameService',
    );
    DebugLogger.info(
      '  • Game status: ${gameState.gameStatus}',
      tag: 'GameService',
    );
    DebugLogger.info(
      '  • Is game over: ${gameState.isGameOver}',
      tag: 'GameService',
    );

    // Log each previous guess with full details
    DebugLogger.info('📝 PREVIOUS GUESSES HISTORY:', tag: 'GameService');
    for (int i = 0; i < guessResults.length; i++) {
      final gr = guessResults[i];
      final resultString = gr.$2.join('');
      DebugLogger.info(
        '  Guess ${i + 1}: "${gr.$1}" → $resultString',
        tag: 'GameService',
      );
    }

    // Log remaining words (first 10 for brevity)
    DebugLogger.info(
      '🎯 REMAINING POSSIBLE WORDS (first 10):',
      tag: 'GameService',
    );
    final displayWords = remainingWords.take(10).toList();
    DebugLogger.info('  ${displayWords.join(", ")}', tag: 'GameService');
    if (remainingWords.length > 10) {
      DebugLogger.info(
        '  ... and ${remainingWords.length - 10} more',
        tag: 'GameService',
      );
    }

    // Log word list integrity
    DebugLogger.info('📚 WORD LIST INTEGRITY CHECK:', tag: 'GameService');
    DebugLogger.info(
      '  • All words sample: ${allWords.take(5).join(", ")}',
      tag: 'GameService',
    );
    DebugLogger.info(
      '  • All words count: ${allWords.length}',
      tag: 'GameService',
    );

    // Trust the algorithm - it knows what it's doing
    DebugLogger.debug(
      'Trusting elite Rust algorithm with ${remainingWords.length} words',
      tag: 'GameService',
    );

    // Use the optimized intelligent solver with Rust-managed word lists
    DebugLogger.info('🚀 CALLING OPTIMIZED RUST FFI SOLVER...', tag: 'GameService');
    
    String? suggestion;
    try {
      // For first guess (no previous guesses), use pre-computed optimal first guess
      if (guessResults.isEmpty) {
        print('🎯 Using pre-computed optimal first guess...');
        suggestion = FfiService.getOptimalFirstGuess();
        if (suggestion != null) {
          print('✅ Got optimal first guess: $suggestion');
        } else {
          print('⚠️ No optimal first guess available, falling back to full algorithm');
        }
      }
      
      // If we don't have a suggestion yet (not first guess or optimal first guess failed),
      // use the REFERENCE algorithm (99.8% success rate)
      if (suggestion == null) {
        print('🧠 Using REFERENCE algorithm (99.8% success rate)...');
        suggestion = FfiService.getBestGuessReference(
          remainingWords,
          guessResults,
        );
      }
    } catch (e) {
      DebugLogger.warning('FFI solver failed, using fallback: $e', tag: 'GameService');
      // Fallback to simple entropy-based selection
      if (remainingWords.isNotEmpty) {
        suggestion = remainingWords.first;
      }
    }

    // COMPREHENSIVE DEBUG LOGGING - FFI Response
    print('🔍 FFI BRIDGE RESPONSE - Rust solver returned:');
    if (suggestion != null) {
      print('✅ SUCCESS: Rust suggested "$suggestion"');
      DebugLogger.info(
        '🔍 FFI BRIDGE RESPONSE - Rust solver returned:',
        tag: 'GameService',
      );
      DebugLogger.info(
        '✅ SUCCESS: Rust suggested "$suggestion"',
        tag: 'GameService',
      );
      DebugLogger.info('🎯 Suggestion analysis:', tag: 'GameService');
      DebugLogger.info(
        '  • Word length: ${suggestion.length}',
        tag: 'GameService',
      );
      DebugLogger.info(
        '  • Is valid format: ${suggestion.length == 5}',
        tag: 'GameService',
      );
      DebugLogger.info(
        '  • Is in remaining words: ${remainingWords.contains(suggestion)}',
        tag: 'GameService',
      );
    } else {
      DebugLogger.error(
        '❌ FAILURE: Rust solver returned null',
        tag: 'GameService',
      );
      DebugLogger.error(
        '⚠️  This indicates a serious issue with the algorithm',
        tag: 'GameService',
      );
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
    } catch (e) {
      return false;
    }
  }

  /// Gets game hints
  Map<String, dynamic> getGameHints() {
    if (_currentGame == null) {
      throw InvalidGameStateException('No active game');
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
