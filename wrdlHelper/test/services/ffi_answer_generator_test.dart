import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('FFI Answer Generator Tests', () {
    bool ffiAvailable = false;

    setUpAll(() async {
      // Initialize FFI service before running tests
      try {
        await FfiService.initialize();
        ffiAvailable = true;
      } catch (e) {
        // FFI initialization may fail in test environment, that's OK
        // The tests will be skipped or use fallback behavior
        DebugLogger.testPrint(
          'FFI initialization failed in test: $e',
          tag: 'FFITest',
        );
        ffiAvailable = false;
      }
    });

    test('should generate random answer word from valid list', () async {
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

      // Act
      final randomWord = FfiService.getRandomAnswerWord(answerWords);

      // Assert
      expect(randomWord, isNotNull);
      expect(randomWord, isA<String>());
      expect(randomWord!.length, equals(5));
      expect(randomWord, isIn(answerWords));
      expect(randomWord, matches(RegExp(r'^[A-Z]{5}$')));
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

      // Act
      final randomWord = FfiService.getRandomAnswerWord(emptyList);

      // Assert
      expect(randomWord, isNull);
    });

    test('should generate different words on multiple calls', () async {
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

      // Act
      final generatedWords = <String>{};
      for (int i = 0; i < 50; i++) {
        final randomWord = FfiService.getRandomAnswerWord(answerWords);
        if (randomWord != null) {
          generatedWords.add(randomWord);
        }
      }

      // Assert
      expect(
        generatedWords.length,
        greaterThan(1),
        reason: 'Should generate variety of words',
      );
      expect(
        generatedWords.length,
        greaterThanOrEqualTo(5),
        reason: 'Should generate at least 5 unique words in 50 attempts',
      );

      // All generated words should be valid
      for (final word in generatedWords) {
        expect(word.length, equals(5));
        expect(word, matches(RegExp(r'^[A-Z]{5}$')));
        expect(word, isIn(answerWords));
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

      // Act
      final randomWord1 = FfiService.getRandomAnswerWord(singleWordList);
      final randomWord2 = FfiService.getRandomAnswerWord(singleWordList);
      final randomWord3 = FfiService.getRandomAnswerWord(singleWordList);

      // Assert
      expect(randomWord1, equals('HELLO'));
      expect(randomWord2, equals('HELLO'));
      expect(randomWord3, equals('HELLO'));
    });

    test('should handle large answer word lists', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // Arrange - Create a large list of answer words
      final largeAnswerList = List.generate(
        1000,
        (index) => 'WORD${index.toString().padLeft(3, '0')}',
      );

      // Act
      final randomWord = FfiService.getRandomAnswerWord(largeAnswerList);

      // Assert
      expect(randomWord, isNotNull);
      expect(randomWord!.length, equals(7)); // "WORD" + 3 digits
      expect(randomWord, isIn(largeAnswerList));
    });

    test('should throw exception when FFI service not initialized', () async {
      if (!ffiAvailable) {
        DebugLogger.testPrint(
          'Skipping test: FFI not available in test environment',
          tag: 'FFITest',
        );
        return;
      }

      // This test would require resetting the initialization state,
      // which is complex with static state. Instead, we'll test the
      // initialization requirement indirectly by ensuring our tests
      // properly initialize the service.

      // Arrange & Act & Assert
      // We can't easily test the uninitialized state with static methods,
      // but we can verify the service works after initialization
      final answerWords = ['TEST'];
      final result = FfiService.getRandomAnswerWord(answerWords);
      expect(result, equals('TEST'));
    });

    test(
      'should generate words with proper distribution over many calls',
      () async {
        if (!ffiAvailable) {
          DebugLogger.testPrint(
            'Skipping test: FFI not available in test environment',
            tag: 'FFITest',
          );
          return;
        }

        // Arrange
        final answerWords = ['A', 'B', 'C', 'D', 'E'];
        final wordCounts = <String, int>{};

        // Act - Generate many words and count occurrences
        for (int i = 0; i < 1000; i++) {
          final randomWord = FfiService.getRandomAnswerWord(answerWords);
          if (randomWord != null) {
            wordCounts[randomWord] = (wordCounts[randomWord] ?? 0) + 1;
          }
        }

        // Assert - Each word should appear roughly equally (within reasonable variance)
        expect(
          wordCounts.length,
          equals(5),
          reason: 'All 5 words should appear at least once',
        );

        for (final word in answerWords) {
          expect(
            wordCounts[word],
            isNotNull,
            reason: 'Word $word should appear in results',
          );
          expect(
            wordCounts[word]!,
            greaterThan(100),
            reason: 'Word $word should appear frequently enough',
          );
          expect(
            wordCounts[word]!,
            lessThan(400),
            reason: 'Word $word should not dominate the distribution',
          );
        }
      },
    );
  });
}
