import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Debug Filter Tests', () {
    setUpAll(RustLib.init);

    test('debug word filtering', () async {
      final words = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE'];
      final guessResults = [
        ('CRANE', ['G', 'Y', 'X', 'X', 'Y']), // C=Green, R=Yellow, A=Gray, N=Gray, E=Yellow
      ];
      
      print('Original words: $words');
      print('Guess results: $guessResults');
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: guessResults,
      );
      
      print('Filtered words: $filtered');
      print('Filtered count: ${filtered.length}');
      
      // Let's test with a pattern that should definitely work
      final simpleGuessResults = [
        ('CRANE', ['G', 'G', 'G', 'G', 'G']), // All green (should match CRANE exactly)
      ];
      
      final simpleFiltered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: simpleGuessResults,
      );
      
      print('All green filtered words: $simpleFiltered');
      print('All green filtered count: ${simpleFiltered.length}');
      
      // Test with no restrictions
      final noRestrictionsResults = [
        ('CRANE', ['X', 'X', 'X', 'X', 'X']), // All gray (should reject CRANE but keep others)
      ];
      
      final noRestrictionsFiltered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: noRestrictionsResults,
      );
      
      print('No restrictions filtered words: $noRestrictionsFiltered');
      print('No restrictions filtered count: ${noRestrictionsFiltered.length}');
    });
  });
}
