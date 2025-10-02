import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Debug Detailed', () {
    setUpAll(() {
      RustLib.init();
    });

    test('debug step by step', () async {
      // Test 1: All green (should work)
      print('=== Test 1: All Green ===');
      final words1 = ['CRANE', 'SLATE'];
      final pattern1 = [('CRANE', ['G', 'G', 'G', 'G', 'G'])];
      final filtered1 = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words1,
        guessResults: pattern1,
      );
      print('Words: $words1');
      print('Pattern: GGGGG');
      print('Filtered: $filtered1');
      print('Expected: [CRANE]');
      print('');

      // Test 2: All gray (should return SLATE)
      print('=== Test 2: All Gray ===');
      final words2 = ['CRANE', 'SLATE'];
      final pattern2 = [('CRANE', ['X', 'X', 'X', 'X', 'X'])];
      final filtered2 = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words2,
        guessResults: pattern2,
      );
      print('Words: $words2');
      print('Pattern: XXXXX');
      print('Filtered: $filtered2');
      print('Expected: [SLATE]');
      print('');

      // Test 3: One green (should return words starting with C)
      print('=== Test 3: One Green ===');
      final words3 = ['CRANE', 'SLATE', 'CHASE'];
      final pattern3 = [('CRANE', ['G', 'X', 'X', 'X', 'X'])];
      final filtered3 = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words3,
        guessResults: pattern3,
      );
      print('Words: $words3');
      print('Pattern: GXXXX');
      print('Filtered: $filtered3');
      print('Expected: [CHASE] (starts with C, no R,A,N,E)');
      print('');

      // Test 4: Pattern simulation (should work)
      print('=== Test 4: Pattern Simulation ===');
      final pattern4 = RustLib.instance.api.crateApiSimpleSimulateGuessPattern(
        guess: 'CRANE',
        target: 'SLATE',
      );
      print('Guess: CRANE, Target: SLATE');
      print('Pattern: $pattern4');
      print('Expected: XXGXG');
      print('');

      // Test 5: Entropy calculation (should work)
      print('=== Test 5: Entropy Calculation ===');
      final entropy = RustLib.instance.api.crateApiSimpleCalculateEntropy(
        candidateWord: 'CRANE',
        remainingWords: ['CRANE', 'SLATE'],
      );
      print('Candidate: CRANE, Remaining: [CRANE, SLATE]');
      print('Entropy: $entropy');
      print('Expected: 1.0 (perfect split)');
    });
  });
}
