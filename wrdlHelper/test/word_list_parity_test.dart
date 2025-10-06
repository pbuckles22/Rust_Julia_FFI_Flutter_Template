import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/word_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Word List Parity via FFI', () {
    late WordService wordService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      wordService = WordService();
      await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
      await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      await wordService.loadAnswerWords('assets/word_lists/official_wordle_words.json');
    });

    test('counts match expected ranges and are uppercase/deduped', () async {
      // RED: Validate counts and normalization
      final answers = wordService.answerWords.map((w) => w.value).toList();
      final guesses = wordService.guessWords.map((w) => w.value).toList();

      // Expected ranges (loose to avoid flakiness if lists update)
      expect(answers.length, inInclusiveRange(2200, 2400));
      expect(guesses.length, greaterThan(12000));

      // All uppercase and deduped
      expect(answers, everyElement(predicate((String w) => w.length == 5 && w == w.toUpperCase())));
      expect(guesses, everyElement(predicate((String w) => w.length == 5 && w == w.toUpperCase())));
      expect(answers.toSet().length, answers.length);
      expect(guesses.toSet().length, guesses.length);
    });

    test('FFI loads full lists to Rust WORD_MANAGER once without panic', () async {
      final answers = wordService.answerWords.map((w) => w.value).toList();
      final guesses = wordService.guessWords.map((w) => w.value).toList();

      // RED: ensure loading to Rust succeeds
      FfiService.loadWordListsToRust(answers, guesses);

      // Call a few functions to ensure no crashes with large lists
      final filtered = FfiService.filterWords(answers.take(1000).toList(), []);
      expect(filtered, isA<List<String>>());

      final entropy = FfiService.calculateEntropy('SLATE', answers.take(500).toList());
      expect(entropy, greaterThanOrEqualTo(0.0));
    });

    test('sanity: guesses contain SLATE and answers exclude it', () async {
      final answers = wordService.answerWords.map((w) => w.value).toList();
      final guesses = wordService.guessWords.map((w) => w.value).toList();

      // Sanity checks based on Wordle canon
      expect(guesses, contains('SLATE'));
      expect(answers, isNot(contains('SLATE')));
    });
  });
}


