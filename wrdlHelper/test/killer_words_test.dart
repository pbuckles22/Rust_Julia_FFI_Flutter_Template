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
      FfiService.setConfiguration(FfiConfiguration(
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
      
      // Should be one of the known killer words
      final killerWords = ['VOMIT', 'PSYCH', 'GLYPH', 'JUMBO', 'ZEBRA', 'SLATE', 'CRANE', 'TRACE'];
      expect(killerWords, contains(bestGuess));
    });

    test('should not include killer words when flag is disabled', () {
      // RED: This test will fail until we implement the flag logic
      FfiService.setConfiguration(FfiConfiguration(
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
      
      // Should suggest one of the remaining words (current behavior)
      expect(bestGuess, isNotNull);
      expect(remainingWords, contains(bestGuess));
    });

    test('should have higher entropy for killer words in classic trap scenario', () {
      // RED: This test will fail until we implement entropy calculation with killer words
      FfiService.setConfiguration(FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 500,
        earlyTerminationEnabled: false, // Disable early termination for full analysis
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: true,
      ));

      final remainingWords = ['MATCH', 'PATCH', 'LATCH', 'HATCH'];
      final guessResults = <(String, List<String>)>[];
      
      // Calculate entropy for different candidate words
      final vomitEntropy = FfiService.calculateEntropy('VOMIT', remainingWords);
      final matchEntropy = FfiService.calculateEntropy('MATCH', remainingWords);
      final slateEntropy = FfiService.calculateEntropy('SLATE', remainingWords);
      
      // VOMIT should have higher entropy than MATCH (one of the remaining words)
      expect(vomitEntropy, greaterThan(matchEntropy));
      
      // VOMIT should have high entropy (close to maximum for 4 words)
      expect(vomitEntropy, greaterThan(1.5));
      
      print('Entropy values: VOMIT=$vomitEntropy, MATCH=$matchEntropy, SLATE=$slateEntropy');
    });

    test('should include all curated killer words in candidate pool', () {
      // RED: This test will fail until we implement the curated list
      FfiService.setConfiguration(FfiConfiguration(
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

      // Test with empty remaining words to see all candidates
      final remainingWords = <String>[];
      final guessResults = <(String, List<String>)>[];
      
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      // Should return one of the killer words when no remaining words
      expect(bestGuess, isNotNull);
      expect(expectedKillerWords, contains(bestGuess));
    });

    test('should maintain performance with killer words enabled', () {
      // RED: This test will fail until we implement performance optimization
      FfiService.setConfiguration(FfiConfiguration(
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
