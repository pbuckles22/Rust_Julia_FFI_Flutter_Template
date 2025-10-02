import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Debug Partial Gray', () {
    setUpAll(() {
      RustLib.init();
    });

    test('debug GXXXX pattern', () async {
      // Pattern: GXXXX (C=Green, R,A,N,E=Gray) for guess "CRANE"
      // Should return words that start with 'C' but don't contain R, A, N, E
      final words = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE', 'CHASE', 'CLOTH', 'CLOUD'];
      final guessResults = [
        ('CRANE', ['G', 'X', 'X', 'X', 'X']), // C=Green, R,A,N,E=Gray
      ];
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: guessResults,
      );
      
      print('Words: $words');
      print('Pattern: GXXXX (C=Green, R,A,N,E=Gray)');
      print('Filtered: $filtered');
      print('');
      print('Analysis:');
      print('- CRANE: starts with C, but contains R,A,N,E → should be rejected');
      print('- SLATE: doesn\'t start with C → should be rejected');
      print('- CRATE: starts with C, but contains R,A,E → should be rejected');
      print('- PLATE: doesn\'t start with C → should be rejected');
      print('- GRATE: doesn\'t start with C → should be rejected');
      print('- TRACE: doesn\'t start with C → should be rejected');
      print('- CHASE: starts with C, but contains A,E → should be rejected');
      print('- CLOTH: starts with C, no R,A,N,E → should be accepted');
      print('- CLOUD: starts with C, no R,A,N,E → should be accepted');
      print('');
      print('Expected: [CLOTH, CLOUD]');
      print('Actual: $filtered');
      
      // Should return CLOTH and CLOUD
      expect(filtered, equals(['CLOTH', 'CLOUD']));
    });
  });
}
