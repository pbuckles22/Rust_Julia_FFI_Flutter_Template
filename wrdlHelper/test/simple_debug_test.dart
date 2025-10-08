import 'package:flutter_test/flutter_test.dart';

import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Simple Debug Tests', () {
    setUpAll(() async {
      await FfiService.initialize();
    });

    test('test basic word filtering', () async {
      // Test with just two words
      final words = ['CRANE', 'SLATE'];
      
      // Test 1: All green for CRANE should return only CRANE
      final allGreenResults = [
        ('CRANE', ['G', 'G', 'G', 'G', 'G']),
      ];
      
      final allGreenFiltered = FfiService.filterWords(
        words,
        allGreenResults,
      );
      
      DebugLogger.debug('All green for CRANE: $allGreenFiltered');
      expect(allGreenFiltered, equals(['CRANE']));
      
      // Test 2: All gray for CRANE should return empty (SLATE contains A and E which are gray)
      final allGrayResults = [
        ('CRANE', ['X', 'X', 'X', 'X', 'X']),
      ];
      
      final allGrayFiltered = FfiService.filterWords(
        words,
        allGrayResults,
      );
      
      DebugLogger.debug('All gray for CRANE: $allGrayFiltered');
      expect(allGrayFiltered, isEmpty); // SLATE contains A and E which are gray in CRANE
      
      // Test 3: Better example - guess "CRANE" with only C gray, others green
      final partialGrayResults = [
        ('CRANE', ['X', 'G', 'G', 'G', 'G']), // Only C is gray, RANE are green
      ];
      
      final partialGrayFiltered = FfiService.filterWords(
        words,
        partialGrayResults,
      );
      
      DebugLogger.debug('Partial gray for CRANE: $partialGrayFiltered');
      expect(partialGrayFiltered, isEmpty); // No word can have RANE in positions 2-5 and not have C
    });
  });
}
