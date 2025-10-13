import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Debug Partial Gray', () {
    setUpAll(() {
      RustLib.init();
    });

    test('debug GXXXX pattern', () async {
      // Pattern: GXXXX (C=Green, R,A,N,E=Gray) for guess "CRANE"
      // Should return words that start with 'C' but don't contain R, A, N, E
      final words = [
        'CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE', 'CHASE',
        'CLOTH', 'CLOUD'
      ];
      final guessResults = [
        ('CRANE', ['G', 'X', 'X', 'X', 'X']), // C=Green, R,A,N,E=Gray
      ];
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: guessResults,
      );
      
      DebugLogger.info('Words: $words', tag: 'Debug');
      DebugLogger.info('Pattern: GXXXX (C=Green, R,A,N,E=Gray)', tag: 'Debug');
      DebugLogger.info('Filtered: $filtered', tag: 'Debug');
      DebugLogger.info('', tag: 'Debug');
      DebugLogger.info('Analysis:', tag: 'Debug');
      DebugLogger.info('- CRANE: starts with C, but contains R,A,N,E → should be '
          'rejected', tag: 'Debug');
      DebugLogger.info('- SLATE: doesn\'t start with C → should be rejected', tag: 'Debug');
      DebugLogger.info('- CRATE: starts with C, but contains R,A,E → should be '
          'rejected', tag: 'Debug');
      DebugLogger.info('- PLATE: doesn\'t start with C → should be rejected', tag: 'Debug');
      DebugLogger.info('- GRATE: doesn\'t start with C → should be rejected', tag: 'Debug');
      DebugLogger.info('- TRACE: doesn\'t start with C → should be rejected', tag: 'Debug');
      DebugLogger.info('- CHASE: starts with C, but contains A,E → should be rejected', tag: 'Debug');
      DebugLogger.info('- CLOTH: starts with C, no R,A,N,E → should be accepted', tag: 'Debug');
      DebugLogger.info('- CLOUD: starts with C, no R,A,N,E → should be accepted', tag: 'Debug');
      DebugLogger.info('', tag: 'Debug');
      DebugLogger.info('Expected: [CLOTH, CLOUD]', tag: 'Debug');
      DebugLogger.info('Actual: $filtered', tag: 'Debug');
      
      // Should return CLOTH and CLOUD
      expect(filtered, equals(['CLOTH', 'CLOUD']));
    });
  });
}
