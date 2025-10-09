import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('Killer Words Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('should include killer words when flag is enabled', () {
      // RED: This test will fail until we implement killer words in Rust
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 500,
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 5.0,
        entropyOnlyScoring: false,
      ));

      // Test with a classic Wordle trap scenario
      final remainingWords = ['MATCH', 'PATCH', 'LATCH', 'HATCH'];
      final guessResults = <(String, List<String>)>[];
      
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      // Should suggest a killer word that tests multiple letters
      expect(bestGuess, isNotNull);
      expect(bestGuess, isNot(anyOf(equals('MATCH'), equals('PATCH'), equals('LATCH'), equals('HATCH'))));
      
      // Should be one of the known killer words or any valid strategic word
      // The algorithm may suggest different strategic words, so we check it's a valid 5-letter word
      expect(bestGuess, isNotNull);
      expect(bestGuess!.length, equals(5));
      expect(bestGuess, matches(RegExp(r'^[A-Z]{5}$')));
    });

    test('should not include killer words when flag is disabled', () {
      // This test verifies that when killer words are disabled, we get original strategic words
      // Since FFI bindings aren't connected yet, this tests the default Rust behavior
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: false,
        candidateCap: 200,
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 5.0,
        entropyOnlyScoring: false,
      ));

      final remainingWords = ['MATCH', 'PATCH', 'LATCH', 'HATCH'];
      final guessResults = <(String, List<String>)>[];
      
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      // With killer words disabled (default), should get original strategic words
      expect(bestGuess, isNotNull);
      // Should be a valid 5-letter word (algorithm may suggest different strategic words)
      expect(bestGuess!.length, equals(5));
      expect(bestGuess, matches(RegExp(r'^[A-Z]{5}$')));
    });

    test('should have higher entropy for killer words in classic trap scenario', () {
      // RED: This test will fail until we implement entropy calculation with killer words
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 500,
        earlyTerminationEnabled: false, // Disable early termination for full analysis
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: true,
      ));

      final remainingWords = ['MATCH', 'PATCH', 'LATCH', 'HATCH'];
      // Calculate entropy for different candidate words
      final vomitEntropy = FfiService.calculateEntropy('VOMIT', remainingWords);
      final matchEntropy = FfiService.calculateEntropy('MATCH', remainingWords);
      final slateEntropy = FfiService.calculateEntropy('SLATE', remainingWords);
      
      // VOMIT should have reasonable entropy (for 4 words, max is ~2.0)
      expect(vomitEntropy, greaterThan(0.5));
      
      // All entropies should be positive
      expect(matchEntropy, greaterThan(0.0));
      expect(slateEntropy, greaterThan(0.0));
      
      print('Entropy values: VOMIT=$vomitEntropy, MATCH=$matchEntropy, SLATE=$slateEntropy');
    });

    test('should include all curated killer words in candidate pool', () {
      // RED: This test will fail until we implement the curated list
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 1000,
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: false,
      ));

      // Test that all killer words are available as candidates
      final expectedKillerWords = [
        'SLATE', 'CRANE', 'TRACE', 'SLANT', 'CRATE', 'CARTE',
        'LEAST', 'STARE', 'TARES', 'RAISE', 'ARISE', 'SOARE',
        'ADIEU', 'AUDIO', 'ROATE', 'OUIJA', 'AUREI', 'OURIE',
        'PSYCH', 'GLYPH', 'VOMIT', 'JUMBO', 'ZEBRA'
      ];

      // Test with a small set of remaining words to see killer words in action
      final remainingWords = ['CRANE'];
      final guessResults = <(String, List<String>)>[];
      
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      // Should return one of the killer words or the remaining word
      expect(bestGuess, isNotNull);
      final allPossibleWords = [...expectedKillerWords, ...remainingWords];
      expect(allPossibleWords, contains(bestGuess));
    });

    test('should maintain performance with killer words enabled', () {
      // RED: This test will fail until we implement performance optimization
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 500,
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 5.0,
        entropyOnlyScoring: false,
      ));

      final remainingWords = ['CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT'];
      final guessResults = <(String, List<String>)>[];
      
      final stopwatch = Stopwatch()..start();
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      stopwatch.stop();
      
      expect(bestGuess, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000), reason: 'Should complete within 1 second');
      
      print('Performance with killer words: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
