import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/service_locator.dart';

void main() {
  group('FfiService Tests', () {
    setUpAll(() async {
      // Initialize services for testing
      await setupTestServices();
    });

    group('isValidWord', () {
      test('should return true for valid words', () async {
        // MICRO-STEP 1: Test FfiService.isValidWord() with a single test case
        // Verify it returns true for valid words
        
        // Test with a common valid word
        final result = FfiService.isValidWord('SLATE');
        
        expect(result, isTrue, reason: 'SLATE should be a valid word');
      });

      test('should return false for invalid words', () async {
        // MICRO-STEP 2: Test FfiService.isValidWord() with invalid words
        // Verify it returns false for invalid words
        
        // Test with an invalid word
        final result = FfiService.isValidWord('XXXXX');
        
        expect(result, isFalse, reason: 'XXXXX should not be a valid word');
      });
    });
  });
}
