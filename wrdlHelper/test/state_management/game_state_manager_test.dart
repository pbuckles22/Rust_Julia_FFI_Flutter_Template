import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/state_management/game_state_manager.dart';

void main() {
  group('GameStateManager TDD Tests', () {
    late GameStateManager stateManager;

    setUp(() {
      // This will fail initially - we need to implement GameStateManager
      stateManager = GameStateManager();
    });

    test('should initialize with default state', () {
      // This test should fail initially - we need to implement initialization
      expect(stateManager.gameState, isNull);
      expect(stateManager.isInitialized, isFalse);
      expect(stateManager.currentInput, isEmpty);
      expect(stateManager.errorMessage, isNull);
      expect(stateManager.isLoading, isFalse);
    });

    test('should create new game state', () {
      // This test should fail initially - we need to implement game creation
      final targetWord = Word.fromString('CRATE');
      final gameState = stateManager.createNewGame(targetWord);

      expect(gameState, isNotNull);
      expect(gameState.targetWord, equals(targetWord));
      expect(gameState.guesses, isEmpty);
      expect(gameState.isGameOver, isFalse);
      expect(gameState.isWon, isFalse);
    });

    test('should update current input', () {
      // This test should fail initially - we need to implement input management
      stateManager.updateCurrentInput('A');

      expect(stateManager.currentInput, equals('A'));
    });

    test('should append letter to current input', () {
      // This test should fail initially - we need to implement letter appending
      stateManager.appendLetter('A');
      stateManager.appendLetter('B');
      stateManager.appendLetter('C');

      expect(stateManager.currentInput, equals('ABC'));
    });

    test('should not append letter when input is full', () {
      // This test should fail initially - we need to implement input validation
      stateManager.appendLetter('A');
      stateManager.appendLetter('B');
      stateManager.appendLetter('C');
      stateManager.appendLetter('D');
      stateManager.appendLetter('E');
      stateManager.appendLetter('F'); // Should not be added

      expect(stateManager.currentInput, equals('ABCDE'));
    });

    test('should remove last letter from input', () {
      // This test should fail initially - we need to implement backspace
      stateManager.appendLetter('A');
      stateManager.appendLetter('B');
      stateManager.appendLetter('C');

      stateManager.removeLastLetter();

      expect(stateManager.currentInput, equals('AB'));
    });

    test('should clear current input', () {
      // This test should fail initially - we need to implement clear functionality
      stateManager.appendLetter('A');
      stateManager.appendLetter('B');
      stateManager.appendLetter('C');

      stateManager.clearInput();

      expect(stateManager.currentInput, isEmpty);
    });

    test('should add guess to game state', () {
      // This test should fail initially - we need to implement guess management
      final gameState = stateManager.createNewGame(Word.fromString('CRATE'));
      final guess = Word.fromString('CRANE');
      final result = GuessResult.fromWord(Word.fromString('CRANE'));

      stateManager.addGuess(gameState, guess, result);

      expect(gameState.guesses.length, equals(1));
      expect(gameState.guesses.first.result, equals(result));
    });

    test('should update game state when guess is correct', () {
      // This test should fail initially - we need to implement win condition
      final gameState = stateManager.createNewGame(Word.fromString('CRATE'));
      final guess = Word.fromString('CRATE');
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

      stateManager.addGuess(gameState, guess, result);

      expect(gameState.isWon, isTrue);
      expect(gameState.isGameOver, isTrue);
    });

    test('should update game state when max guesses reached', () {
      // This test should fail initially - we need to implement game over condition
      final gameState = stateManager.createNewGame(Word.fromString('CRATE'));

      // Add 5 different guesses (max for helper app)
      final words = ['CRANE', 'SLATE', 'TRACE', 'BLAME', 'GRADE'];
      for (int i = 0; i < 5; i++) {
        final guess = Word.fromString(words[i]);
        final result = GuessResult.fromWord(Word.fromString(words[i]));
        stateManager.addGuess(gameState, guess, result);
      }

      expect(gameState.isGameOver, isTrue);
      expect(gameState.isWon, isFalse);
    });

    test('should set error message', () {
      // This test should fail initially - we need to implement error management
      stateManager.setError('Test error message');

      expect(stateManager.errorMessage, equals('Test error message'));
    });

    test('should clear error message', () {
      // This test should fail initially - we need to implement error clearing
      stateManager.setError('Test error message');
      stateManager.clearError();

      expect(stateManager.errorMessage, isNull);
    });

    test('should set loading state', () {
      // This test should fail initially - we need to implement loading state
      stateManager.setLoading(true);

      expect(stateManager.isLoading, isTrue);
    });

    test('should clear loading state', () {
      // This test should fail initially - we need to implement loading state clearing
      stateManager.setLoading(true);
      stateManager.setLoading(false);

      expect(stateManager.isLoading, isFalse);
    });

    test('should reset all state', () {
      // This test should fail initially - we need to implement state reset
      stateManager.appendLetter('A');
      stateManager.setError('Test error');
      stateManager.setLoading(true);

      stateManager.reset();

      expect(stateManager.currentInput, isEmpty);
      expect(stateManager.errorMessage, isNull);
      expect(stateManager.isLoading, isFalse);
      expect(stateManager.gameState, isNull);
    });

    test('should validate word length', () {
      // This test should fail initially - we need to implement validation
      expect(stateManager.isValidWordLength('ABC'), isFalse);
      expect(stateManager.isValidWordLength('ABCDE'), isTrue);
      expect(stateManager.isValidWordLength('ABCDEF'), isFalse);
    });

    test('should get remaining guesses count', () {
      // This test should fail initially - we need to implement guess counting
      final gameState = stateManager.createNewGame(Word.fromString('CRATE'));

      expect(stateManager.getRemainingGuesses(gameState), equals(6));

      // Add one guess
      final guess = Word.fromString('CRANE');
      final result = GuessResult.fromWord(Word.fromString('CRANE'));
      stateManager.addGuess(gameState, guess, result);

      expect(stateManager.getRemainingGuesses(gameState), equals(5));
    });

    test('should check if game is in progress', () {
      // This test should fail initially - we need to implement game status checking
      final gameState = stateManager.createNewGame(Word.fromString('CRATE'));

      expect(stateManager.isGameInProgress(gameState), isTrue);

      // Mark game as over
      gameState.isGameOver = true;

      expect(stateManager.isGameInProgress(gameState), isFalse);
    });

    test('should handle state changes with listeners', () {
      // This test should fail initially - we need to implement listener system
      bool listenerCalled = false;

      stateManager.addListener(() {
        listenerCalled = true;
      });

      stateManager.appendLetter('A');

      expect(listenerCalled, isTrue);
    });

    test('should remove listeners', () {
      // This test should fail initially - we need to implement listener removal
      bool listenerCalled = false;

      void listener() {
        listenerCalled = true;
      }

      stateManager.addListener(listener);
      stateManager.removeListener(listener);

      stateManager.appendLetter('A');

      expect(listenerCalled, isFalse);
    });

    test('should dispose resources correctly', () {
      // This test should fail initially - we need to implement disposal
      expect(() => stateManager.dispose(), returnsNormally);
    });

    test('should handle rapid state changes', () {
      // This test should fail initially - we need to implement rapid change handling
      for (int i = 0; i < 100; i++) {
        stateManager.appendLetter('A');
        stateManager.removeLastLetter();
      }

      expect(stateManager.currentInput, isEmpty);
    });

    test('should maintain state consistency across operations', () {
      // This test should fail initially - we need to implement state consistency
      // final gameState = stateManager.createNewGame(Word.fromString('CRATE')); // Not used in this test
      stateManager.createNewGame(Word.fromString('CRATE'));
      stateManager.appendLetter('A');
      stateManager.appendLetter('B');

      final inputBefore = stateManager.currentInput;
      final gameStateBefore = stateManager.gameState;

      stateManager.appendLetter('C');
      stateManager.removeLastLetter();

      expect(stateManager.currentInput, equals(inputBefore));
      expect(stateManager.gameState, equals(gameStateBefore));
    });
  });
}
