import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

/// Tests for centralized FFI asset loading functionality
///
/// These tests verify that the word list assets are properly loaded
/// via centralized FFI and contain the expected data structure for the Wordle
/// Helper app.
void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Centralized FFI Asset Loading Tests', () {
    setUpAll(() async {
      await RustLib.init();
      await FfiService.initialize();
    });

    test('word lists can be loaded via centralized FFI', () async {
      final answerWords = FfiService.getAnswerWords();
      final guessWords = FfiService.getGuessWords();

      expect(answerWords, isNotNull);
      expect(guessWords, isNotNull);
      expect(answerWords, isNotEmpty);
      expect(guessWords, isNotEmpty);
    });

    test('word lists contain valid data via centralized FFI', () async {
      final answerWords = FfiService.getAnswerWords();
      final guessWords = FfiService.getGuessWords();

      // Verify it contains word data
      expect(answerWords.length, greaterThan(0));
      expect(guessWords.length, greaterThan(0));
      expect(answerWords, everyElement(isA<String>()));
      expect(guessWords, everyElement(isA<String>()));
    });

    test('word lists contain 5-letter words via centralized FFI', () async {
      final answerWords = FfiService.getAnswerWords();

      // Check first 10 words to verify they are 5 letters
      for (var i = 0; i < answerWords.length && i < 10; i++) {
        final word = answerWords[i];
        expect(
          word.length,
          equals(5),
          reason: 'Word "$word" should be 5 letters long',
        );
      }
    });

    test('word lists contain uppercase words via centralized FFI', () async {
      final answerWords = FfiService.getAnswerWords();

      // Check first 10 words to verify they are uppercase
      for (var i = 0; i < answerWords.length && i < 10; i++) {
        final word = answerWords[i];
        expect(
          word,
          equals(word.toUpperCase()),
          reason: 'Word "$word" should be uppercase',
        );
      }
    });

    test('centralized FFI service is initialized', () async {
      expect(FfiService.isInitialized, isTrue);
    });

    test('word lists are not empty via centralized FFI', () async {
      final answerWords = FfiService.getAnswerWords();
      final guessWords = FfiService.getGuessWords();

      expect(answerWords.length, greaterThan(100)); // Reasonable size check
      expect(guessWords.length, greaterThan(100)); // Reasonable size check
    });
  });

  group('Centralized FFI Content Validation Tests', () {
    test('word lists have reasonable size via centralized FFI', () async {
      final answerWords = FfiService.getAnswerWords();
      final guessWords = FfiService.getGuessWords();

      // Verify it's not too small (should contain substantial word data)
      expect(answerWords.length, greaterThan(100));
      expect(guessWords.length, greaterThan(100));

      // Verify it's not unreasonably large (should be under 50k words)
      expect(answerWords.length, lessThan(50000));
      expect(guessWords.length, lessThan(50000));
    });

    test(
      'word lists contain expected number of words via centralized FFI',
      () async {
      final answerWords = FfiService.getAnswerWords();
      final guessWords = FfiService.getGuessWords();

      // Should have a reasonable number of words (typical Wordle lists have
      // 100+ words)
      expect(answerWords.length, greaterThan(10));
      expect(guessWords.length, greaterThan(10));
      expect(answerWords.length, lessThan(50000)); // Reasonable upper bound
      expect(guessWords.length, lessThan(50000)); // Reasonable upper bound
    });

    test('word lists contain valid words via centralized FFI', () async {
      final answerWords = FfiService.getAnswerWords();
      final guessWords = FfiService.getGuessWords();

      // Verify all words are valid 5-letter uppercase strings
      expect(answerWords, everyElement(predicate((word) => 
        (word as String).length == 5 && word == (word as String).toUpperCase())));
      expect(guessWords, everyElement(predicate((word) => 
        (word as String).length == 5 && word == (word as String).toUpperCase())));
    });
  });
}
