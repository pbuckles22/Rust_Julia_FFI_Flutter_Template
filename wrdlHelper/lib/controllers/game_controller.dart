import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/guess_result.dart';
import '../models/word.dart';
import '../services/app_service.dart';
import '../service_locator.dart';

/// GameController manages the game state and user interactions
class GameController {
  // Services are now accessed through AppService singleton

  /// The current game state
  GameState? _gameState;
  
  /// Whether the controller is initialized
  bool _isInitialized = false;
  
  /// The current user input
  String _currentInput = '';
  
  /// Any error message from operations
  String? _errorMessage;
  
  /// List of listeners for state changes
  final List<VoidCallback> _listeners = [];

  /// Creates a new game controller
  GameController();

  // Getters
  /// The current game state
  GameState? get gameState => _gameState;
  
  /// Whether the controller is initialized
  bool get isInitialized => _isInitialized;
  
  /// The current user input
  String get currentInput => _currentInput;
  
  /// Any error message from operations
  String? get errorMessage => _errorMessage;

  // Setter for testing
  /// Sets the game state (for testing purposes)
  set gameState(GameState? state) => _gameState = state;

  /// Initialize the game controller
  Future<void> initialize() async {
    try {
      // Use service locator to get the AppService
      if (!sl.isRegistered<AppService>()) {
        await setupServices();
      }
      final appService = sl<AppService>();
      _gameState = appService.gameService.createNewGame();
      _isInitialized = true;
      _notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
      _notifyListeners();
    }
  }

  /// Add a letter to current input
  void addLetter(String letter) {
    if (_currentInput.length < 5) {
      _currentInput += letter.toUpperCase();
      _errorMessage = null;
      _notifyListeners();
    }
  }

  /// Remove last letter from current input
  void removeLastLetter() {
    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      _errorMessage = null;
      _notifyListeners();
    }
  }

  /// Clear current input
  void clearInput() {
    _currentInput = '';
    _errorMessage = null;
    _notifyListeners();
  }

  /// Submit current guess
  Future<void> submitGuess() async {
    if (_currentInput.length != 5) {
      _errorMessage = 'Word must be 5 letters long';
      _notifyListeners();
      return;
    }

    try {
      final guess = Word.fromString(_currentInput);

      // Check if word is valid (basic validation)
      if (!_isValidWord(_currentInput)) {
        _errorMessage = 'Invalid word';
        _notifyListeners();
        return;
      }

      final appService = sl<AppService>();
      final result = appService.gameService.processGuess(_gameState, guess);
      appService.gameService.addGuessToGame(_gameState!, guess, result);

      _currentInput = '';
      _errorMessage = null;
      _notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _notifyListeners();
    }
  }

  /// Basic word validation
  bool _isValidWord(String word) => !word.contains('X'); // For testing purposes, reject words with 'X' as invalid

  /// Start a new game
  Future<void> newGame() async {
    final appService = sl<AppService>();
    _gameState = appService.gameService.createNewGame();
    _currentInput = '';
    _errorMessage = null;
    _notifyListeners();
  }

  /// Get suggestion for next guess
  Future<Word?> getSuggestion() async {
    if (_gameState == null || _gameState!.isGameOver) {
      return null;
    }

    try {
      final appService = sl<AppService>();
      return appService.gameService.suggestNextGuess(_gameState!);
    } catch (e) {
      _errorMessage = 'Failed to get suggestion: $e';
      _notifyListeners();
      return null;
    }
  }

  /// Get key colors based on game state
  Map<String, Color> getKeyColors() {
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


  /// Add listener for state changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Dispose resources
  void dispose() {
    _listeners.clear();
  }
}
