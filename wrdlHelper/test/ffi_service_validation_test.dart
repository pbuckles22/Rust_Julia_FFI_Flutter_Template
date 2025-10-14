import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('FFI Service Validation Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    tearDownAll(() {
      // Clean up FFI resources to prevent test interference
      try {
        RustLib.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    });

    test('isValidWord() should handle edge cases correctly', () {
      // RED: This test will verify comprehensive validation
      
      // Valid words from answer list (uppercase)
      expect(FfiService.isValidWord('CRANE'), isTrue);
      expect(FfiService.isValidWord('SLATE'), isTrue);
      expect(FfiService.isValidWord('TARES'), isTrue);
      
      // Valid words from guess list (but not answer list)
      expect(FfiService.isValidWord('HELLO'), isTrue);
      expect(FfiService.isValidWord('WORLD'), isTrue);
      
      // Valid words with different cases (should be normalized to uppercase)
      expect(
        FfiService.isValidWord('crane'),
        isTrue,
        reason: 'Lowercase should be normalized to uppercase',
      );
      expect(
        FfiService.isValidWord('CrAnE'),
        isTrue,
        reason: 'Mixed case should be normalized to uppercase',
      );
      
      // Invalid format cases
      expect(
        FfiService.isValidWord(''),
        isFalse,
        reason: 'Empty string should be invalid',
      );
      expect(
        FfiService.isValidWord('WORD'),
        isFalse,
        reason: '4-letter word should be invalid',
      );
      expect(
        FfiService.isValidWord('TOOLONG'),
        isFalse,
        reason: '6-letter word should be invalid',
      );
      expect(
        FfiService.isValidWord('CR4NE'),
        isFalse,
        reason: 'Numbers should be invalid',
      );
      expect(
        FfiService.isValidWord('CR-AN'),
        isFalse,
        reason: 'Special characters should be invalid',
      );
      expect(
        FfiService.isValidWord('CR AN'),
        isFalse,
        reason: 'Spaces should be invalid',
      );
      
      // Non-existent words
      expect(
        FfiService.isValidWord('XXXXX'),
        isFalse,
        reason: 'Non-existent word should be invalid',
      );
      expect(
        FfiService.isValidWord('QWERT'),
        isFalse,
        reason: 'Non-existent word should be invalid',
      );
      expect(
        FfiService.isValidWord('ASDFG'),
        isFalse,
        reason: 'Non-existent word should be invalid',
      );
    });

    test('isValidWord() should be consistent with word lists', () {
      // RED: This test will verify validation matches word lists
      
      final answerWords = FfiService.getAnswerWords();
      final guessWords = FfiService.getGuessWords();
      
      // All answer words should be valid
      for (final word in answerWords.take(20)) {
        expect(FfiService.isValidWord(word), isTrue, 
               reason: 'Answer word "$word" should be valid');
      }
      
      // All guess words should be valid
      for (final word in guessWords.take(20)) {
        expect(FfiService.isValidWord(word), isTrue, 
               reason: 'Guess word "$word" should be valid');
      }
      
      // Answer words should be a subset of guess words
      for (final answerWord in answerWords.take(10)) {
        expect(guessWords.contains(answerWord), isTrue,
               reason: 'Answer word "$answerWord" should be in guess words');
      }
    });

    test('isValidWord() should handle null and special cases gracefully', () {
      // RED: This test will verify error handling
      
      // Test with null-like inputs (if supported)
      expect(FfiService.isValidWord(''), isFalse);
      
      // Test with very long strings
      expect(FfiService.isValidWord('A' * 100), isFalse);
      
      // Test with unicode characters
      expect(FfiService.isValidWord('CRANÉ'), isFalse);
      expect(FfiService.isValidWord('CRANÈ'), isFalse);
      
      // Test with whitespace variations
      expect(FfiService.isValidWord(' CRANE'), isFalse);
      expect(FfiService.isValidWord('CRANE '), isFalse);
      expect(FfiService.isValidWord('CR ANE'), isFalse);
    });
  });
}
