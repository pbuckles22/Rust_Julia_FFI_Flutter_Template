import 'package:flutter_test/flutter_test.dart';
import 'package:my_working_ffi_app/src/rust/frb_generated.dart';

void main() {
  group('wrdlHelper Intelligent Solver Tests', () {
    setUpAll(() {
      // Initialize the FFI bridge
      RustLib.init();
    });

    group('Basic FFI Functions', () {
      test('should calculate entropy for candidate word', () async {
        final candidate = 'CRANE';
        final remaining = ['CRANE', 'SLATE'];
        
        final entropy = RustLib.instance.api.crateApiSimpleCalculateEntropy(
          candidateWord: candidate,
          remainingWords: remaining,
        );
        
        expect(entropy, isA<double>());
        expect(entropy, greaterThanOrEqualTo(0.0));
      });

      test('should simulate guess patterns correctly', () async {
        final pattern1 = RustLib.instance.api.crateApiSimpleSimulateGuessPattern(
          guess: 'CRANE',
          target: 'CRATE',
        );
        expect(pattern1, equals('GGGXG')); // C, R, A match, N doesn't, E matches
        
        final pattern2 = RustLib.instance.api.crateApiSimpleSimulateGuessPattern(
          guess: 'CRANE',
          target: 'SLATE',
        );
        expect(pattern2, equals('XXGXG')); // Only A and E match
      });

      test('should filter words based on guess results', () async {
        final words = ['CRANE', 'SLATE', 'CRATE'];
        final guessResults = [
          ('CRANE', ['G', 'Y', 'X', 'X', 'G']), // C=Green, R=Yellow, A=Gray, N=Gray, E=Green
        ];
        
        final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
          words: words,
          guessResults: guessResults,
        );
        
        expect(filtered, isA<List<String>>());
        expect(filtered.length, lessThan(words.length));
      });

      test('should get intelligent guess', () async {
        final allWords = ['CRANE', 'SLATE', 'CRATE'];
        final remaining = ['CRANE', 'SLATE'];
        final guessResults = <(String, List<String>)>[];
        
        final bestGuess = RustLib.instance.api.crateApiSimpleGetIntelligentGuess(
          allWords: allWords,
          remainingWords: remaining,
          guessResults: guessResults,
        );
        
        expect(bestGuess, isA<String?>());
        expect(bestGuess, isNotNull);
        expect(remaining, contains(bestGuess));
      });
    });

    group('Advanced Algorithm Tests', () {
      test('should handle empty remaining words', () async {
        final allWords = ['CRANE', 'SLATE', 'CRATE'];
        final remaining = <String>[];
        final guessResults = <(String, List<String>)>[];
        
        final bestGuess = RustLib.instance.api.crateApiSimpleGetIntelligentGuess(
          allWords: allWords,
          remainingWords: remaining,
          guessResults: guessResults,
        );
        
        expect(bestGuess, isNull);
      });

      test('should handle single remaining word', () async {
        final allWords = ['CRANE', 'SLATE', 'CRATE'];
        final remaining = ['CRANE'];
        final guessResults = <(String, List<String>)>[];
        
        final bestGuess = RustLib.instance.api.crateApiSimpleGetIntelligentGuess(
          allWords: allWords,
          remainingWords: remaining,
          guessResults: guessResults,
        );
        
        expect(bestGuess, equals('CRANE'));
      });

      test('should handle complex guess results', () async {
        final words = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE'];
        final guessResults = [
          ('CRANE', ['G', 'Y', 'X', 'X', 'G']), // C=Green, R=Yellow, A=Gray, N=Gray, E=Green
          ('SLATE', ['X', 'X', 'G', 'X', 'G']), // S=Gray, L=Gray, A=Green, T=Gray, E=Green
        ];
        
        final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
          words: words,
          guessResults: guessResults,
        );
        
        expect(filtered, isA<List<String>>());
        // Should filter out words that don't match both patterns
        expect(filtered.length, lessThan(words.length));
      });
    });

    group('Performance Tests', () {
      test('should complete entropy calculation quickly', () async {
        final candidate = 'CRANE';
        final remaining = List.generate(100, (i) => 'WORD$i');
        
        final stopwatch = Stopwatch()..start();
        final entropy = RustLib.instance.api.crateApiSimpleCalculateEntropy(
          candidateWord: candidate,
          remainingWords: remaining,
        );
        stopwatch.stop();
        
        expect(entropy, isA<double>());
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
      });

      test('should complete intelligent guess quickly', () async {
        final allWords = List.generate(50, (i) => 'WORD$i');
        final remaining = allWords.take(10).toList();
        final guessResults = <(String, List<String>)>[];
        
        final stopwatch = Stopwatch()..start();
        final bestGuess = RustLib.instance.api.crateApiSimpleGetIntelligentGuess(
          allWords: allWords,
          remainingWords: remaining,
          guessResults: guessResults,
        );
        stopwatch.stop();
        
        expect(bestGuess, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Target: < 200ms
      });
    });

    group('Edge Cases', () {
      test('should handle invalid patterns gracefully', () async {
        final words = ['CRANE', 'SLATE', 'CRATE'];
        final guessResults = [
          ('CRANE', ['INVALID', 'Y', 'X', 'X', 'G']), // Invalid pattern should default to Gray
        ];
        
        final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
          words: words,
          guessResults: guessResults,
        );
        
        expect(filtered, isA<List<String>>());
        // Should still work, treating invalid patterns as Gray
      });

      test('should handle empty word lists', () async {
        final words = <String>[];
        final guessResults = <(String, List<String>)>[];
        
        final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
          words: words,
          guessResults: guessResults,
        );
        
        expect(filtered, isEmpty);
      });
    });

    group('Integration Tests', () {
      test('should complete full game simulation', () async {
        // Simulate a complete Wordle game
        final allWords = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE'];
        var remaining = allWords;
        final guessResults = <(String, List<String>)>[];
        
        // First guess: CRANE
        final firstGuess = RustLib.instance.api.crateApiSimpleGetIntelligentGuess(
          allWords: allWords,
          remainingWords: remaining,
          guessResults: guessResults,
        );
        expect(firstGuess, isNotNull);
        
        // Simulate result: CRANE -> GGYXY (C=Green, R=Yellow, A=Gray, N=Gray, E=Yellow)
        final firstResult = (firstGuess!, ['G', 'Y', 'X', 'X', 'Y']);
        guessResults.add(firstResult);
        
        // Filter remaining words
        remaining = RustLib.instance.api.crateApiSimpleFilterWords(
          words: remaining,
          guessResults: guessResults,
        );
        
        expect(remaining, isNotEmpty);
        expect(remaining.length, lessThan(allWords.length));
        
        // Second guess
        final secondGuess = RustLib.instance.api.crateApiSimpleGetIntelligentGuess(
          allWords: allWords,
          remainingWords: remaining,
          guessResults: guessResults,
        );
        expect(secondGuess, isNotNull);
        expect(remaining, contains(secondGuess));
      });
    });
  });
}
