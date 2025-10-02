import 'package:flutter_test/flutter_test.dart';
import 'package:my_working_ffi_app/src/rust/frb_generated.dart';

void main() {
  group('Simple Debug Tests', () {
    setUpAll(() {
      RustLib.init();
    });

    test('test basic word filtering', () async {
      // Test with just two words
      final words = ['CRANE', 'SLATE'];
      
      // Test 1: All green for CRANE should return only CRANE
      final allGreenResults = [
        ('CRANE', ['G', 'G', 'G', 'G', 'G']),
      ];
      
      final allGreenFiltered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: allGreenResults,
      );
      
      print('All green for CRANE: $allGreenFiltered');
      expect(allGreenFiltered, equals(['CRANE']));
      
      // Test 2: All gray for CRANE should return empty (SLATE contains A and E which are gray)
      final allGrayResults = [
        ('CRANE', ['X', 'X', 'X', 'X', 'X']),
      ];
      
      final allGrayFiltered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: allGrayResults,
      );
      
      print('All gray for CRANE: $allGrayFiltered');
      expect(allGrayFiltered, isEmpty); // SLATE contains A and E which are gray in CRANE
      
      // Test 3: Better example - guess "CRANE" with only C gray, others green
      final partialGrayResults = [
        ('CRANE', ['X', 'G', 'G', 'G', 'G']), // Only C is gray, RANE are green
      ];
      
      final partialGrayFiltered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: partialGrayResults,
      );
      
      print('Partial gray for CRANE: $partialGrayFiltered');
      expect(partialGrayFiltered, isEmpty); // No word can have RANE in positions 2-5 and not have C
    });
  });
}
