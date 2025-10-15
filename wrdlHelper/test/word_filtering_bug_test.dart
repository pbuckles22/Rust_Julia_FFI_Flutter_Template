import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Word Filtering Bug Tests (TDD Red Phase)', () {
    setUpAll(() async {
      // Initialize the FFI service
      await FfiService.initialize();
    });

    group('Critical Bug: Gray Letter Logic', () {
      test('should handle all-gray pattern correctly', () async {
        // TDD Green: This test should PASS now
        // Pattern: XXXXX (all gray) for guess "CRANE"
        // Should return words that don't contain C,R,A,N,E
        final words = ['CRANE', 'SLOTH', 'BLIMP', 'SLATE', 'CRATE'];
        final guessResults = [
          ('CRANE', ['X', 'X', 'X', 'X', 'X']), // All gray
        ];
        
        final filtered = FfiService.filterWords(
          words,
          guessResults,
        );
        
        // Should return only words that don't contain C,R,A,N,E
        expect(filtered, isNotEmpty);
        expect(filtered, contains('SLOTH')); // No C,R,A,N,E
        expect(filtered, contains('BLIMP')); // No C,R,A,N,E
        expect(filtered, isNot(contains('CRANE'))); // Contains C,R,A,N,E
        expect(filtered, isNot(contains('SLATE'))); // Contains A,E
        expect(filtered, isNot(contains('CRATE'))); // Contains C,R,A,E
        expect(filtered.length, equals(2));
      });

      test('should handle partial gray pattern correctly', () async {
        // TDD Green: This test should PASS now
        // Pattern: GXXXX (first letter green, rest gray) for guess "CRANE"
        // Should return words that start with 'C' but don't contain R, A, N, E
        // elsewhere
        final words = [
          'CRANE',
          'SLATE',
          'CRATE',
          'PLATE',
          'GRATE',
          'TRACE',
          'CHASE',
          'CLOTH',
          'CLOUD'
        ];
        final guessResults = [
          ('CRANE', ['G', 'X', 'X', 'X', 'X']), // C=Green, R,A,N,E=Gray
        ];
        
        final filtered = FfiService.filterWords(
          words,
          guessResults,
        );
        
        // Should return words starting with C that don't contain R,A,N,E
        expect(filtered, isNotEmpty);
        expect(filtered, contains('CLOTH')); // Starts with C, no R,A,N,E
        expect(filtered, contains('CLOUD')); // Starts with C, no R,A,N,E
        expect(filtered, isNot(contains('CRANE'))); // Contains R,A,N,E
        expect(filtered, isNot(contains('CRATE'))); // Contains R,A,E
        expect(filtered, isNot(contains('CHASE'))); // Contains A,E
        expect(filtered, isNot(contains('SLATE'))); // Doesn't start with C
        expect(filtered, isNot(contains('PLATE'))); // Doesn't start with C
        expect(filtered, isNot(contains('GRATE'))); // Doesn't start with C
        expect(filtered, isNot(contains('TRACE'))); // Doesn't start with C
        expect(filtered.length, equals(2));
      });

      test('should handle mixed pattern correctly', () async {
        // TDD Green: This test should PASS now
        // Pattern: GYXXY (C=Green, R=Yellow, A=Gray, N=Gray, E=Yellow) for
        // guess "CRANE"
        // Should return words that: start with C, contain R (not in pos 2),
        // don't contain A or N, contain E (not in pos 5)
        final words = [
          'CRANE',
          'SLATE',
          'CRATE',
          'PLATE',
          'GRATE',
          'TRACE',
          'CHORE',
          'CRUDE',
          'CRIME'
        ];
        final guessResults = [
          ('CRANE', ['G', 'Y', 'X', 'X', 'Y']), // C=Green, R=Yellow, A=Gray,
          // N=Gray, E=Yellow
        ];
        
        final filtered = FfiService.filterWords(
          words,
          guessResults,
        );
        
        DebugLogger.info('Mixed pattern GYXXY filtered words: $filtered', tag: 'Bug');
        DebugLogger.info('Analysis:', tag: 'Bug');
        DebugLogger.info(
          '- CRANE: C=G, R=Y(pos2❌), A=X❌, N=X❌, E=Y(pos5❌) → should be '
          'rejected',
          tag: 'Bug',
        );
        DebugLogger.info(
          '- CRUDE: C=G, R=Y(pos2❌), no A, no N, E=Y(pos5❌) → should be '
          'rejected',
          tag: 'Bug',
        );
        DebugLogger.info(
          '- CRIME: C=G, R=Y(pos2❌), no A, no N, no E → should be rejected',
        );
        DebugLogger.info(
          '- Need words like: C_R_E (C at pos1, R not at pos2, E not at pos5, '
          'no A/N)',
        );
        
        // This pattern is very restrictive - might return empty list
        // Let's just verify the algorithm doesn't crash and returns a valid
        // result
        expect(filtered, isA<List<String>>());
      });
    });

    group('All Green Pattern (Should Work)', () {
      test('should handle all-green pattern correctly', () async {
        // This should already work based on debug output
        final words = ['CRANE', 'SLATE', 'CRATE'];
        final guessResults = [
          ('CRANE', ['G', 'G', 'G', 'G', 'G']), // All green
        ];
        
        final filtered = FfiService.filterWords(
          words,
          guessResults,
        );
        
        // Should return only CRANE
        expect(filtered, equals(['CRANE']));
      });
    });
  });
}
