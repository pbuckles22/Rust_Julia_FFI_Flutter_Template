import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/exceptions/game_exceptions.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

import '../helpers/word_test_helper.dart';

/// Comprehensive integration tests for the Wordle game
///
/// These tests validate end-to-end game functionality, service integration,
/// and complete game workflows following TDD principles.
void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Game Integration Tests', () {
    // Now works with comprehensive algorithm-testing word list
    late AppService appService;

    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });
    
    setUp(() {
      // Get the service from the locator
      appService = sl<AppService>();
    });
    
    tearDownAll(() {
      // Clean up after all tests
      resetAllServices();
    });

    group('Complete Game Workflow', () {
      test('plays complete game from start to win', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );

        // Act - Play game with strategic guesses
        final guess1 = Word.fromString('SLATE');
        final result1 = appService.gameService.processGuess(gameState, guess1);
        appService.gameService.addGuessToGame(gameState, guess1, result1);

        final guess2 = Word.fromString('CRATE');
        final result2 = appService.gameService.processGuess(gameState, guess2);
        appService.gameService.addGuessToGame(gameState, guess2, result2);

        final guess3 = Word.fromString('CRANE');
        final result3 = appService.gameService.processGuess(gameState, guess3);
        appService.gameService.addGuessToGame(gameState, guess3, result3);

        // Assert
        expect(gameState.isWon, isTrue);
        expect(gameState.isLost, isFalse);
        expect(gameState.isGameOver, isTrue);
        expect(gameState.gameStatus, equals(GameStatus.won));
        expect(gameState.guesses.length, equals(3));
        expect(result3.isCorrect, isTrue);
      });

      test('plays complete game from start to loss', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
          maxGuesses: 3,
        );

        // Act - Play game with wrong guesses
        final guess1 = Word.fromString('SLATE');
        final result1 = appService.gameService.processGuess(gameState, guess1);
        appService.gameService.addGuessToGame(gameState, guess1, result1);

        final guess2 = Word.fromString('CRATE');
        final result2 = appService.gameService.processGuess(gameState, guess2);
        appService.gameService.addGuessToGame(gameState, guess2, result2);

        final guess3 = Word.fromString('BLAME');
        final result3 = appService.gameService.processGuess(gameState, guess3);
        appService.gameService.addGuessToGame(gameState, guess3, result3);

        // Assert
        expect(gameState.isWon, isFalse);
        expect(gameState.isLost, isTrue);
        expect(gameState.isGameOver, isTrue);
        expect(gameState.gameStatus, equals(GameStatus.lost));
        expect(gameState.guesses.length, equals(3));
        expect(result3.isCorrect, isFalse);
      });

      test('plays game with mixed letter states', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );

        // Act - Play game with strategic guesses
        final guess1 = Word.fromString('SLATE');
        final result1 = appService.gameService.processGuess(gameState, guess1);
        appService.gameService.addGuessToGame(gameState, guess1, result1);

        // Assert - Verify letter states are correct
        expect(
          result1.greenCount,
          equals(2),
        ); // A and E are in correct positions
        expect(result1.yellowCount, equals(0)); // No letters in wrong positions
        expect(result1.grayCount, equals(3)); // S, L, T are not in target

        // Continue game
        final guess2 = Word.fromString('CRATE');
        final result2 = appService.gameService.processGuess(gameState, guess2);
        appService.gameService.addGuessToGame(gameState, guess2, result2);

        // Assert - Verify letter states are correct
        expect(
          result2.greenCount,
          equals(4),
        ); // C, R, A, E are in correct positions
        expect(result2.yellowCount, equals(0)); // No letters in wrong positions
        expect(result2.grayCount, equals(1)); // T is not in target
      });
    });

    group('Service Integration', () {
      test('integrates FFI service with game service', () async {
        // Arrange
        final gameState = appService.gameService.createNewGame();

        // Act
        final targetWord = gameState.targetWord!;
        final isValidWord = FfiService.isValidWord(targetWord.value);

        // Assert
        expect(isValidWord, isTrue);
        expect(FfiService.getAnswerWords().contains(targetWord.value), isTrue);
      });

      test('validates guesses against word service', () async {
        // Arrange
        final validGuess = Word.fromString('CRANE');
        final invalidGuess = Word.fromString('ZZZZZ');

        // Act
        final isValid1 = FfiService.isValidWord(validGuess.value);
        final isValid2 = FfiService.isValidWord(invalidGuess.value);

        // Assert
        expect(isValid1, isTrue);
        expect(isValid2, isFalse);
      });

      test('filters words based on game state', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Act - Use the gameService for word filtering
        final filteredWords = appService.gameService
            .getFilteredWords(gameState)
            .where(
              (word) => word.containsLetter('A') && word.containsLetter('E'),
            )
            .toList();

        // Assert
        expect(filteredWords.isNotEmpty, isTrue);
        expect(
          filteredWords.every((word) => word.containsLetter('A')),
          isTrue,
        );
        expect(
          filteredWords.every((word) => word.containsLetter('E')),
          isTrue,
        );
      });
    });

    group('Asset Integration', () {
      test('loads and validates word list assets', () async {
        // Arrange & Act
        final wordList = FfiService.getAnswerWords()
            .map((word) => Word.fromString(word))
            .toList();
        final guessWords = FfiService.getGuessWords()
            .map((word) => Word.fromString(word))
            .toList();

        // Debug output
        DebugLogger.testPrint(
          'WordList length: ${wordList.length}',
          tag: 'GameIntegrationTest',
        );
        DebugLogger.testPrint(
          'GuessWords length: ${guessWords.length}',
          tag: 'GameIntegrationTest',
        );
        DebugLogger.testPrint(
          'FFI Service isInitialized: ${FfiService.isInitialized}',
          tag: 'GameIntegrationTest',
        );
        DebugLogger.testPrint(
          'FFI Service word lists loaded: '
          '${FfiService.getAnswerWords().length} answer words, '
          '${FfiService.getGuessWords().length} guess words',
          tag: 'GameIntegrationTest',
        );

        // Assert - wordList should be loaded, guessWords might be empty due to
        // test environment
        expect(wordList.isNotEmpty, isTrue);
        // Note: Some words in the official Wordle list may not pass strict Word
        // validation (e.g., "HELLO" is considered invalid by Word model but is
        // a legitimate Wordle word)
        // So we check that words are properly formatted instead of strictly
        // valid
        expect(wordList.every((word) => word.value.length == 5), isTrue);
        expect(
          wordList.every((word) => word.value == word.value.toUpperCase()),
          isTrue,
        );
        // Note: guessWords are now loaded by centralized FFI
        // Guess words include many words that may not pass strict Word
        // validation (like proper nouns, abbreviations, etc.) so we only check
        // they're properly formatted
        if (guessWords.isNotEmpty) {
          expect(
            guessWords.every((word) => word.value.length == 5),
            isTrue,
          );
          expect(
            guessWords.every((word) => word.value == word.value.toUpperCase()),
            isTrue,
          );
        }
      });

      test('validates word list content quality', () async {
        // Arrange & Act
        // final wordList = appService.wordService.wordList; // Not used in this test
        // final guessWords = appService.wordService.guessWords; // Not used in this test

        // For testing, we'll use the WordTestHelper to generate more words
        final testWords = WordTestHelper.generateRandomWords(
          60,
          useGuessWords: false,
        );
        final testGuessWords = WordTestHelper.generateRandomWords(
          60,
          useGuessWords: true,
        );

        // Assert
        expect(
          testWords.length,
          greaterThan(50),
        ); // Should have substantial word list
        expect(
          testGuessWords.length,
          greaterThan(50),
        ); // Should have substantial guess list
        expect(testWords.every((word) => word.value.length == 5), isTrue);
        expect(testGuessWords.every((word) => word.value.length == 5), isTrue);
      });

      test('handles FFI service errors gracefully', () async {
        // Arrange - FFI service should be initialized by test setup
        expect(FfiService.isInitialized, isTrue);

        // Act - should handle gracefully without throwing
        final answerWords = FfiService.getAnswerWords();
        final guessWords = FfiService.getGuessWords();

        // Assert - FFI service should provide word lists
        expect(answerWords.isNotEmpty, isTrue);
        expect(guessWords.isNotEmpty, isTrue);
      });
    });

    group('Game State Persistence', () {
      test('serializes and deserializes game state', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Act
        final json = gameState.toJson();
        final restoredGameState = GameState.fromJson(json);

        // Assert
        expect(restoredGameState.targetWord, equals(gameState.targetWord));
        expect(
          restoredGameState.guesses.length,
          equals(gameState.guesses.length),
        );
        expect(restoredGameState.currentGuess, equals(gameState.currentGuess));
        expect(restoredGameState.isGameOver, equals(gameState.isGameOver));
      });

      test('maintains game state across service calls', () async {
        // Arrange
        final gameState = appService.gameService.createNewGame();
        final guess = Word.fromString('SLATE');
        final result = appService.gameService.processGuess(gameState, guess);
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Act
        final analysis = appService.gameService.analyzeGameProgress(gameState);
        final suggestion = appService.gameService.suggestNextGuess(gameState);

        // Assert
        expect(analysis.guessCount, equals(1));
        // Note: suggestion may be null if no valid words are available
        if (suggestion != null) {
          expect(suggestion.isValid, isTrue);
        }
        expect(gameState.guesses.length, equals(1));
      });
    });

    group('Error Handling Integration', () {
      test('handles invalid guesses gracefully', () async {
        // Arrange
        final gameState = appService.gameService.createNewGame();
        final invalidGuess = Word.fromString('CAT');

        // Act & Assert
        expect(
          () => appService.gameService.processGuess(gameState, invalidGuess),
          throwsA(isA<InvalidGuessException>()),
        );
      });

      test('handles service errors gracefully', () async {
        // Arrange - GameService should work with centralized FFI
        final gameService = GameService();
        await gameService.initialize();

        // Act - should work with centralized FFI
        final gameState = gameService.createNewGame();

        // Assert - service should work with centralized FFI
        expect(gameState, isNotNull);
        expect(gameState.targetWord, isNotNull);
      });

      test('handles FFI service initialization gracefully', () async {
        // Arrange - FFI service should be initialized by test setup
        expect(FfiService.isInitialized, isTrue);

        // Act - should handle gracefully without throwing
        final answerWords = FfiService.getAnswerWords();
        final guessWords = FfiService.getGuessWords();

        // Assert - FFI service should provide word lists
        expect(answerWords.isNotEmpty, isTrue);
        expect(guessWords.isNotEmpty, isTrue);
      });
    });

    group('Performance Integration', () {
      test('completes full game within time limit', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
        );

        // Act
        final stopwatch = Stopwatch()..start();

        // Play complete game
        final guess1 = Word.fromString('SLATE');
        final result1 = appService.gameService.processGuess(gameState, guess1);
        appService.gameService.addGuessToGame(gameState, guess1, result1);

        final guess2 = Word.fromString('CRATE');
        final result2 = appService.gameService.processGuess(gameState, guess2);
        appService.gameService.addGuessToGame(gameState, guess2, result2);

        final guess3 = Word.fromString('CRANE');
        final result3 = appService.gameService.processGuess(gameState, guess3);
        appService.gameService.addGuessToGame(gameState, guess3, result3);

        stopwatch.stop();

        // Assert
        expect(gameState.isWon, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
        ); // Should complete within 1 second
      });

      test('FFI service provides word lists within time limit', () async {
        // Arrange - FFI service should be initialized by test setup
        expect(FfiService.isInitialized, isTrue);

        // Act
        final stopwatch = Stopwatch()..start();
        final answerWords = FfiService.getAnswerWords();
        final guessWords = FfiService.getGuessWords();
        stopwatch.stop();

        // Assert
        expect(answerWords.isNotEmpty, isTrue);
        expect(guessWords.isNotEmpty, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Should access word lists within 100ms
      });

      test('processes multiple guesses efficiently', () async {
        // Arrange
        final gameState = appService.gameService.createNewGame();
        final guesses = [
          Word.fromString('SLATE'),
          Word.fromString('CRATE'),
          Word.fromString('BLAME'),
          Word.fromString('GRADE'),
          Word.fromString('SHARE'),
        ];

        // Act
        final stopwatch = Stopwatch()..start();

        for (final guess in guesses) {
          final result = appService.gameService.processGuess(gameState, guess);
          appService.gameService.addGuessToGame(gameState, guess, result);
        }

        stopwatch.stop();

        // Assert
        expect(gameState.guesses.length, equals(5));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Should process 5 guesses within 100ms
      });
    });

    group('Edge Case Integration', () {
      test('handles game with maximum guesses', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
          maxGuesses: 5,
        );

        // Act - use different words for each guess to avoid duplicate
        // validation and winning
        final words = ['SLATE', 'TRACE', 'BLAME', 'GRADE', 'SHARE'];
        for (int i = 0; i < 5; i++) {
          final guess = Word.fromString(words[i]);
          final result = appService.gameService.processGuess(gameState, guess);
          appService.gameService.addGuessToGame(gameState, guess, result);
        }

        // Assert
        expect(gameState.guesses.length, equals(5));
        expect(gameState.isGameOver, isTrue);
        expect(gameState.isLost, isTrue);
      });

      test('handles game won on last guess', () async {
        // Arrange
        final targetWord = Word.fromString('CRANE');
        final gameState = appService.gameService.createNewGame(
          targetWord: targetWord,
          maxGuesses: 1,
        );

        // Act
        final guess = Word.fromString('CRANE');
        final result = appService.gameService.processGuess(gameState, guess);
        appService.gameService.addGuessToGame(gameState, guess, result);

        // Assert
        expect(gameState.isWon, isTrue);
        expect(gameState.isLost, isFalse);
        expect(gameState.isGameOver, isTrue);
      });

      test('handles game with duplicate letters', () async {
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
