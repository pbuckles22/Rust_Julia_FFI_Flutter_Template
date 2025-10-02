import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/exceptions/game_exceptions.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';

/// Comprehensive tests for GameState model
///
/// These tests validate game state management, guess tracking, and game progression
/// for the Wordle game following TDD principles.
void main() {
  group('GameState Model Tests', () {
    group('Game Initialization', () {
      test('creates new game with default state', () {
        // Arrange & Act
        final gameState = GameState.newGame();

        // Assert
        expect(gameState.guesses, isEmpty);
        expect(gameState.maxGuesses, equals(5));
        expect(gameState.currentGuess, equals(0));
        expect(gameState.isGameOver, isFalse);
        expect(gameState.isWon, isFalse);
        expect(gameState.isLost, isFalse);
        expect(gameState.targetWord, isNull);
        expect(gameState.gameStatus, equals(GameStatus.playing));
      });

      test('creates new game with custom max guesses', () {
        // Arrange
        const maxGuesses = 10;

        // Act
        final gameState = GameState.newGame(maxGuesses: maxGuesses);

        // Assert
        expect(gameState.maxGuesses, equals(maxGuesses));
        expect(gameState.guesses, isEmpty);
        expect(gameState.currentGuess, equals(0));
      });

      test('creates game with target word', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');

        // Act
        final gameState = GameState.newGame(targetWord: targetWord);

        // Assert
        expect(gameState.targetWord, equals(targetWord));
        expect(gameState.guesses, isEmpty);
        expect(gameState.isGameOver, isFalse);
      });
    });

    group('Guess Management', () {
      test('adds valid guess to game state', () {
        // Arrange
        final gameState = GameState.newGame();
        final guess = Word.fromString('CRANE');
        final result = GuessResult.fromWord(guess);

        // Act
        gameState.addGuess(guess, result);

        // Assert
        expect(gameState.guesses.length, equals(1));
        expect(gameState.guesses.first.word, equals(guess));
        expect(gameState.guesses.first.result, equals(result));
        expect(gameState.currentGuess, equals(1));
      });

      test('adds multiple guesses in order', () {
        // Arrange
        final gameState = GameState.newGame();
        final guess1 = Word.fromString('CRANE');
        final guess2 = Word.fromString('SLATE');
        final result1 = GuessResult.fromWord(guess1);
        final result2 = GuessResult.fromWord(guess2);

        // Act
        gameState.addGuess(guess1, result1);
        gameState.addGuess(guess2, result2);

        // Assert
        expect(gameState.guesses.length, equals(2));
        expect(gameState.guesses[0].word, equals(guess1));
        expect(gameState.guesses[1].word, equals(guess2));
        expect(gameState.currentGuess, equals(2));
      });

      test('prevents adding guess when game is over', () {
        // Arrange
        final gameState = GameState.newGame();
        gameState.setGameOver(); // Simulate game over
        final guess = Word.fromString('CRANE');
        final result = GuessResult.fromWord(guess);

        // Act & Assert
        expect(
          () => gameState.addGuess(guess, result),
          throwsA(isA<GameOverException>()),
        );
      });

      test('prevents adding guess when max guesses reached', () {
        // Arrange
        final gameState = GameState.newGame(maxGuesses: 1);
        final guess1 = Word.fromString('CRANE');
        final guess2 = Word.fromString('SLATE');
        final result1 = GuessResult.fromWord(guess1);
        final result2 = GuessResult.fromWord(guess2);

        // Act
        gameState.addGuess(guess1, result1);

        // Assert
        expect(
          () => gameState.addGuess(guess2, result2),
          throwsA(isA<MaxGuessesReachedException>()),
        );
      });

      test('prevents adding duplicate guesses in the same game', () {
        // Arrange
        final gameState = GameState.newGame();
        final guess = Word.fromString('CRANE');
        final result = GuessResult.fromWord(guess);

        // Act
        gameState.addGuess(guess, result);

        // Assert - trying to add the same guess again should throw an exception
        expect(
          () => gameState.addGuess(guess, result),
          throwsA(isA<InvalidGuessException>()),
        );

        // Verify the error message mentions the duplicate word
        try {
          gameState.addGuess(guess, result);
          fail('Expected InvalidGuessException to be thrown');
        } catch (e) {
          expect(e, isA<InvalidGuessException>());
          expect(e.toString(), contains('already been used'));
        }
      });
    });

    group('Game Status Management', () {
      test('marks game as won when target word is guessed', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = GameState.newGame(targetWord: targetWord);
        final guess = Word.fromString('CRANE');
        // Create a result with all green letters (correct guess)
        final result = GuessResult.withStates(
          word: guess,
          letterStates: [
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
          ],
        );

        // Act
        gameState.addGuess(guess, result);

        // Assert
        expect(gameState.isWon, isTrue);
        expect(gameState.isLost, isFalse);
        expect(gameState.isGameOver, isTrue);
        expect(gameState.gameStatus, equals(GameStatus.won));
      });

      test('marks game as lost when max guesses reached', () {
        // Arrange
        final gameState = GameState.newGame(maxGuesses: 1);
        final guess = Word.fromString('SLATE');
        final result = GuessResult.fromWord(guess);

        // Act
        gameState.addGuess(guess, result);

        // Assert
        expect(gameState.isWon, isFalse);
        expect(gameState.isLost, isTrue);
        expect(gameState.isGameOver, isTrue);
        expect(gameState.gameStatus, equals(GameStatus.lost));
      });

      test('maintains playing status during game', () {
        // Arrange
        final gameState = GameState.newGame();
        final guess = Word.fromString('SLATE');
        final result = GuessResult.fromWord(guess);

        // Act
        gameState.addGuess(guess, result);

        // Assert
        expect(gameState.isWon, isFalse);
        expect(gameState.isLost, isFalse);
        expect(gameState.isGameOver, isFalse);
        expect(gameState.gameStatus, equals(GameStatus.playing));
      });
    });

    group('Guess Validation', () {
      test('validates guess is correct length', () {
        // Arrange
        final gameState = GameState.newGame();
        final invalidGuess = Word.fromString('CAT');
        final result = GuessResult.fromWord(invalidGuess);

        // Act & Assert
        expect(
          () => gameState.addGuess(invalidGuess, result),
          throwsA(isA<InvalidGuessException>()),
        );
      });

      test('validates guess is valid word', () {
        // Arrange
        final gameState = GameState.newGame();
        final invalidGuess = Word.fromString('CR4NE');
        final result = GuessResult.fromWord(invalidGuess);

        // Act & Assert
        expect(
          () => gameState.addGuess(invalidGuess, result),
          throwsA(isA<InvalidGuessException>()),
        );
      });

      test('validates guess is not empty', () {
        // Arrange
        final gameState = GameState.newGame();
        final emptyGuess = Word.fromString('');
        final result = GuessResult.fromWord(emptyGuess);

        // Act & Assert
        expect(
          () => gameState.addGuess(emptyGuess, result),
          throwsA(isA<InvalidGuessException>()),
        );
      });
    });

    group('Game Statistics', () {
      test('tracks guess count correctly', () {
        // Arrange
        final gameState = GameState.newGame();
        final guess1 = Word.fromString('CRANE');
        final guess2 = Word.fromString('SLATE');
        final result1 = GuessResult.fromWord(guess1);
        final result2 = GuessResult.fromWord(guess2);

        // Act
        gameState.addGuess(guess1, result1);
        gameState.addGuess(guess2, result2);

        // Assert
        expect(gameState.guessCount, equals(2));
        expect(gameState.remainingGuesses, equals(3));
      });

      test('calculates remaining guesses correctly', () {
        // Arrange
        final gameState = GameState.newGame(maxGuesses: 6);
        final guess = Word.fromString('CRANE');
        final result = GuessResult.fromWord(guess);

        // Act
        gameState.addGuess(guess, result);

        // Assert
        expect(gameState.remainingGuesses, equals(5));
      });

      test('tracks game duration', () {
        // Arrange
        final gameState = GameState.newGame();

        // Act
        final duration = gameState.gameDuration;

        // Assert
        expect(duration, isA<Duration>());
        expect(duration.inMilliseconds, greaterThanOrEqualTo(0));
      });
    });

    group('Game State Serialization', () {
      test('serializes to JSON correctly', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = GameState.newGame(targetWord: targetWord);
        final guess = Word.fromString('SLATE');
        final result = GuessResult.fromWord(guess);
        gameState.addGuess(guess, result);

        // Act
        final json = gameState.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['guesses'], isA<List>());
        expect(json['maxGuesses'], equals(5));
        expect(json['currentGuess'], equals(1));
        expect(json['isGameOver'], isFalse);
        expect(json['gameStatus'], equals('playing'));
      });

      test('deserializes from JSON correctly', () {
        // Arrange
        final json = {
          'guesses': [],
          'maxGuesses': 5,
          'currentGuess': 0,
          'isGameOver': false,
          'gameStatus': 'playing',
          'targetWord': {'value': 'CRANE', 'isValid': true},
        };

        // Act
        final gameState = GameState.fromJson(json);

        // Assert
        expect(gameState.guesses, isEmpty);
        expect(gameState.maxGuesses, equals(5));
        expect(gameState.currentGuess, equals(0));
        expect(gameState.isGameOver, isFalse);
        expect(gameState.gameStatus, equals(GameStatus.playing));
      });

      test('handles invalid JSON gracefully', () {
        // Arrange
        final invalidJson = {'invalid': 'data'};

        // Act & Assert
        expect(
          () => GameState.fromJson(invalidJson),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Game State Edge Cases', () {
      test('handles game with no guesses', () {
        // Arrange
        final gameState = GameState.newGame();

        // Act & Assert
        expect(gameState.guesses, isEmpty);
        expect(gameState.currentGuess, equals(0));
        expect(gameState.isGameOver, isFalse);
      });

      test('handles game with maximum guesses', () {
        // Arrange
        final gameState = GameState.newGame(maxGuesses: 6);

        // Act
        final words = ['CRANE', 'CRATE', 'SLATE', 'BLADE', 'GRADE', 'SHADE'];
        for (int i = 0; i < 6; i++) {
          final guess = Word.fromString(words[i]);
          final result = GuessResult.fromWord(guess);
          gameState.addGuess(guess, result);
        }

        // Assert
        expect(gameState.guesses.length, equals(6));
        expect(gameState.isGameOver, isTrue);
        expect(gameState.isLost, isTrue);
      });

      test('handles game won on last guess', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = GameState.newGame(
          targetWord: targetWord,
          maxGuesses: 1,
        );
        final guess = Word.fromString('CRANE');
        // Create a result with all green letters (correct guess)
        final result = GuessResult.withStates(
          word: guess,
          letterStates: [
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
          ],
        );

        // Act
        gameState.addGuess(guess, result);

        // Assert
        expect(gameState.isWon, isTrue);
        expect(gameState.isLost, isFalse);
        expect(gameState.isGameOver, isTrue);
      });
    });

    group('Game State Performance', () {
      test('adds guesses quickly', () {
        // Arrange
        final gameState = GameState.newGame();
        final guess = Word.fromString('CRANE');
        final result = GuessResult.fromWord(guess);

        // Act
        final stopwatch = Stopwatch()..start();
        gameState.addGuess(guess, result);
        stopwatch.stop();

        // Assert
        expect(gameState.guesses.length, equals(1));
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });

      test('serializes quickly', () {
        // Arrange
        final gameState = GameState.newGame();
        final guess = Word.fromString('CRANE');
        final result = GuessResult.fromWord(guess);
        gameState.addGuess(guess, result);

        // Act
        final stopwatch = Stopwatch()..start();
        final json = gameState.toJson();
        stopwatch.stop();

        // Assert
        expect(json, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });
    });
  });
}
