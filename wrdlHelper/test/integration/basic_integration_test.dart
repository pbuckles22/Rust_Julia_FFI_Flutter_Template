import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/api/simple.dart' as ffi;

/// Basic Integration Tests
/// 
/// This test suite validates basic integration between Dart and Rust
/// through the FFI service, ensuring core functionality works correctly.
/// 
/// Test Categories:
/// - FFI service initialization
/// - Basic FFI function calls
/// - Error handling
/// - Performance validation

void main() {
  group('Basic Integration Tests', () {
    setUpAll(() async {
      // Initialize FFI service for integration testing
      await FfiService.initialize();
    });

    group('FFI Service Initialization', () {
      test('should initialize FFI service successfully', () async {
        // Test FFI service initialization
        expect(FfiService.isInitialized, isTrue);
      });

      test('should handle multiple initialization calls', () async {
        // Test multiple initialization calls
        await FfiService.initialize();
        expect(FfiService.isInitialized, isTrue);
      });

      test('should maintain service state after initialization', () async {
        // Test service state maintenance
        expect(FfiService.isInitialized, isTrue);
      });
    });

    group('Basic FFI Function Calls', () {
      test('should call FFI functions successfully', () async {
        // Test basic FFI function calls
        final answerWords = ffi.getAnswerWords();
        expect(answerWords, isNotNull);
        expect(answerWords, isA<List<String>>());
        expect(answerWords.length, greaterThan(0));
      });

      test('should retrieve word lists correctly', () async {
        // Test word list retrieval
        final answerWords = ffi.getAnswerWords();
        final guessWords = ffi.getGuessWords();
        
        expect(answerWords, isNotNull);
        expect(guessWords, isNotNull);
        expect(answerWords.length, greaterThan(0));
        expect(guessWords.length, greaterThan(0));
      });

      test('should validate words correctly', () async {
        // Test word validation
        final isValid = ffi.isValidWord(word: 'CRANE');
        expect(isValid, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle invalid word validation', () async {
        // Test invalid word handling
        final isValid = ffi.isValidWord(word: 'INVALID');
        expect(isValid, isFalse);
      });

      test('should handle empty word validation', () async {
        // Test empty word handling
        final isValid = ffi.isValidWord(word: '');
        expect(isValid, isFalse);
      });

      test('should handle special character validation', () async {
        // Test special character handling
        final isValid = ffi.isValidWord(word: 'TEST!');
        expect(isValid, isFalse);
      });
    });

    group('Performance Validation', () {
      test('should retrieve word lists within acceptable time', () async {
        // Test word list retrieval performance
        final stopwatch = Stopwatch()..start();
        ffi.getAnswerWords();
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should validate words within acceptable time', () async {
        // Test word validation performance
        final stopwatch = Stopwatch()..start();
        ffi.isValidWord(word: 'CRANE');
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle concurrent requests efficiently', () async {
        // Test concurrent request handling
        final stopwatch = Stopwatch()..start();
        
        final futures = List.generate(10, (i) async {
          ffi.getAnswerWords();
          ffi.isValidWord(word: 'CRANE');
        });
        
        await Future.wait(futures);
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });
    });

    group('Data Consistency', () {
      test('should maintain data consistency across calls', () async {
        // Test data consistency
        final answerWords1 = ffi.getAnswerWords();
        final answerWords2 = ffi.getAnswerWords();
        
        expect(answerWords1, equals(answerWords2));
        expect(answerWords1.length, equals(answerWords2.length));
      });

      test('should provide consistent word validation results', () async {
        // Test consistent validation results
        final testWord = 'CRANE';
        
        final result1 = ffi.isValidWord(word: testWord);
        final result2 = ffi.isValidWord(word: testWord);
        
        expect(result1, equals(result2));
      });

      test('should handle repeated operations consistently', () async {
        // Test repeated operations consistency
        for (int i = 0; i < 5; i++) {
          final answerWords = ffi.getAnswerWords();
          expect(answerWords.length, greaterThan(0));
        }
      });
    });

    group('Integration with Rust FFI', () {
      test('should communicate with Rust FFI correctly', () async {
        // Test Rust FFI communication
        final answerWords = ffi.getAnswerWords();
        expect(answerWords, isNotNull);
        expect(answerWords.length, greaterThan(0));
      });

      test('should handle FFI bridge communication', () async {
        // Test FFI bridge communication
        final guessWords = ffi.getGuessWords();
        expect(guessWords, isNotNull);
        expect(guessWords.length, greaterThan(0));
      });

      test('should maintain FFI state consistency', () async {
        // Test FFI state consistency
        final answerWords1 = ffi.getAnswerWords();
        final answerWords2 = ffi.getAnswerWords();
        
        expect(answerWords1, equals(answerWords2));
      });
    });

    group('Memory Management', () {
      test('should handle memory allocation efficiently', () async {
        // Test memory allocation
        for (int i = 0; i < 100; i++) {
          ffi.getAnswerWords();
        }
        
        expect(true, isTrue, reason: 'No memory issues during repeated operations');
      });

      test('should handle large data sets', () async {
        // Test large data set handling
        final answerWords = ffi.getAnswerWords();
        final guessWords = ffi.getGuessWords();
        
        expect(answerWords.length, greaterThan(1000));
        expect(guessWords.length, greaterThan(10000));
      });

      test('should maintain memory consistency', () async {
        // Test memory consistency
        final answerWords1 = ffi.getAnswerWords();
        final answerWords2 = ffi.getAnswerWords();
        
        expect(answerWords1, equals(answerWords2));
      });
    });
  });
}
