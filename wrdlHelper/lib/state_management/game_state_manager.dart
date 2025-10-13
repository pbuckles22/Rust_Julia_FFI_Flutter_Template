import 'package:flutter/material.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';

/// GameStateManager handles game state management and notifications
class GameStateManager {
  /// The current game state
  GameState? _gameState;
  
  /// Whether the manager is initialized
  final bool _isInitialized = false;
  
  /// The current user input
  String _currentInput = '';
  
  /// Any error message from operations
  String? _errorMessage;
  
  /// Whether the manager is in loading state
  bool _isLoading = false;
  
  /// List of listeners for state changes
  final List<VoidCallback> _listeners = [];

  // Getters
  /// The current game state
  GameState? get gameState => _gameState;
  
  /// Whether the manager is initialized
  bool get isInitialized => _isInitialized;
  
  /// The current user input
  String get currentInput => _currentInput;
  
  /// Any error message from operations
  String? get errorMessage => _errorMessage;
  
  /// Whether the manager is in loading state
  bool get isLoading => _isLoading;

  /// Create a new game with target word
  GameState createNewGame(Word targetWord) {
    _gameState = GameState.newGame(targetWord: targetWord);
    _notifyListeners();
    return _gameState!;
  }

  /// Update current input
  void updateCurrentInput(String input) {
    _currentInput = input;
    _notifyListeners();
  }

  /// Append letter to current input
  void appendLetter(String letter) {
    if (_currentInput.length < 5) {
      _currentInput += letter.toUpperCase();
      _notifyListeners();
    }
  }

  /// Remove last letter from input
  void removeLastLetter() {
    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      _notifyListeners();
    }
  }

  /// Clear current input
  void clearInput() {
    _currentInput = '';
    _notifyListeners();
  }

  /// Add guess to game state
  void addGuess(GameState gameState, Word guess, GuessResult result) {
    // Use the GameState's addGuess method which handles all the logic
    gameState.addGuess(guess, result);

    _notifyListeners();
  }

  /// Set error message
  void setError(String error) {
    _errorMessage = error;
    _notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    _notifyListeners();
  }

  /// Reset all state
  void reset() {
    _gameState = null;
    _currentInput = '';
    _errorMessage = null;
    _isLoading = false;
    _notifyListeners();
  }

  /// Check if word length is valid
  bool isValidWordLength(String word) {
    return word.length == 5;
  }

  /// Get remaining guesses count
  int getRemainingGuesses(GameState gameState) {
    return 6 - gameState.guesses.length;
  }

  /// Check if game is in progress
  bool isGameInProgress(GameState gameState) {
    return !gameState.isGameOver;
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
