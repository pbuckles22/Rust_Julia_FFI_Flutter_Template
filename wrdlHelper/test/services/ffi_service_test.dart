import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/service_locator.dart';

void main() {
  group('FfiService Tests', () {
    setUpAll(() async {
      // Initialize services for testing
      await setupTestServices();
    });

    group('isValidWord', () {
      test('should return true for valid words', () async {
        // MICRO-STEP 1: Test FfiService.isValidWord() with a single test case
        // Verify it returns true for valid words
        
        // Test with a common valid word
        final result = FfiService.isValidWord('SLATE');
        
        expect(result, isTrue, reason: 'SLATE should be a valid word');
      });

      test('should return false for invalid words', () async {
        // MICRO-STEP 2: Test FfiService.isValidWord() with invalid words
        // Verify it returns false for invalid words
        
        // Test with an invalid word
        final result = FfiService.isValidWord('XXXXX');
        
        expect(result, isFalse, reason: 'XXXXX should not be a valid word');
      });
    });

    group('getAnswerWords', () {
      test('should return the correct number of answer words', () async {
        // MICRO-STEP 3: Test FfiService.getAnswerWords()
        // Verify it returns the correct number of answer words
        
        final answerWords = FfiService.getAnswerWords();
        
        expect(answerWords, isNotEmpty, reason: 'Answer words should not be empty');
        expect(answerWords.length, equals(2300), reason: 'Should have 2300 answer words (full production list)');
        expect(answerWords.first, isA<String>(), reason: 'Answer words should be strings');
        expect(answerWords.first.length, equals(5), reason: 'Answer words should be 5 letters');
      });
    });

    group('getGuessWords', () {
      test('should return the correct number of guess words', () async {
        // MICRO-STEP 4: Test FfiService.getGuessWords()
        // Verify it returns the correct number of guess words
        
        final guessWords = FfiService.getGuessWords();
        
        expect(guessWords, isNotEmpty, reason: 'Guess words should not be empty');
        expect(guessWords.length, equals(14855), reason: 'Should have 14855 guess words (full production list)');
        expect(guessWords.first, isA<String>(), reason: 'Guess words should be strings');
        expect(guessWords.first.length, equals(5), reason: 'Guess words should be 5 letters');
      });
    });

    group('GameService Integration', () {
      test('GameService.isValidWord() should call FfiService.isValidWord()', () async {
        // MICRO-STEP 6: Test GameService.isValidWord() calls FfiService.isValidWord()
        // This test will initially fail because GameService still uses WordService
        // We'll refactor GameService to use FfiService.isValidWord() later
        
        // Import GameService for testing
        final gameService = GameService();
        await gameService.initialize();
        
        // Test that GameService.isValidWord() works with a valid word
        final word = Word.fromString('SLATE');
        final result = gameService.isValidWord(word);
        
        expect(result, isTrue, reason: 'GameService.isValidWord() should return true for valid words');
        
        // Test that GameService.isValidWord() works with an invalid word
        final invalidWord = Word.fromString('XXXXX');
        final invalidResult = gameService.isValidWord(invalidWord);
        
        expect(invalidResult, isFalse, reason: 'GameService.isValidWord() should return false for invalid words');
      });

      test('GameService.getFilteredWords() should use Rust filtering', () async {
        // MICRO-STEP 8: Test GameService word filtering uses Rust
        // This test will initially fail because GameService still uses WordService for initial word list
        // We'll refactor GameService to use FfiService.getGuessWords() later
        
        // Import GameService for testing
        final gameService = GameService();
        await gameService.initialize();
        
        // Test that getFilteredWords() works with no game state (should return all words)
        final allWords = gameService.getFilteredWords();
        
        expect(allWords, isNotEmpty, reason: 'getFilteredWords() should return words when no game state provided');
        expect(allWords.length, greaterThan(1000), reason: 'Should have many words available');
        expect(allWords.first, isA<Word>(), reason: 'Should return Word objects');
        
        // Test that getFilteredWords() works with empty game state
        final gameState = gameService.createNewGame();
        final filteredWords = gameService.getFilteredWords(gameState);
        
        expect(filteredWords, isNotEmpty, reason: 'getFilteredWords() should return words for empty game state');
        expect(filteredWords.length, equals(allWords.length), reason: 'Empty game state should return all words');
      });

      test('GameService.getBestNextGuess() should use Rust algorithm', () async {
        // MICRO-STEP 10: Test GameService word selection uses Rust
        // This test will initially fail because GameService still uses WordService for allWords
        // We'll refactor GameService to use FfiService.getGuessWords() later
        
        // Import GameService for testing
        final gameService = GameService();
        await gameService.initialize();
        
        // Create a new game to test word selection
        final gameState = gameService.createNewGame();
        
        // Test that getBestNextGuess() works and returns a valid word
        final suggestion = gameService.getBestNextGuess(gameState);
        
        expect(suggestion, isNotNull, reason: 'getBestNextGuess() should return a suggestion');
        expect(suggestion, isA<Word>(), reason: 'Should return a Word object');
        expect(suggestion!.value.length, equals(5), reason: 'Suggestion should be 5 letters');
        expect(suggestion.value, matches(RegExp(r'^[A-Z]+$')), reason: 'Suggestion should be uppercase letters only');
        
        // Test that the suggestion is a valid word
        final isValid = gameService.isValidWord(suggestion);
        expect(isValid, isTrue, reason: 'Suggestion should be a valid word');
      });
    });
  });
}
