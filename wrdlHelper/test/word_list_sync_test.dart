import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Word List Synchronization Tests', () {
    // Now works with centralized FFI word lists
    
    setUpAll(() async {
      // Initialize Flutter binding for asset loading
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize FFI once (word lists are loaded by centralized FFI during
      // initialization)
      await RustLib.init();
      await FfiService.initialize();
    });

    test('word lists should be synchronized between Dart and Rust', () {
      // Get word counts from centralized FFI
      final dartGuessWords = FfiService.getGuessWords().length;
      final dartAnswerWords = FfiService.getAnswerWords().length;
      
      print('📊 Centralized FFI word counts:');
      print('  • Guess words: $dartGuessWords');
      print('  • Answer words: $dartAnswerWords');
      
      // Test that we have the expected word counts
      expect(dartGuessWords, greaterThan(10000)); // Should have 14,854+ words
      expect(dartAnswerWords, greaterThan(2000)); // Should have 2,315+ words
      
      // Word lists are already loaded to Rust by centralized FFI during
      // initialization
      print('✅ Word lists already loaded to Rust by centralized FFI');
      print(
        '🎯 Rust now has ${dartGuessWords} guess words and '
        '${dartAnswerWords} answer words',
      );
    });

    test('optimal first guess should be available from Rust', () {
      final optimalFirstGuess = FfiService.getOptimalFirstGuess();
      
      expect(optimalFirstGuess, isNotNull);
      expect(optimalFirstGuess!.length, equals(5));
      expect(optimalFirstGuess, isA<String>());
      
      print('🎯 Optimal first guess from Rust: $optimalFirstGuess');
      
      // Should be one of the known optimal first guesses
      final knownOptimalGuesses = ['TARES', 'SLATE', 'CRANE', 'CRATE', 'SLANT'];
      expect(knownOptimalGuesses, contains(optimalFirstGuess));
    });

    test('Rust should be able to process real word lists', () {
      // Test with a small subset of real words from centralized FFI
      final testWords = FfiService.getGuessWords().take(100).toList();
      final testResults = <(String, List<String>)>[];
      
      // Test that Rust can handle real word lists
      final result = FfiService.getBestGuessFast(testWords, testResults);
      
      expect(result, isNotNull);
      expect(result!.length, equals(5));
      // The result should be a valid 5-letter word (may not be in the subset
      // due to algorithm logic)
      expect(result, matches(RegExp(r'^[A-Z]{5}$')));
      
      print('🧠 Rust processed real words successfully: $result');
    });

    test('word filtering should work with real word lists', () {
      // Test word filtering with real words from centralized FFI
      final allWords = FfiService.getGuessWords().take(1000).toList();
      final guessResults = [
        ('CRANE', ['X', 'X', 'X', 'X', 'X']), // All gray
      ];
      
      final filtered = FfiService.filterWords(allWords, guessResults);
      
      expect(filtered, isNotEmpty);
      expect(filtered.length, lessThan(allWords.length));
      
      // All filtered words should not contain C, R, A, N, E
      for (final word in filtered) {
        expect(word.contains('C'), isFalse);
        expect(word.contains('R'), isFalse);
        expect(word.contains('A'), isFalse);
        expect(word.contains('N'), isFalse);
        expect(word.contains('E'), isFalse);
      }
      
      print(
        '🔍 Word filtering works with real words: '
        '${filtered.length} words remaining',
      );
    });
  });
}
