import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Debug Detailed', () {
    setUpAll(RustLib.init);

    test('debug step by step', () async {
      // Test 1: All green (should work)
      DebugLogger.info('=== Test 1: All Green ===', tag: 'Debug');
      final words1 = ['CRANE', 'SLATE'];
      final pattern1 = [('CRANE', ['G', 'G', 'G', 'G', 'G'])];
      final filtered1 = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words1,
        guessResults: pattern1,
      );
      DebugLogger.info('Words: $words1', tag: 'Debug');
      DebugLogger.info('Pattern: GGGGG', tag: 'Debug');
      DebugLogger.info('Filtered: $filtered1', tag: 'Debug');
      DebugLogger.info('Expected: [CRANE]', tag: 'Debug');
      DebugLogger.info('', tag: 'Debug');

      // Test 2: All gray (should return SLATE)
      DebugLogger.info('=== Test 2: All Gray ===', tag: 'Debug');
      final words2 = ['CRANE', 'SLATE'];
      final pattern2 = [('CRANE', ['X', 'X', 'X', 'X', 'X'])];
      final filtered2 = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words2,
        guessResults: pattern2,
      );
      DebugLogger.info('Words: $words2', tag: 'Debug');
      DebugLogger.info('Pattern: XXXXX', tag: 'Debug');
      DebugLogger.info('Filtered: $filtered2', tag: 'Debug');
      DebugLogger.info('Expected: [SLATE]', tag: 'Debug');
      DebugLogger.info('', tag: 'Debug');

      // Test 3: One green (should return words starting with C)
      DebugLogger.info('=== Test 3: One Green ===', tag: 'Debug');
      final words3 = ['CRANE', 'SLATE', 'CHASE'];
      final pattern3 = [('CRANE', ['G', 'X', 'X', 'X', 'X'])];
      final filtered3 = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words3,
        guessResults: pattern3,
      );
      DebugLogger.info('Words: $words3', tag: 'Debug');
      DebugLogger.info('Pattern: GXXXX', tag: 'Debug');
      DebugLogger.info('Filtered: $filtered3', tag: 'Debug');
      DebugLogger.info('Expected: [CHASE] (starts with C, no R,A,N,E)', tag: 'Debug');
      DebugLogger.info('', tag: 'Debug');

      // Test 4: Pattern simulation (should work)
      DebugLogger.info('=== Test 4: Pattern Simulation ===', tag: 'Debug');
      final pattern4 = RustLib.instance.api.crateApiSimpleSimulateGuessPattern(
        guess: 'CRANE',
        target: 'SLATE',
      );
      DebugLogger.info('Guess: CRANE, Target: SLATE', tag: 'Debug');
      DebugLogger.info('Pattern: $pattern4', tag: 'Debug');
      DebugLogger.info('Expected: XXGXG', tag: 'Debug');
      DebugLogger.info('', tag: 'Debug');

      // Test 5: Entropy calculation (should work)
      DebugLogger.info('=== Test 5: Entropy Calculation ===', tag: 'Debug');
      final entropy = RustLib.instance.api.crateApiSimpleCalculateEntropy(
        candidateWord: 'CRANE',
        remainingWords: ['CRANE', 'SLATE'],
      );
      DebugLogger.info('Candidate: CRANE, Remaining: [CRANE, SLATE]', tag: 'Debug');
      DebugLogger.info('Entropy: $entropy', tag: 'Debug');
      DebugLogger.info('Expected: 1.0 (perfect split)', tag: 'Debug');
    });
  });
}
