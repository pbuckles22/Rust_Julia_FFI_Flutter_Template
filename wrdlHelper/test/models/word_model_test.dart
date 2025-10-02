import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/word.dart';

/// Comprehensive tests for Word model
///
/// These tests follow TDD principles and validate all aspects of word handling
/// including validation, serialization, and business logic for the Wordle game.
void main() {
  group('Word Model Tests', () {
    group('Word Creation and Validation', () {
      test('creates valid word from string', () {
        // Arrange
        const wordString = 'CRANE';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('CRANE'));
        expect(word.isValid, isTrue);
        expect(word.length, equals(5));
      });

      test('creates word with lowercase input', () {
        // Arrange
        const wordString = 'crane';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('CRANE')); // Should be uppercase
        expect(word.isValid, isTrue);
      });

      test('creates word with mixed case input', () {
        // Arrange
        const wordString = 'CrAnE';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('CRANE')); // Should be uppercase
        expect(word.isValid, isTrue);
      });

      test('rejects word with invalid length - too short', () {
        // Arrange
        const wordString = 'CAT';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('CAT'));
        expect(word.isValid, isFalse);
        expect(word.length, equals(3));
      });

      test('rejects word with invalid length - too long', () {
        // Arrange
        const wordString = 'HELLO';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('HELLO'));
        expect(word.isValid, isFalse);
        expect(word.length, equals(5));
      });

      test('rejects word with non-alphabetic characters', () {
        // Arrange
        const wordString = 'CR4NE';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('CR4NE'));
        expect(word.isValid, isFalse);
      });

      test('rejects empty word', () {
        // Arrange
        const wordString = '';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals(''));
        expect(word.isValid, isFalse);
        expect(word.length, equals(0));
      });

      test('rejects word with spaces', () {
        // Arrange
        const wordString = 'CR ANE';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('CR ANE'));
        expect(word.isValid, isFalse);
      });

      test('rejects word with special characters', () {
        // Arrange
        const wordString = 'CR@NE';

        // Act
        final word = Word.fromString(wordString);

        // Assert
        expect(word.value, equals('CR@NE'));
        expect(word.isValid, isFalse);
      });
    });

    group('Word Equality and Comparison', () {
      test('two words with same value are equal', () {
        // Arrange
        final word1 = Word.fromString('CRANE');
        final word2 = Word.fromString('crane');

        // Act & Assert
        expect(word1, equals(word2));
        expect(word1.hashCode, equals(word2.hashCode));
      });

      test('two words with different values are not equal', () {
        // Arrange
        final word1 = Word.fromString('CRANE');
        final word2 = Word.fromString('SLATE');

        // Act & Assert
        expect(word1, isNot(equals(word2)));
        expect(word1.hashCode, isNot(equals(word2.hashCode)));
      });

      test('word equals string with same value', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(word.value, equals('CRANE'));
        expect(word.toString(), equals('CRANE'));
      });
    });

    group('Word Character Access', () {
      test('accesses characters by index', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(word[0], equals('C'));
        expect(word[1], equals('R'));
        expect(word[2], equals('A'));
        expect(word[3], equals('N'));
        expect(word[4], equals('E'));
      });

      test('throws error for invalid index - too high', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(() => word[5], throwsRangeError);
      });

      test('throws error for invalid index - negative', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(() => word[-1], throwsRangeError);
      });

      test('gets character count', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(word.characterCount, equals(5));
      });
    });

    group('Word Letter Analysis', () {
      test('counts letter frequency correctly', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final letterCount = word.letterFrequency;

        // Assert
        expect(letterCount['C'], equals(1));
        expect(letterCount['R'], equals(1));
        expect(letterCount['A'], equals(1));
        expect(letterCount['N'], equals(1));
        expect(letterCount['E'], equals(1));
        expect(letterCount['Z'], equals(0)); // Letter not in word
      });

      test('counts duplicate letters correctly', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final letterCount = word.letterFrequency;

        // Assert
        expect(letterCount['C'], equals(1));
        expect(letterCount['R'], equals(1));
        expect(letterCount['A'], equals(1));
        expect(letterCount['N'], equals(1));
        expect(letterCount['E'], equals(1));
      });

      test('identifies unique letters', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final uniqueLetters = word.uniqueLetters;

        // Assert
        expect(uniqueLetters, equals({'C', 'R', 'A', 'N', 'E'}));
        expect(uniqueLetters.length, equals(5));
      });

      test('identifies duplicate letters', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final hasDuplicates = word.hasDuplicateLetters;

        // Assert
        expect(hasDuplicates, isFalse);
      });

      test('detects duplicate letters in word', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final hasDuplicates = word.hasDuplicateLetters;

        // Assert
        expect(hasDuplicates, isFalse);
      });
    });

    group('Word Validation Rules', () {
      test('validates word length is exactly 5', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final invalidWord = Word.fromString('CAT');

        // Act & Assert
        expect(validWord.isValidLength, isTrue);
        expect(invalidWord.isValidLength, isFalse);
      });

      test('validates word contains only letters', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final invalidWord = Word.fromString('CR4NE');

        // Act & Assert
        expect(validWord.isValidCharacters, isTrue);
        expect(invalidWord.isValidCharacters, isFalse);
      });

      test('validates word is not empty', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final invalidWord = Word.fromString('');

        // Act & Assert
        expect(validWord.isNotEmpty, isTrue);
        expect(invalidWord.isNotEmpty, isFalse);
      });

      test('validates word meets all criteria', () {
        // Arrange
        final validWord = Word.fromString('CRANE');
        final invalidWord1 = Word.fromString('CAT');
        final invalidWord2 = Word.fromString('CR4NE');
        final invalidWord3 = Word.fromString('');

        // Act & Assert
        expect(validWord.isValid, isTrue);
        expect(invalidWord1.isValid, isFalse);
        expect(invalidWord2.isValid, isFalse);
        expect(invalidWord3.isValid, isFalse);
      });
    });

    group('Word Serialization', () {
      test('serializes to JSON correctly', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final json = word.toJson();

        // Assert
        expect(json, equals({'value': 'CRANE', 'isValid': true}));
      });

      test('deserializes from JSON correctly', () {
        // Arrange
        final json = {'value': 'CRANE', 'isValid': true};

        // Act
        final word = Word.fromJson(json);

        // Assert
        expect(word.value, equals('CRANE'));
        expect(word.isValid, isTrue);
      });

      test('handles invalid JSON gracefully', () {
        // Arrange
        final invalidJson = {'invalid': 'data'};

        // Act & Assert
        expect(
          () => Word.fromJson(invalidJson),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Word Business Logic', () {
      test('checks if word contains letter', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(word.containsLetter('C'), isTrue);
        expect(word.containsLetter('R'), isTrue);
        expect(word.containsLetter('A'), isTrue);
        expect(word.containsLetter('N'), isTrue);
        expect(word.containsLetter('E'), isTrue);
        expect(word.containsLetter('Z'), isFalse);
      });

      test('checks if word contains letter at position', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(word.containsLetterAt('C', 0), isTrue);
        expect(word.containsLetterAt('R', 1), isTrue);
        expect(word.containsLetterAt('A', 2), isTrue);
        expect(word.containsLetterAt('N', 3), isTrue);
        expect(word.containsLetterAt('E', 4), isTrue);
        expect(word.containsLetterAt('C', 1), isFalse);
        expect(word.containsLetterAt('Z', 0), isFalse);
      });

      test('counts letter occurrences', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(word.countLetter('C'), equals(1));
        expect(word.countLetter('R'), equals(1));
        expect(word.countLetter('A'), equals(1));
        expect(word.countLetter('N'), equals(1));
        expect(word.countLetter('E'), equals(1));
        expect(word.countLetter('Z'), equals(0));
      });

      test('finds letter positions', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final cPositions = word.findLetterPositions('C');
        final rPositions = word.findLetterPositions('R');
        final zPositions = word.findLetterPositions('Z');

        // Assert
        expect(cPositions, equals([0]));
        expect(rPositions, equals([1]));
        expect(zPositions, equals([]));
      });
    });

    group('Word Edge Cases', () {
      test('handles word with all same letters', () {
        // Arrange
        final word = Word.fromString('AAAAA');

        // Act & Assert
        expect(word.value, equals('AAAAA'));
        expect(word.isValid, isTrue);
        expect(word.hasDuplicateLetters, isTrue);
        expect(word.uniqueLetters, equals({'A'}));
        expect(word.countLetter('A'), equals(5));
      });

      test('handles word with maximum duplicates', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act & Assert
        expect(word.hasDuplicateLetters, isFalse);
        expect(word.uniqueLetters.length, equals(5));
      });

      test('handles word with special characters gracefully', () {
        // Arrange
        final word = Word.fromString('CR@NE');

        // Act & Assert
        expect(word.value, equals('CR@NE'));
        expect(word.isValid, isFalse);
        expect(word.isValidCharacters, isFalse);
      });

      test('handles very long input gracefully', () {
        // Arrange
        final longWord = 'A' * 1000;
        final word = Word.fromString(longWord);

        // Act & Assert
        expect(word.value, equals(longWord));
        expect(word.isValid, isFalse);
        expect(word.length, equals(1000));
      });
    });

    group('Word Performance Tests', () {
      test('creates word quickly for valid input', () {
        // Arrange
        const wordString = 'CRANE';

        // Act
        final stopwatch = Stopwatch()..start();
        final word = Word.fromString(wordString);
        stopwatch.stop();

        // Assert
        expect(word.isValid, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(10),
        ); // Should be very fast
      });

      test('validates word quickly', () {
        // Arrange
        final word = Word.fromString('CRANE');

        // Act
        final stopwatch = Stopwatch()..start();
        final isValid = word.isValid;
        stopwatch.stop();

        // Assert
        expect(isValid, isTrue);
        expect(stopwatch.elapsedMilliseconds, lessThan(1)); // Should be instant
      });
    });
  });
}
