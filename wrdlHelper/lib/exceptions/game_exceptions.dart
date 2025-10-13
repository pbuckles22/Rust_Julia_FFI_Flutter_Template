/// Game-related exceptions for Wordle game
///
/// These exceptions handle game state errors, invalid moves,
/// and game progression issues following TDD principles.
library;

/// Base class for all game exceptions
abstract class GameException implements Exception {
  /// The main error message
  final String message;
  
  /// Optional additional details about the error
  final String? details;

  /// Creates a new game exception
  const GameException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception thrown when the game is over and no more moves are allowed
class GameOverException extends GameException {
  /// Creates a new game over exception
  const GameOverException([String? details])
    : super('Game is over, no more moves allowed', details);
}

/// Exception thrown when maximum number of guesses is reached
class MaxGuessesReachedException extends GameException {
  /// Creates a new max guesses reached exception
  const MaxGuessesReachedException([String? details])
    : super('Maximum number of guesses reached', details);
}

/// Exception thrown when an invalid guess is made
class InvalidGuessException extends GameException {
  /// Creates a new invalid guess exception
  const InvalidGuessException([String? details])
    : super('Invalid guess provided', details);
}

/// Exception thrown when an invalid guess result is provided
class InvalidGuessResultException extends GameException {
  /// Creates a new invalid guess result exception
  const InvalidGuessResultException([String? details])
    : super('Invalid guess result provided', details);
}

/// Exception thrown when the game state is invalid
class InvalidGameStateException extends GameException {
  /// Creates a new invalid game state exception
  const InvalidGameStateException([String? details])
    : super('Invalid game state', details);
}
