import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Word List Parity via FFI', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      // Word lists are now loaded by centralized FFI during initialization
    });

    tearDownAll(() {
      // Clean up FFI resources to prevent test interference
      try {
        RustLib.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    });

    test('counts match expected ranges and are uppercase/deduped', () async {
      // RED: Validate counts and normalization using centralized FFI
      final answers = FfiService.getAnswerWords() as List<String>;
      final guesses = FfiService.getGuessWords() as List<String>;

      // Expected ranges (loose to avoid flakiness if lists update)
      expect(answers.length, inInclusiveRange(2200, 2400));
      expect(guesses.length, greaterThan(12000));

      // All uppercase and deduped
      expect(
        answers,
        everyElement(
          predicate((w) => (w as String).length == 5 && w == (w as String).toUpperCase()),
        ),
      );
      expect(
        guesses,
        everyElement(
          predicate((w) => (w as String).length == 5 && w == (w as String).toUpperCase()),
        ),
      );
      expect(answers.toSet().length, answers.length);
      expect(guesses.toSet().length, guesses.length);
    });

    test(
      'FFI loads full lists to Rust WORD_MANAGER once without panic',
      () async {
      final answers = FfiService.getAnswerWords() as List<String>;

      // Word lists are now loaded directly by Rust during FFI initialization
      // No need to manually load them - they're already available

      // Call a few functions to ensure no crashes with large lists
      final filtered = FfiService.filterWords(answers.take(1000).toList(), []);
      expect(filtered, isA<List<String>>());

      final entropy = FfiService.calculateEntropy(
        'SLATE',
        answers.take(500).toList(),
      );
      expect(entropy, greaterThanOrEqualTo(0.0));
    });

    test('sanity: guesses contain SLATE and answers exclude it', () async {
      final answers = FfiService.getAnswerWords() as List<String>;
      final guesses = FfiService.getGuessWords() as List<String>;

      // Sanity checks based on Wordle canon
      expect(guesses, contains('SLATE'));
      expect(answers, isNot(contains('SLATE')));
    });
  });
}



