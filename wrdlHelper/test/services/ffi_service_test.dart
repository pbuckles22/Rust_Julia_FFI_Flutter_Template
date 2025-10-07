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

    group('getAnswerWords', () {
      test('should return the correct number of answer words', () async {
        // MICRO-STEP 3: Test FfiService.getAnswerWords()
        // Verify it returns the correct number of answer words
        
        final answerWords = FfiService.getAnswerWords();
        
        expect(answerWords, isNotEmpty, reason: 'Answer words should not be empty');
        expect(answerWords.length, equals(1273), reason: 'Should have 1273 answer words (algorithm-testing list)');
        expect(answerWords.first, isA<String>(), reason: 'Answer words should be strings');
        expect(answerWords.first.length, equals(5), reason: 'Answer words should be 5 letters');
      });
    });
  });
}
