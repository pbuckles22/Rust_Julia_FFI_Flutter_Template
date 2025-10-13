import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('FFI Service Basic Functions Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('getAnswerWords() should return list of answer words', () {
      // RED: This test will verify the basic FFI function works
      final answerWords = FfiService.getAnswerWords();
      
      // Should return a non-empty list
      expect(answerWords, isNotNull);
      expect(answerWords, isA<List<String>>());
      expect(answerWords.length, greaterThan(0));
      
      // Should contain valid 5-letter words
      for (final word in answerWords.take(10)) {
        expect(word.length, equals(5));
        expect(word, matches(RegExp(r'^[A-Z]{5}$')));
      }
      
      // Should contain some known answer words
      final knownAnswerWords = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE'];
      final hasKnownWords = knownAnswerWords.any(answerWords.contains);
      expect(
        hasKnownWords,
        isTrue,
        reason: 'Should contain some known answer words',
      );
    });

    test('getGuessWords() should return list of guess words', () {
      // RED: This test will verify the basic FFI function works
      final guessWords = FfiService.getGuessWords();
      
      // Should return a non-empty list
      expect(guessWords, isNotNull);
      expect(guessWords, isA<List<String>>());
      expect(guessWords.length, greaterThan(0));
      
      // Should contain valid 5-letter words
      for (final word in guessWords.take(10)) {
        expect(word.length, equals(5));
        expect(word, matches(RegExp(r'^[A-Z]{5}$')));
      }
      
      // Should contain more words than answer words (guess words include all
      // valid words)
      final answerWords = FfiService.getAnswerWords();
      expect(guessWords.length, greaterThan(answerWords.length));
    });

    test('isValidWord() should validate words correctly', () {
      // RED: This test will verify the basic FFI function works
      
      // Valid words should return true
      expect(FfiService.isValidWord('CRANE'), isTrue);
      expect(FfiService.isValidWord('SLATE'), isTrue);
      expect(FfiService.isValidWord('HELLO'), isTrue);
      
      // Invalid words should return false
      expect(FfiService.isValidWord('XXXXX'), isFalse);
      expect(FfiService.isValidWord('INVALID'), isFalse);
      expect(FfiService.isValidWord(''), isFalse);
      expect(FfiService.isValidWord('WORD'), isFalse); // Too short
      expect(FfiService.isValidWord('TOOLONG'), isFalse); // Too long
    });
  });
}
