import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Debug Integration Tests', () {
    setUpAll(RustLib.init);

    test('debug integration test pattern', () async {
      final allWords = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE'];
      final guessResults = [
        ('CRANE', ['G', 'G', 'G', 'X', 'X']), // C=Green, R=Green, A=Green,
        // N=Gray, E=Gray
      ];
      
      DebugLogger.info('Original words: $allWords', tag: 'Debug');
      DebugLogger.info('Guess results: $guessResults', tag: 'Debug');
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: allWords,
        guessResults: guessResults,
      );
      
      DebugLogger.info('Filtered words: $filtered', tag: 'Debug');
      DebugLogger.info('Filtered count: ${filtered.length}', tag: 'Debug');
      
      // Let's analyze each word manually
      for (final word in allWords) {
        DebugLogger.info('Analyzing word: $word', tag: 'Debug');
        // C should be in position 1 (green)
        final hasCInPos1 = word.length > 0 && word[0] == 'C';
        DebugLogger.info('  Has C in position 1: $hasCInPos1', tag: 'Debug');
        
        // R should be in position 2 (green)
        final hasRInPos2 = word.length > 1 && word[1] == 'R';
        DebugLogger.info('  Has R in position 2: $hasRInPos2', tag: 'Debug');
        
        // A should be in position 3 (green)
        final hasAInPos3 = word.length > 2 && word[2] == 'A';
        DebugLogger.info('  Has A in position 3: $hasAInPos3', tag: 'Debug');
        
        // N should NOT be in the word (gray)
        final hasN = word.contains('N');
        DebugLogger.info('  Has N: $hasN', tag: 'Debug');
        
        // E should NOT be in the word (gray)
        final hasE = word.contains('E');
        DebugLogger.info('  Has E: $hasE', tag: 'Debug');
        
        final shouldMatch = hasCInPos1 && hasRInPos2 && hasAInPos3 && !hasN &&
            !hasE;
        DebugLogger.info('  Should match: $shouldMatch', tag: 'Debug');
        DebugLogger.info('', tag: 'Debug');
      }
    });
  });
}
