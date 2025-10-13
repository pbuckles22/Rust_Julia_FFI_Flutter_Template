import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Debug Simple Case', () {
    setUpAll(RustLib.init);

    test('debug all gray case', () async {
      final words = ['CRANE', 'SLOTH', 'BLIMP'];
      final guessResults = [
        ('CRANE', ['X', 'X', 'X', 'X', 'X']), // All gray
      ];
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: guessResults,
      );
      
      DebugLogger.info('Words: $words', tag: 'Debug');
      DebugLogger.info('Pattern: XXXXX', tag: 'Debug');
      DebugLogger.info('Filtered: $filtered', tag: 'Debug');
      
      // Should return SLOTH and BLIMP (don't contain C,R,A,N,E)
      expect(filtered, equals(['SLOTH', 'BLIMP']));
    });
  });
}
