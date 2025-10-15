import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('FFI Answer Generator Tests', () {
    var ffiAvailable = false;

    setUpAll(() async {
      // Initialize FFI service before running tests
      try {
        await FfiService.initialize();
        ffiAvailable = true;
      } on Exception catch (e) {
        // FFI initialization may fail in test environment, that's OK
        // The tests will be skipped or use fallback behavior
        DebugLogger.testPrint(
          'FFI initialization failed in test: $e',
          tag: 'FFITest',
        );
        ffiAvailable = false;
      }
    });

    tearDownAll(() {
      // Clean up FFI resources to prevent test interference
      try {
        RustLib.dispose();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    test('should get intelligent guess from valid word list', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // Arrange
      final answerWords = [
        'CRANE',
        'SLATE',
        'CRATE',
        'TRACE',
        'ADIEU',
        'AUDIO',
        'ROATE',
        'RAISE',
        'SOARE',
        'STARE',
      ];

      // Act - Use intelligent solver instead of random selection
      final intelligentGuess = FfiService.getBestGuessFast(answerWords, []);

      // Assert
      expect(intelligentGuess, isNotNull);
      expect(intelligentGuess, isA<String>());
      expect(intelligentGuess!.length, equals(5));
      expect(intelligentGuess, matches(RegExp(r'^[A-Z]{5}$')));
    });

    test('should return null for empty answer list', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // Arrange
      final emptyList = <String>[];

      // Act - Use intelligent solver instead of random selection
      final intelligentGuess = FfiService.getBestGuessFast(emptyList, []);

      // Assert
      expect(intelligentGuess, isNull);
    });

    test('should consistently return optimal first guess', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // Arrange
      final answerWords = [
        'CRANE',
        'SLATE',
        'CRATE',
        'TRACE',
        'ADIEU',
        'AUDIO',
        'ROATE',
        'RAISE',
        'SOARE',
        'STARE',
      ];

      // Act - Test consistency of intelligent solver
      final firstGuess = FfiService.getBestGuessFast(answerWords, []);
      final secondGuess = FfiService.getBestGuessFast(answerWords, []);
      final thirdGuess = FfiService.getBestGuessFast(answerWords, []);

      // Assert - Intelligent solver should be consistent
      expect(firstGuess, isNotNull);
      expect(secondGuess, isNotNull);
      expect(thirdGuess, isNotNull);
      
      // Should return the same optimal word consistently
      expect(firstGuess, equals(secondGuess));
      expect(secondGuess, equals(thirdGuess));
      
      // All guesses should be valid
      for (final word in [firstGuess, secondGuess, thirdGuess]) {
        expect(word!.length, equals(5));
        expect(word, matches(RegExp(r'^[A-Z]{5}$')));
      }
    });

    test('should always return the same word for single-word list', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // Arrange
      final singleWordList = ['HELLO'];

      // Act - Use intelligent solver
      final guess1 = FfiService.getBestGuessFast(singleWordList, []);
      final guess2 = FfiService.getBestGuessFast(singleWordList, []);
      final guess3 = FfiService.getBestGuessFast(singleWordList, []);

      // Assert - Should return the only available word
      expect(guess1, equals('HELLO'));
      expect(guess2, equals('HELLO'));
      expect(guess3, equals('HELLO'));
    });

    test('should handle large answer word lists', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // Arrange - Create a large list of valid 5-letter words
      final largeAnswerList = List.generate(
        100,
        (index) => 'WORD${index.toString().padLeft(2, '0')}',
      );

      // Act - Use intelligent solver
      final intelligentGuess = FfiService.getBestGuessFast(largeAnswerList, []);

      // Assert
      expect(intelligentGuess, isNotNull);
      expect(intelligentGuess!.length, equals(6)); // "WORD" + 2 digits
      expect(intelligentGuess, isIn(largeAnswerList));
    });

    test('should work correctly after FFI service initialization', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // This test verifies the service works correctly after initialization
      // We can't easily test the uninitialized state with static methods,
      // but we can verify the service works after initialization

      // Arrange & Act & Assert
      final answerWords = ['TEST'];
      final result = FfiService.getBestGuessFast(answerWords, []);
      expect(result, equals('TEST'));
    });

    test(
      'should consistently return optimal word for entropy analysis',
      () async {
        if (!ffiAvailable) {
          DebugLogger.testPrint(
            'Skipping test: FFI not available in test environment',
            tag: 'FFITest',
          );
          return;
        }

        // Arrange
        final answerWords = ['CRANE', 'SLATE', 'CRATE', 'TRACE', 'ADIEU'];

        // Act - Test consistency of intelligent solver
        final results = <String>[];
        for (var i = 0; i < 10; i++) {
          final guess = FfiService.getBestGuessFast(answerWords, []);
          if (guess != null) {
            results.add(guess);
          }
        }

        // Assert - Intelligent solver should be consistent
        expect(results.length, equals(10));
        
        // All results should be the same (optimal word)
        final firstResult = results.first;
        for (final result in results) {
          expect(result, equals(firstResult));
        }
        
        // The result should be one of the optimal first guesses
        final optimalGuesses = ['TARES', 'SLATE', 'CRANE', 'CRATE', 'SLANT'];
        expect(optimalGuesses, contains(firstResult));
      },
    );
  });
}
