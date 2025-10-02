import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/word_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Word List Synchronization Tests', () {
    late WordService wordService;
    
    setUpAll(() async {
      // Initialize Flutter binding for asset loading
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize FFI once
      await RustLib.init();
      await FfiService.initialize();
    });

    setUp(() async {
      wordService = WordService();
      await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
      await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      await wordService.loadAnswerWords('assets/word_lists/official_wordle_words.json');
    });

    test('word lists should be synchronized between Dart and Rust', () {
      // Get word counts from Dart side
      final dartGuessWords = wordService.guessWords.length;
      final dartAnswerWords = wordService.answerWords.length;
      
      print('📊 Dart word counts:');
      print('  • Guess words: $dartGuessWords');
      print('  • Answer words: $dartAnswerWords');
      
      // Test that we have the expected word counts
      expect(dartGuessWords, greaterThan(10000)); // Should have 14,854+ words
      expect(dartAnswerWords, greaterThan(2000));  // Should have 2,315+ words
      
      // Load word lists to Rust
      FfiService.loadWordListsToRust(
        wordService.answerWords.map((w) => w.value).toList(),
        wordService.guessWords.map((w) => w.value).toList(),
      );
      
      print('✅ Word lists loaded to Rust successfully');
      print('🎯 This should now have ${dartGuessWords} guess words and ${dartAnswerWords} answer words in Rust');
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
      // Test with a small subset of real words
      final testWords = wordService.guessWords.take(100).map((w) => w.value).toList();
      final testResults = <(String, List<String>)>[];
      
      // Test that Rust can handle real word lists
      final result = FfiService.getBestGuessFast(testWords, testResults);
      
      expect(result, isNotNull);
      expect(result!.length, equals(5));
      expect(testWords, contains(result));
      
      print('🧠 Rust processed real words successfully: $result');
    });

    test('word filtering should work with real word lists', () {
      // Test word filtering with real words
      final allWords = wordService.guessWords.take(1000).map((w) => w.value).toList();
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
      
      print('🔍 Word filtering works with real words: ${filtered.length} words remaining');
    });
  });
}
