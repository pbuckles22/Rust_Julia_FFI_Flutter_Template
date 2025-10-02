/// Game-related exceptions for Wordle game
///
/// These exceptions handle game state errors, invalid moves,
/// and game progression issues following TDD principles.
library;

/// Base class for all game exceptions
abstract class GameException implements Exception {
  final String message;
  final String? details;

  const GameException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception thrown when the game is over and no more moves are allowed
class GameOverException extends GameException {
  const GameOverException([String? details])
    : super('Game is over, no more moves allowed', details);
}

/// Exception thrown when maximum number of guesses is reached
class MaxGuessesReachedException extends GameException {
  const MaxGuessesReachedException([String? details])
    : super('Maximum number of guesses reached', details);
}

/// Exception thrown when an invalid guess is made
class InvalidGuessException extends GameException {
  const InvalidGuessException([String? details])
    : super('Invalid guess provided', details);
}

/// Exception thrown when an invalid guess result is provided
class InvalidGuessResultException extends GameException {
  const InvalidGuessResultException([String? details])
    : super('Invalid guess result provided', details);
}

/// Exception thrown when the game state is invalid
class InvalidGameStateException extends GameException {
  const InvalidGameStateException([String? details])
    : super('Invalid game state', details);
}
