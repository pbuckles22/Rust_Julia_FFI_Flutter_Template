import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/guess_result.dart';
import '../models/word.dart';
import '../service_locator.dart';
import '../services/app_service.dart';
import '../services/ffi_service.dart';
import '../services/game_service.dart';
import '../src/rust/api/simple.dart' as ffi;
import '../utils/debug_logger.dart';
import '../widgets/game_grid.dart';
import '../widgets/letter_tile.dart';
import '../widgets/virtual_keyboard.dart';

/// Main Wordle helper screen
///
/// This screen provides a Wordle helper interface including:
/// - Game grid to track guesses and results
/// - Virtual keyboard to input guesses
/// - Analysis and suggestions for next moves
/// - New game button to start helping with a new puzzle
class WordleGameScreen extends StatefulWidget {
  /// Creates a new Wordle game screen
  const WordleGameScreen({super.key});

  @override
  State<WordleGameScreen> createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends State<WordleGameScreen> {
  // Services are now accessed through AppService singleton
  GameState? _gameState;
  bool _isInitialized = false;
  String _currentInput = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      DebugLogger.info(
        '🔧 WordleGameScreen: Starting service initialization...',
        tag: 'WordleGameScreen',
      );

      // Get services from service locator
      DebugLogger.info(
        '🔧 WordleGameScreen: Getting services from service locator...',
        tag: 'WordleGameScreen',
      );

      // Check if services are registered before accessing them
      if (!sl.isRegistered<AppService>()) {
        throw StateError(
          'AppService is not registered in service locator. '
          'Call setupServices() or setupTestServices() first.',
        );
      }
      if (!sl.isRegistered<GameService>()) {
        throw StateError(
          'GameService is not registered in service locator. '
          'Call setupServices() or setupTestServices() first.',
        );
      }

      final appService = sl<AppService>();
      final gameService = sl<GameService>();
      DebugLogger.success(
        '✅ WordleGameScreen: Services retrieved successfully',
        tag: 'WordleGameScreen',
      );

      // Verify services are initialized
      DebugLogger.info(
        '🔧 WordleGameScreen: Checking if AppService is initialized...',
        tag: 'WordleGameScreen',
      );
      if (!appService.isInitialized) {
        DebugLogger.info(
          '🔧 WordleGameScreen: AppService not initialized, '
          'initializing now...',
          tag: 'WordleGameScreen',
        );
        await appService.initialize();
        DebugLogger.success(
          '✅ WordleGameScreen: AppService initialized successfully',
          tag: 'WordleGameScreen',
        );
      } else {
        DebugLogger.success(
          '✅ WordleGameScreen: AppService already initialized',
          tag: 'WordleGameScreen',
        );
      }

      DebugLogger.info(
        '🔧 WordleGameScreen: Creating new game...',
        tag: 'WordleGameScreen',
      );
      _gameState = GameState.helperMode();
      DebugLogger.success(
        '✅ WordleGameScreen: New game created successfully',
        tag: 'WordleGameScreen',
      );

      setState(() {
        _isInitialized = true;
      });
      DebugLogger.success(
        '✅ WordleGameScreen: UI state updated, initialization complete!',
        tag: 'WordleGameScreen',
      );

      // Don't auto-suggest on app start - let user request hints manually
      // _getSuggestion();
    } on Exception catch (e, stackTrace) {
      DebugLogger.error(
        '❌ CRITICAL: Service initialization failed: $e',
        tag: 'WordleGameScreen',
      );
      DebugLogger.error('Stack trace: $stackTrace', tag: 'WordleGameScreen');

      // Fallback to mock game state
      _gameState = GameState.newGame(targetWord: Word.fromString('CRATE'));
      DebugLogger.warning(
        '🔄 Using fallback game state with target: CRATE',
        tag: 'WordleGameScreen',
      );
      setState(() {
        _isInitialized = true; // Set to true so UI can render
      });
    } catch (e, stackTrace) {
      // Catch any other errors (including StateError)
      DebugLogger.error(
        '❌ CRITICAL: Service initialization failed: $e',
        tag: 'WordleGameScreen',
      );
      DebugLogger.error('Stack trace: $stackTrace', tag: 'WordleGameScreen');

      // Fallback to mock game state
      _gameState = GameState.newGame(targetWord: Word.fromString('CRATE'));
      DebugLogger.warning(
        '🔄 Using fallback game state with target: CRATE',
        tag: 'WordleGameScreen',
      );
      setState(() {
        _isInitialized = true; // Set to true so UI can render
      });
    }
  }

  void _onLetterPressed(String letter) {
    if (_currentInput.length < 5) {
      setState(() {
        _currentInput += letter;
      });

      // Only auto-submit if this is the initial suggestion (not user typing)
      // We'll handle this differently - auto-submit only on app start
    }
  }

  /// Get known letter states for the current input word
  Map<int, LetterTileState> _getKnownLetterStates(String word) {
    if (_gameState == null || _gameState!.guesses.isEmpty) {
      return {};
    }

    final knownStates = <int, LetterTileState>{};

    // For each position in the current word
    for (var i = 0; i < word.length; i++) {
      final letter = word[i].toUpperCase();

      // Check all previous guesses for this letter
      for (final guess in _gameState!.guesses) {
        for (var j = 0; j < guess.word.value.length; j++) {
          if (guess.word.value[j].toUpperCase() == letter) {
            final state = guess.result.letterStates[j];

            // If this is the same position and it's green, use it
            // (green takes precedence)
            if (j == i && state == LetterState.green) {
              knownStates[i] = LetterTileState.correct;
            }
            // If this is the same position and it's yellow, use it if we
            // don't have green
            else if (j == i &&
                state == LetterState.yellow &&
                knownStates[i] != LetterTileState.correct) {
              knownStates[i] = LetterTileState.present;
            }
            // If this is a different position but the letter was marked as
            // present (yellow) and we haven't found a green state for this
            // position yet
            else if (j != i &&
                state == LetterState.yellow &&
                knownStates[i] != LetterTileState.correct) {
              knownStates[i] = LetterTileState.present;
            }
            // If this is the same position and it's gray, use it if we don't
            // have anything better
            else if (j == i &&
                state == LetterState.gray &&
                !knownStates.containsKey(i)) {
              knownStates[i] = LetterTileState.absent;
            }
          }
        }
      }
    }

    return knownStates;
  }

  // REMOVED: _convertLetterStateToTileState method - no longer used

  /// Build letter state buttons for marking letters
  List<Widget> _buildLetterStateButtons() {
    final buttons = <Widget>[];

    for (var row = 0; row < _gameState!.guesses.length; row++) {
      final guess = _gameState!.guesses[row];
      for (var col = 0; col < guess.word.value.length; col++) {
        final letter = guess.word.value[col];
        final state = guess.result.letterStates[col];

        buttons.add(
          GestureDetector(
            onTap: () => _cycleLetterState(row, col),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getButtonColor(state),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: _getButtonTextColor(state),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return buttons;
  }

  /// Get button color for letter state
  Color _getButtonColor(LetterState state) {
    switch (state) {
      case LetterState.green:
        return const Color(0xFF6AAA64); // Green
      case LetterState.yellow:
        return const Color(0xFFC9B458); // Yellow
      case LetterState.gray:
        return const Color(0xFF787C7E); // Gray
    }
  }

  /// Get button text color for letter state
  Color _getButtonTextColor(LetterState state) {
    switch (state) {
      case LetterState.green:
      case LetterState.yellow:
      case LetterState.gray:
        return Colors.white;
    }
  }

  void _onBackspacePressed() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  void _onTileTap(int row, int col) {
    // Only allow tapping on completed guesses (not current input)
    if (row < _gameState!.guesses.length) {
      _cycleLetterState(row, col);
    }
  }

  /// Cycle through letter states: Gray → Yellow → Green → Gray
  void _cycleLetterState(int row, int col) {
    final guess = _gameState!.guesses[row];
    final currentState = guess.result.letterStates[col];

    // Cycle through states: Gray → Yellow → Green → Gray
    LetterState newState;
    switch (currentState) {
      case LetterState.gray:
        newState = LetterState.yellow;
        break;
      case LetterState.yellow:
        newState = LetterState.green;
        break;
      case LetterState.green:
        newState = LetterState.gray;
        break;
    }

    // Update the letter state
    final newLetterStates = List<LetterState>.from(guess.result.letterStates);
    newLetterStates[col] = newState;

    // Create new GuessResult with updated states
    final newResult = GuessResult.withStates(
      word: guess.word,
      letterStates: newLetterStates,
    );

    // Update the guess in the game state
    _gameState!.guesses[row] = GuessEntry(word: guess.word, result: newResult);

    // Update game state to check for win condition
    _gameState!.updateGameState();

    setState(() {
      // Trigger UI rebuild
    });

    // Check if game is won and show modal
    if (_gameState!.isWon) {
      _showCorrectAnswerDialog();
    }
  }

  void _onEnterPressed() {
    if (_currentInput.length == 5) {
      _submitGuess();
    } else if (_currentInput.isNotEmpty) {
      _showErrorDialog('Word must be 5 letters long');
    }
    // If input is empty, do nothing (user might be changing colors on
    // completed guesses)
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
    );
  }

  void _showNoMoreSuggestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('No More Suggestions'),
          content: const Text(
            'No more suggestions available. You may have already found the '
            'correct word!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
    );
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Correct Answer Found!'),
          content: const Text(
            'Congratulations! You have found the correct word.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
    );
  }

  void _submitGuess() {
    try {
      final guess = Word.fromString(_currentInput);
      final gameService = sl<GameService>();

      // Validate word against the word list
      if (!gameService.isValidGuess(_currentInput)) {
        _showErrorDialog('Word not found in word list');
        return;
      }

      // Check if word has already been guessed
      for (final existingGuess in _gameState!.guesses) {
        if (existingGuess.word.value.toUpperCase() ==
            guess.value.toUpperCase()) {
          _showErrorDialog('Word already guessed');
          return;
        }
      }

      // Don't auto-evaluate the guess - create a result with default states
      // User will need to manually input the letter states (G/G/Y)
      final result = GuessResult.fromWord(
        guess,
      ); // Creates all gray states by default

      _gameState!.addGuess(guess, result);

      setState(() {
        _currentInput = '';
      });
    } on Exception catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _newGame() {
    setState(() {
      final gameService = sl<GameService>();
      _gameState = GameState.helperMode();
      _currentInput = '';
    });
    // Don't auto-suggest on new game - let user request hints manually
    // _getSuggestion();
  }

  void _onUndo() {
    if (_gameState!.guesses.isNotEmpty) {
      setState(() {
        _gameState!.guesses.removeLast();
      });
    }
  }

  Timer? _suggestionTimer;

  /// Capture manual markings from the current row and store them in game state
  /// This ensures the algorithm knows about the constraints
  void _captureManualMarkings() {
    print('🔍 DEBUG: _captureManualMarkings called');
    
    if (_gameState == null) {
      print('❌ GameState is null in _captureManualMarkings');
      return;
    }
    
    print('  • GameState guesses: ${_gameState!.guesses.length}');
    print('  • Current guess: ${_gameState!.currentGuess}');
    
    // Get the current row's word and letter states
    final currentRow = _gameState!.currentGuess - 1;
    if (currentRow < 0 || currentRow >= _gameState!.guesses.length) {
      print('❌ Invalid currentRow: $currentRow, guesses.length: ${_gameState!.guesses.length}');
      print('❌ Cannot capture manual markings - no guess at this row');
      return;
    }
    
    final guessEntry = _gameState!.guesses[currentRow];
    final word = guessEntry.word.value;
    
    print('  • Word: $word');
    print('  • Letter states: ${guessEntry.result.letterStates.map((s) => s.toString()).join("")}');
    
    // Get the manual letter states from the existing guess
    final letterStates = guessEntry.result.letterStates;
    
    // Create a new GuessEntry with the manual markings
    final manualResult = GuessResult(word: Word.fromString(word), letterStates: letterStates);
    final manualGuessEntry = GuessEntry(word: Word.fromString(word), result: manualResult);
    
    // Replace the existing guess entry with the manual one
    _gameState!.guesses[currentRow] = manualGuessEntry;
    
    print('✅ Captured manual markings: $word -> ${letterStates.map((s) => s.toString()).join("")}');
  }

  void _getSuggestion() {
    print('🔍 DEBUG: _getSuggestion called');
    DebugLogger.debug('Get suggestion button pressed', tag: 'UI');

    if (_gameState == null) {
      print('❌ GameState is null in _getSuggestion');
      DebugLogger.error('GameState is null when getting suggestion', tag: 'UI');
      return;
    }

    if (_gameState!.isGameOver) {
      DebugLogger.warning('Game is over, cannot get suggestion', tag: 'UI');
      return;
    }

    DebugLogger.debug(
      'GameState: guesses=${_gameState!.guesses.length}, '
      'isGameOver=${_gameState!.isGameOver}',
      tag: 'UI',
    );

    try {
      // CRITICAL: Capture manual markings before getting suggestion
      // This ensures the algorithm knows about the constraints
      _captureManualMarkings();
      
      DebugLogger.debug('Getting suggestion from GameService', tag: 'UI');

      final gameService = sl<GameService>();
      final suggestion = gameService.suggestNextGuess(_gameState!);

      if (suggestion != null) {
        DebugLogger.success('Got suggestion: ${suggestion.value}', tag: 'UI');

        // Cancel any existing timer
        _suggestionTimer?.cancel();
        // Add satisfying animation delay (card-flip effect)
        _suggestionTimer = Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _currentInput = suggestion.value;
            });
            DebugLogger.debug(
              'Updated currentInput to: $_currentInput',
              tag: 'UI',
            );

            // Don't auto-submit - let user review the suggestion first
            DebugLogger.info('Suggestion populated: $_currentInput', tag: 'UI');
          }
        });
      } else {
        DebugLogger.warning('GameService returned null suggestion', tag: 'UI');

        // Check if we have a correct answer (all green letters in any guess)
        var hasCorrectAnswer = false;
        for (final guess in _gameState!.guesses) {
          if (guess.result.letterStates.every(
            (state) => state == LetterState.green,
          )) {
            hasCorrectAnswer = true;
            break;
          }
        }

        if (hasCorrectAnswer) {
          _showCorrectAnswerDialog();
        } else {
          _showNoMoreSuggestionsDialog();
        }
      }
    } on Exception catch (e, stackTrace) {
      DebugLogger.error(
        'Error getting suggestion: $e',
        tag: 'UI',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Run benchmark test on the phone
  void _runBenchmark() async {
    DebugLogger.info('🎯 Starting Phone Benchmark - 50 games', tag: 'BENCHMARK');
    
    try {
      // Ensure FFI service is initialized (safe to call multiple times)
      await FfiService.initialize();
      
      // Initialize benchmark solver
      FfiService.initializeBenchmarkSolver();
      
      final testWords = [
        'TRAIN', 'CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT', 'LEAST', 'STARE', 'TARES',
        'RAISE', 'ARISE', 'SOARE', 'ROATE', 'ADIEU', 'AUDIO', 'ALIEN', 'STONE', 'STORE',
        'STORM', 'STOMP', 'PLATE', 'GRATE', 'CHASE', 'CLOTH', 'CLOUD', 'BREAD', 'BRAIN',
        'BRAND', 'BRASS', 'BRAVE', 'BREAK', 'BREED', 'BRICK', 'BRIDE', 'BRING', 'BRINK',
        'BRISK', 'BROAD', 'BROKE', 'BROWN', 'BUILD', 'BUILT', 'BURST', 'BUSED', 'BUSES',
        'BUSHY', 'BUTCH', 'BUYER', 'BUZZY', 'CABLE', 'CACHE'
      ];
      
      final results = <Map<String, dynamic>>[];
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < testWords.length; i++) {
        final targetWord = testWords[i];
        final gameResult = _simulateGame(targetWord, 6);
        results.add(gameResult);
        
        DebugLogger.info(
          'Game ${i + 1}/${testWords.length}: ${targetWord} - ${gameResult['solved'] ? "✅ SOLVED" : "❌ FAILED"} in ${gameResult['guessCount']} guesses',
          tag: 'BENCHMARK'
        );
        if (gameResult['guesses'].isNotEmpty) {
          DebugLogger.info('  Guesses: ${gameResult['guesses'].join(" → ")}', tag: 'BENCHMARK');
        }
      }
      
      stopwatch.stop();
      
      // Calculate statistics
      final totalGames = results.length;
      final solvedGames = results.where((r) => r['solved']).length;
      final successRate = solvedGames / totalGames;
      final totalGuesses = results.fold(0, (sum, r) => sum + (r['guessCount'] as int));
      final averageGuesses = totalGuesses / totalGames;
      
      DebugLogger.info('📊 PHONE BENCHMARK RESULTS', tag: 'BENCHMARK');
      DebugLogger.info('==========================', tag: 'BENCHMARK');
      DebugLogger.info('Total games: $totalGames', tag: 'BENCHMARK');
      DebugLogger.info('Solved games: $solvedGames', tag: 'BENCHMARK');
      DebugLogger.info('Success rate: ${(successRate * 100).toStringAsFixed(1)}%', tag: 'BENCHMARK');
      DebugLogger.info('Average guesses: ${averageGuesses.toStringAsFixed(2)}', tag: 'BENCHMARK');
      DebugLogger.info('Total time: ${stopwatch.elapsedMilliseconds}ms', tag: 'BENCHMARK');
      DebugLogger.info('Time per game: ${(stopwatch.elapsedMilliseconds / totalGames).toStringAsFixed(0)}ms', tag: 'BENCHMARK');
      
      // Show results in a dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('📊 Benchmark Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total games: $totalGames'),
                Text('Solved games: $solvedGames'),
                Text('Success rate: ${(successRate * 100).toStringAsFixed(1)}%'),
                Text('Average guesses: ${averageGuesses.toStringAsFixed(2)}'),
                Text('Total time: ${stopwatch.elapsedMilliseconds}ms'),
                Text('Time per game: ${(stopwatch.elapsedMilliseconds / totalGames).toStringAsFixed(0)}ms'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      DebugLogger.info('🎉 Phone benchmark completed successfully!', tag: 'BENCHMARK');
      DebugLogger.info('✅ Success rate: ${(successRate * 100).toStringAsFixed(1)}% (target: ≥95%)', tag: 'BENCHMARK');
      DebugLogger.info('✅ Average guesses: ${averageGuesses.toStringAsFixed(2)} (target: ≤4.0)', tag: 'BENCHMARK');
      
    } catch (e, stackTrace) {
      DebugLogger.error('Benchmark failed: $e', tag: 'BENCHMARK', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Benchmark Failed'),
            content: Text('Error: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Simulate a single game exactly like Cargo benchmark
  Map<String, dynamic> _simulateGame(String targetWord, int maxGuesses) {
    final guesses = <String>[];
    final guessResults = <(String, List<String>)>[];
    
    // Get answer words (like Cargo benchmark)
    final answerWords = FfiService.getAnswerWords();
    var remainingWords = List<String>.from(answerWords);
    
    for (int attempt = 1; attempt <= maxGuesses; attempt++) {
      // Get the best guess from our intelligent solver (exactly like Cargo benchmark)
      final candidateWords = remainingWords.isEmpty ? answerWords : remainingWords;
      final bestGuess = FfiService.getBestGuessReference(candidateWords, guessResults);
      
      if (bestGuess == null) {
        break; // No valid guess available
      }
      
      guesses.add(bestGuess);
      
      // Check if we solved it (like Cargo benchmark)
      if (bestGuess == targetWord) {
        return {
          'targetWord': targetWord,
          'guesses': guesses,
          'guessCount': attempt,
          'solved': true,
          'maxGuesses': maxGuesses,
        };
      }
      
      // Generate feedback for this guess (like Cargo benchmark)
      final feedback = _generateFeedback(bestGuess, targetWord);
      guessResults.add((bestGuess, feedback));
      
      // Filter remaining words based on feedback (exactly like Cargo benchmark)
      remainingWords = FfiService.filterWords(remainingWords, guessResults);
    }
    
    return {
      'targetWord': targetWord,
      'guesses': guesses,
      'guessCount': guesses.length,
      'solved': false,
      'maxGuesses': maxGuesses,
    };
  }

  /// Generate feedback for a guess against a target word (like Cargo benchmark)
  List<String> _generateFeedback(String guess, String target) {
    final guessChars = guess.split('');
    final targetChars = target.split('');
    final results = List<String>.filled(5, 'X'); // Start with all gray
    
    // First pass: mark exact matches (green) - like Cargo benchmark
    for (int i = 0; i < 5; i++) {
      if (guessChars[i] == targetChars[i]) {
        results[i] = 'G';
        targetChars[i] = ' '; // Mark as used
      }
    }
    
    // Second pass: mark partial matches (yellow) - like Cargo benchmark
    for (int i = 0; i < 5; i++) {
      if (results[i] == 'X') {
        final letter = guessChars[i];
        final pos = targetChars.indexOf(letter);
        if (pos != -1) {
          results[i] = 'Y';
          targetChars[pos] = ' '; // Mark as used
        }
      }
    }
    
    return results;
  }

  /// A new method to test the FFI connection
  void _testFfiConnection() async {
    DebugLogger.info(
      '🔍 FLUTTER DEBUG: Testing FFI connection...',
      tag: 'FFI_TEST',
    );
    try {
      print('🔍 DEBUG: Starting FFI test...');
      
      // Ensure FFI service is initialized first
      print('🔍 DEBUG: Initializing FFI service...');
      await FfiService.initialize();
      print('🔍 DEBUG: FFI service initialized successfully');
      
      // Test FFI connection with a simple function call
      print('🔍 DEBUG: Calling ffi.getAnswerWords()...');
      final answerWords = ffi.getAnswerWords();
      print('🔍 DEBUG: getAnswerWords() returned ${answerWords.length} words');
      DebugLogger.success(
        '✅ FFI SUCCESS: Rust loaded ${answerWords.length} answer words',
        tag: 'FFI_TEST',
      );

      // Show a success dialog
      _showErrorDialog(
        'FFI Connection Successful!\n\nRust loaded '
        '${answerWords.length} answer words',
      );
    } on Exception catch (e, stackTrace) {
      DebugLogger.error(
        '❌ FFI FAILED: Could not call getAnswerWords.',
        tag: 'FFI_TEST',
        error: e,
        stackTrace: stackTrace,
      );

      // Show detailed error dialog
      _showErrorDialog(
        'FFI Connection FAILED!\n\nError: ${e.toString()}\n\nStack: ${stackTrace.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _suggestionTimer?.cancel();
    super.dispose();
  }

  Map<String, Color> _getKeyColors() {
    if (_gameState == null) return {};

    final keyColors = <String, Color>{};

    // Track the best state for each letter across all guesses
    final letterStates = <String, LetterState>{};

    for (final guess in _gameState!.guesses) {
      for (var i = 0; i < guess.word.value.length; i++) {
        final letter = guess.word.value[i].toUpperCase();
        final state = guess.result.letterStates[i];

        // Keep the best state for each letter (green > yellow > gray)
        if (!letterStates.containsKey(letter) ||
            _isBetterState(state, letterStates[letter]!)) {
          letterStates[letter] = state;
        }
      }
    }

    // Convert letter states to colors
    for (final entry in letterStates.entries) {
      keyColors[entry.key] = _getColorForLetterState(entry.value);
    }

    return keyColors;
  }

  /// Check if newState is better than currentState
  bool _isBetterState(LetterState newState, LetterState currentState) {
    // Green is best, then yellow, then gray
    if (newState == LetterState.green) return true;
    if (newState == LetterState.yellow && currentState == LetterState.gray)
      return true;
    return false;
  }

  /// Get color for letter state
  Color _getColorForLetterState(LetterState state) {
    switch (state) {
      case LetterState.green:
        return const Color(0xFF6AAA64); // Green
      case LetterState.yellow:
        return const Color(0xFFC9B458); // Yellow
      case LetterState.gray:
        return const Color(0xFF787C7E); // Gray
    }
  }

  Set<String> _getDisabledKeys() {
    // TODO: Implement disabled keys logic
    return {};
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle Helper'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
              Color(0xFFDEE2E6),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available height for content
              final availableHeight = constraints.maxHeight;
              final screenHeight = MediaQuery.of(context).size.height;

              // Determine if we're on a small screen (iPhone SE size)
              final isSmallScreen = screenHeight < 700;

              // Calculate responsive spacing based on available space
              final topSpacing = isSmallScreen ? 8.0 : 20.0;
              final middleSpacing = isSmallScreen ? 8.0 : 16.0;
              final bottomSpacing = isSmallScreen ? 8.0 : 20.0;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    SizedBox(height: topSpacing),

                    // Game Grid - Responsive size
                    Center(
                      child: GameGrid(
                        key: const Key('game_grid'),
                        gameState: _gameState!,
                        currentInput: _currentInput,
                        availableHeight:
                            availableHeight *
                            0.35, // Use 35% of available height
                            // (reduced from 40%)
                        onTileTap: _onTileTap,
                        knownLetterStates: _getKnownLetterStates(_currentInput),
                      ),
                    ),
                    SizedBox(height: middleSpacing),

                    // Virtual Keyboard - Responsive size
                    VirtualKeyboard(
                      key: const Key('virtual_keyboard'),
                      onKeyPress: (key) {
                        if (key == 'ENTER') {
                          _onEnterPressed();
                        } else if (key == 'DELETE') {
                          _onBackspacePressed();
                        } else {
                          _onLetterPressed(key);
                        }
                      },
                      keyColors: _getKeyColors(),
                      disabledKeys: _getDisabledKeys(),
                      availableWidth: constraints.maxWidth,
                      isSmallScreen: isSmallScreen,
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons Row
                    Row(
                      children: [
                        // New Game Button (compact)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            child: TextButton(
                              key: const Key('new_game_button'),
                              onPressed: _newGame,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: isSmallScreen ? 6 : 8,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                foregroundColor: const Color(0xFF787C7E),
                              ),
                              child: const Text('New Game'),
                            ),
                          ),
                        ),

                        // Undo Button (if there are guesses)
                        if (_gameState!.guesses.isNotEmpty)
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: TextButton(
                                key: const Key('undo_button'),
                                onPressed: _onUndo,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: isSmallScreen ? 6 : 8,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  foregroundColor: const Color(0xFF787C7E),
                                ),
                                child: const Text('↶ Undo'),
                              ),
                            ),
                          ),

                        // Test FFI Button
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextButton(
                              key: const Key('test_ffi_button'),
                              onPressed: _testFfiConnection,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: isSmallScreen ? 6 : 8,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                foregroundColor: const Color(0xFF6AAA64),
                              ),
                              child: const Text('🔧 Test FFI'),
                            ),
                          ),
                        ),

                        // Get Suggestion Button (primary) - smaller
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.only(left: 4),
                            child: ElevatedButton(
                              key: const Key('get_suggestion_button'),
                              onPressed: _getSuggestion,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isSmallScreen ? 8 : 10,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 6,
                                shadowColor: Colors.black.withValues(
                                  alpha: 0.2,
                                ),
                                backgroundColor: const Color(0xFF6AAA64),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('🎯 Get Next Hint'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Benchmark Button
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        onPressed: _runBenchmark,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: Colors.purple[100],
                          foregroundColor: Colors.purple[800],
                        ),
                        child: const Text('📊 Run Benchmark (50 games)'),
                      ),
                    ),
                    
                    SizedBox(height: middleSpacing),

                    // Letter State Buttons (for marking letters)
                    if (_gameState!.guesses.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mark Letters (tap to cycle: '
                              'Gray → Yellow → Green):',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: _buildLetterStateButtons(),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: bottomSpacing),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
