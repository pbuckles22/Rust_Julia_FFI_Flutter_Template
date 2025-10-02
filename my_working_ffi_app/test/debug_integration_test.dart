import 'package:flutter_test/flutter_test.dart';
import 'package:my_working_ffi_app/src/rust/frb_generated.dart';

void main() {
  group('Debug Integration Tests', () {
    setUpAll(() {
      RustLib.init();
    });

    test('debug integration test pattern', () async {
      final allWords = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE'];
      final guessResults = [
        ('CRANE', ['G', 'G', 'G', 'X', 'X']), // C=Green, R=Green, A=Green, N=Gray, E=Gray
      ];
      
      print('Original words: $allWords');
      print('Guess results: $guessResults');
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: allWords,
        guessResults: guessResults,
      );
      
      print('Filtered words: $filtered');
      print('Filtered count: ${filtered.length}');
      
      // Let's analyze each word manually
      for (final word in allWords) {
        print('Analyzing word: $word');
        // C should be in position 1 (green)
        final hasCInPos1 = word.length > 0 && word[0] == 'C';
        print('  Has C in position 1: $hasCInPos1');
        
        // R should be in position 2 (green)
        final hasRInPos2 = word.length > 1 && word[1] == 'R';
        print('  Has R in position 2: $hasRInPos2');
        
        // A should be in position 3 (green)
        final hasAInPos3 = word.length > 2 && word[2] == 'A';
        print('  Has A in position 3: $hasAInPos3');
        
        // N should NOT be in the word (gray)
        final hasN = word.contains('N');
        print('  Has N: $hasN');
        
        // E should NOT be in the word (gray)
        final hasE = word.contains('E');
        print('  Has E: $hasE');
        
        final shouldMatch = hasCInPos1 && hasRInPos2 && hasAInPos3 && !hasN && !hasE;
        print('  Should match: $shouldMatch');
        print('');
      }
    });
  });
}
