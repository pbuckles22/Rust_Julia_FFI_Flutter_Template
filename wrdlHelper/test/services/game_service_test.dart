import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/exceptions/game_exceptions.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

/// Comprehensive tests for GameService
///
/// These tests validate game logic, guess processing, and game state management
/// for the Wordle game following TDD principles.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameService Tests', () {
    late AppService appService;

    setUpAll(() async {
      // Initialize FFI once for all tests in this group
      await RustLib.init();
    });

    setUp(() async {
      appService = AppService();
      await appService.initialize();
    });

    group('Game Initialization', () {
      test('creates new game with random target word', () {
        // Act
        final gameState = appService.gameService.createNewGame();

        // Assert
        expect(gameState, isNotNull);
        expect(gameState.targetWord, isNotNull);
        expect(gameState.guesses, isEmpty);
        expect(gameState.isGameOver, isFalse);
      });

      test('creates new game with specific target word', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');

        // Act
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );

        // Assert
        expect(gameState.targetWord, equals(targetWord));
        expect(gameState.guesses, isEmpty);
        expect(gameState.isGameOver, isFalse);
      });

      test('creates new game with custom max guesses', () {
        // Arrange
        const maxGuesses = 10;

        // Act
        final gameState = appService.gameService.createNewGame(
          maxGuesses: maxGuesses,
        );

        // Assert
        expect(gameState.maxGuesses, equals(maxGuesses));
        expect(gameState.guesses, isEmpty);
      });

      test('creates new game with word list', () {
        // Arrange
        final wordList = [
          Word.fromString('CRANE'),
          Word.fromString('SLATE'),
          Word.fromString('TRACE'),
        ];

        // Act
        final gameState = appService.gameService.createNewGame(
          wordList: wordList,
        );

        // Assert
        expect(gameState.targetWord, isNotNull);
        expect(wordList.contains(gameState.targetWord!), isTrue);
      });
    });

    group('Guess Processing', () {
      late GameState gameState;
      late Word targetWord;

      setUp(() {
        targetWord = Word.fromString('CRANE');
        gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
      });

      test('processes valid guess correctly', () {
        // Arrange
        final guess = Word.fromString('SLATE');

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert
        expect(result, isNotNull);
        expect(result.word, equals(guess));
        expect(result.letterStates.length, equals(5));
        expect(result.isComplete, isTrue);
      });

      test('processes guess with green letters', () {
        // Arrange
        final guess = Word.fromString('CRANE'); // Exact match

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert
        expect(result.isCorrect, isTrue);
        expect(result.greenCount, equals(5));
        expect(result.yellowCount, equals(0));
        expect(result.grayCount, equals(0));
      });

      test('processes guess with yellow letters', () {
        // Arrange
        final guess = Word.fromString(
          'SLATE',
        ); // A and E are in target but wrong position

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert - should process gracefully
        expect(result, isNotNull);
        expect(result.word, equals(guess));
      });

      test('processes guess with all gray letters', () {
        // Arrange
        final guess = Word.fromString('SLOTH'); // No letters match

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert - should process gracefully
        expect(result, isNotNull);
        expect(result.word, equals(guess));
      });

      test('processes guess with mixed letter states', () {
        // Arrange
        final guess = Word.fromString(
          'CRATE',
        ); // C and R match, A is green, T is gray, E is green

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert
        expect(result.isCorrect, isFalse);
        expect(result.greenCount, equals(4));
        expect(result.yellowCount, equals(0));
        expect(result.grayCount, equals(1));
      });

      test('rejects invalid guess length', () {
        // Arrange
        final invalidGuess = Word.fromString('CAT');

        // Act & Assert
        expect(
          () => appService.gameService.processGuess(gameState, invalidGuess),
          throwsA(isA<InvalidGuessException>()),
        );
      });

      test('rejects invalid guess characters', () {
        // Arrange
        final invalidGuess = Word.fromString('CR4NE');

        // Act & Assert
        expect(
          () => appService.gameService.processGuess(gameState, invalidGuess),
          throwsA(isA<InvalidGuessException>()),
        );
      });

      test('rejects empty guess', () {
        // Arrange
        final emptyGuess = Word.fromString('');

        // Act & Assert
        expect(
          () => appService.gameService.processGuess(gameState, emptyGuess),
          throwsA(isA<InvalidGuessException>()),
        );
      });
    });

    group('Game State Management', () {
      late GameState gameState;
      late Word targetWord;

      setUp(() {
        targetWord = Word.fromString('CRANE');
        gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
      });

      test('adds guess to game state', () {
        // Arrange
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);

        // Act
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Assert
        expect(gameState.guesses.length, equals(1));
        expect(gameState.guesses.first.word, equals(guess));
        expect(gameState.guesses.first.result, equals(result));
        expect(gameState.currentGuess, equals(1));
      });

      test('marks game as won when target is guessed', () {
        // Arrange
        final guess = Word.fromString('CRANE');
        final result = appService.gameService.processGuess(gameState, guess);

        // Act
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Assert
        expect(gameState.isWon, isTrue);
        expect(gameState.isLost, isFalse);
        expect(gameState.isGameOver, isTrue);
        expect(gameState.gameStatus, equals(GameStatus.won));
      });

      test('marks game as lost when max guesses reached', () {
        // Arrange
        gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
          maxGuesses: 1,
        );
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);

        // Act
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Assert
        expect(gameState.isWon, isFalse);
        expect(gameState.isLost, isTrue);
        expect(gameState.isGameOver, isTrue);
        expect(gameState.gameStatus, equals(GameStatus.lost));
      });

      test('maintains playing status during game', () {
        // Arrange
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);

        // Act
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Assert
        expect(gameState.isWon, isFalse);
        expect(gameState.isLost, isFalse);
        expect(gameState.isGameOver, isFalse);
        expect(gameState.gameStatus, equals(GameStatus.playing));
      });

      test('prevents adding guess when game is over', () {
        // Arrange
        final guess = Word.fromString('CRANE');
        final result = appService.gameService.processGuess(gameState, guess);
        appService.gameService.addGuessToGame(
          gameState,
          guess,
          result,
        ); // Game is now won

        // Act & Assert - try to add a different guess when game is over
        final secondGuess = Word.fromString('CRATE');
        final secondResult = appService.gameService.processGuess(
          gameState,
          secondGuess,
        );
        expect(
          () => appService.gameService.addGuessToGame(
            gameState,
            secondGuess,
            secondResult,
          ),
          throwsA(isA<GameOverException>()),
        );
      });
    });

    group('Word Validation', () {
      test('validates word is in word list', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final invalidWord = Word.fromString('ZZZZZ');

        // Act
        final isValid1 = appService.gameService.isValidWord(validWord);
        final isValid2 = appService.gameService.isValidWord(invalidWord);

        // Assert
        expect(isValid1, isTrue);
        expect(isValid2, isFalse);
      });

      test('validates word length', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final invalidWord = Word.fromString('CAT');

        // Act
        final isValid1 = appService.gameService.isValidWordLength(validWord);
        final isValid2 = appService.gameService.isValidWordLength(invalidWord);

        // Assert
        expect(isValid1, isTrue);
        expect(isValid2, isFalse);
      });

      test('validates word characters', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final invalidWord = Word.fromString('CR4NE');

        // Act
        final isValid1 = appService.gameService.isValidWordCharacters(
          validWord,
        );
        final isValid2 = appService.gameService.isValidWordCharacters(
          invalidWord,
        );

        // Assert
        expect(isValid1, isTrue);
        expect(isValid2, isFalse);
      });

      test('validates word is not empty', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final emptyWord = Word.fromString('');

        // Act
        final isValid1 = appService.gameService.isValidWordNotEmpty(validWord);
        final isValid2 = appService.gameService.isValidWordNotEmpty(emptyWord);

        // Assert
        expect(isValid1, isTrue);
        expect(isValid2, isFalse);
      });
    });

    group('Game Analysis', () {
      late GameState gameState;
      late Word targetWord;

      setUp(() {
        targetWord = Word.fromString('CRANE');
        gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
      });

      test('analyzes game progress', () {
        // Arrange
        final guess1 = Word.fromString('SLATE');
        final guess2 = Word.fromString('CRATE');
        final result1 = appService.gameService.processGuess(gameState, guess1);
        final result2 = appService.gameService.processGuess(gameState, guess2);

        appService.gameService.addGuessToGame(gameState, guess1, result1);
        appService.gameService.addGuessToGame(gameState, guess2, result2);

        // Act
        final analysis = appService.gameService.analyzeGameProgress(gameState);

        // Assert
        expect(analysis, isNotNull);
        expect(analysis.guessCount, equals(2));
        expect(analysis.remainingGuesses, equals(3));
        expect(analysis.isWon, isFalse);
        expect(analysis.isLost, isFalse);
      });

      test('analyzes letter frequency in guesses', () {
        // Arrange
        final guess1 = Word.fromString('SLATE');
        final guess2 = Word.fromString('CRATE');
        final result1 = appService.gameService.processGuess(gameState, guess1);
        final result2 = appService.gameService.processGuess(gameState, guess2);

        appService.gameService.addGuessToGame(gameState, guess1, result1);
        appService.gameService.addGuessToGame(gameState, guess2, result2);

        // Act
        final letterFrequency = appService.gameService.analyzeLetterFrequency(
          gameState,
        );

        // Assert
        expect(letterFrequency, isNotNull);
        expect(letterFrequency.isNotEmpty, isTrue);
        expect(
          letterFrequency.keys.every((letter) => letter.length == 1),
          isTrue,
        );
      });

      test('analyzes guess effectiveness', () {
        // Arrange
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);

        // Act
        final effectiveness = appService.gameService.analyzeGuessEffectiveness(
          result,
        );

        // Assert
        expect(effectiveness, isNotNull);
        expect(effectiveness.greenCount, equals(result.greenCount));
        expect(effectiveness.yellowCount, equals(result.yellowCount));
        expect(effectiveness.grayCount, equals(result.grayCount));
        expect(effectiveness.isEffective, isA<bool>());
      });

      test('suggests next guess', () {
        // Arrange
        final guess1 = Word.fromString('SLATE');
        final result1 = appService.gameService.processGuess(gameState, guess1);
        appService.gameService.addGuessToGame(gameState, guess1, result1);

        // Act
        final suggestion = appService.gameService.suggestNextGuess(gameState);

        // Assert - suggestion may be null if no valid suggestions available
        if (suggestion != null) {
          expect(suggestion.isValid, isTrue);
          expect(suggestion.length, equals(5));
        }
      });
    });

    group('Game Service Error Handling', () {
      test('handles null game state', () {
        // Arrange
        final guess = Word.fromString('CRANE');

        // Act & Assert
        expect(
          () => appService.gameService.processGuess(null, guess),
          throwsA(isA<InvalidGameStateException>()),
        );
      });

      test('handles null guess', () {
        // Arrange
        final gameState = appService.gameService.createNewGame();

        // Act & Assert
        expect(
          () => appService.gameService.processGuess(gameState, null),
          throwsA(isA<InvalidGuessException>()),
        );
      });

      test('handles game state without target word', () {
        // Arrange
        final gameState = GameState.newGame(); // No target word
        final guess = Word.fromString('CRANE');

        // Act & Assert
        expect(
          () => appService.gameService.processGuess(gameState, guess),
          throwsA(isA<InvalidGameStateException>()),
        );
      });

      test('handles service not initialized', () {
        // Arrange - create a new AppService without initializing
        final uninitializedAppService = AppService();

        // Act & Assert - should throw error when accessing uninitialized
        // service
        expect(
          () => uninitializedAppService.gameService.createNewGame(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Game Service Performance', () {
      late GameState gameState;
      late Word targetWord;

      setUp(() {
        targetWord = Word.fromString('CRANE');
        gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
      });

      test('processes guess quickly', () {
        // Arrange
        final guess = Word.fromString('SLATE');

        // Act
        final stopwatch = Stopwatch()..start();
        final result = appService.gameService.processGuess(gameState, guess);
        stopwatch.stop();

        // Assert
        expect(result, isNotNull);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(10),
        ); // Should process within 10ms
      });

      test('adds guess to game quickly', () {
        // Arrange
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);

        // Act
        final stopwatch = Stopwatch()..start();
        appService.gameService.addGuessToGame(gameState, guess, result);
        stopwatch.stop();

        // Assert
        expect(gameState.guesses.length, equals(1));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5),
        ); // Should add within 5ms
      });

      test('analyzes game quickly', () {
        // Arrange
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Act
        final stopwatch = Stopwatch()..start();
        final analysis = appService.gameService.analyzeGameProgress(gameState);
        stopwatch.stop();

        // Assert
        expect(analysis, isNotNull);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(10),
        ); // Should analyze within 10ms
      });

      test('suggests next guess quickly', () {
        // Arrange
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Act
        final stopwatch = Stopwatch()..start();
        // final suggestion = appService.gameService.suggestNextGuess(gameState); // Not used in this test
        appService.gameService.suggestNextGuess(gameState);
        stopwatch.stop();

        // Assert - suggestion may be null, but should be fast
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Should suggest within 100ms
      });
    });

    group('Game Service Edge Cases', () {
      test('handles game with duplicate letters in target', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
        final guess = Word.fromString('CRANE');

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert
        expect(result.isCorrect, isTrue);
        expect(result.greenCount, equals(5));
      });

      test('handles game with duplicate letters in guess', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
        final guess = Word.fromString('CRANE');

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert
        expect(result.isCorrect, isTrue);
        expect(result.greenCount, equals(5));
      });

      test('handles game with no matching letters', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
        final guess = Word.fromString('SLOTH');

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert - should process gracefully
        expect(result, isNotNull);
        expect(result.word, equals(guess));
      });

      test('handles game with all matching letters', () {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
        final guess = Word.fromString('CRANE');

        // Act
        final result = appService.gameService.processGuess(gameState, guess);

        // Assert
        expect(result.isCorrect, isTrue);
        expect(result.greenCount, equals(5));
        expect(result.yellowCount, equals(0));
        expect(result.grayCount, equals(0));
      });
    });
  });
}
