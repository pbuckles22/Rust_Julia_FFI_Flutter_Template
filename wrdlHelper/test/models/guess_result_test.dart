import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/exceptions/game_exceptions.dart';

/// Comprehensive tests for GuessResult model
/// 
/// These tests validate guess result tracking, letter state management,
/// and result analysis for the Wordle game following TDD principles.
void main() {
  group('GuessResult Model Tests', () {
    group('GuessResult Creation', () {
      test('creates result from word with all gray letters', () {
        // Arrange
        final word = Word.fromString('CRANE');
        
        // Act
        final result = GuessResult.fromWord(word);
        
        // Assert
        expect(result.word, equals(word));
        expect(result.letterStates.length, equals(5));
        expect(result.letterStates.every((state) => state == LetterState.gray), isTrue);
        expect(result.isComplete, isFalse);
      });

      test('creates result with custom letter states', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        
        // Act
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Assert
        expect(result.word, equals(word));
        expect(result.letterStates, equals(letterStates));
        expect(result.isComplete, isTrue);
      });

      test('creates result with mixed letter states', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
        ];
        
        // Act
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Assert
        expect(result.word, equals(word));
        expect(result.letterStates, equals(letterStates));
        expect(result.isComplete, isTrue);
      });
    });

    group('Letter State Access', () {
      test('accesses letter state by index', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act & Assert
        expect(result[0], equals(LetterState.green));
        expect(result[1], equals(LetterState.yellow));
        expect(result[2], equals(LetterState.gray));
        expect(result[3], equals(LetterState.gray));
        expect(result[4], equals(LetterState.gray));
      });

      test('throws error for invalid index - too high', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final result = GuessResult.fromWord(word);
        
        // Act & Assert
        expect(() => result[5], throwsRangeError);
      });

      test('throws error for invalid index - negative', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final result = GuessResult.fromWord(word);
        
        // Act & Assert
        expect(() => result[-1], throwsRangeError);
      });

      test('gets letter state for specific position', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act & Assert
        expect(result.getLetterState(0), equals(LetterState.green));
        expect(result.getLetterState(1), equals(LetterState.yellow));
        expect(result.getLetterState(2), equals(LetterState.gray));
      });
    });

    group('Letter State Analysis', () {
      test('counts green letters correctly', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final greenCount = result.greenCount;
        
        // Assert
        expect(greenCount, equals(2));
      });

      test('counts yellow letters correctly', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final yellowCount = result.yellowCount;
        
        // Assert
        expect(yellowCount, equals(2));
      });

      test('counts gray letters correctly', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final grayCount = result.grayCount;
        
        // Assert
        expect(grayCount, equals(3));
      });

      test('identifies if guess is correct', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final correctStates = [
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
        ];
        final incorrectStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        
        // Act
        final correctResult = GuessResult(word: word, letterStates: correctStates);
        final incorrectResult = GuessResult(word: word, letterStates: incorrectStates);
        
        // Assert
        expect(correctResult.isCorrect, isTrue);
        expect(incorrectResult.isCorrect, isFalse);
      });

      test('identifies if guess has any correct letters', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final someCorrectStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        final noCorrectStates = [
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        
        // Act
        final someCorrectResult = GuessResult(word: word, letterStates: someCorrectStates);
        final noCorrectResult = GuessResult(word: word, letterStates: noCorrectStates);
        
        // Assert
        expect(someCorrectResult.hasCorrectLetters, isTrue);
        expect(noCorrectResult.hasCorrectLetters, isFalse);
      });
    });

    group('Letter State Updates', () {
      test('updates letter state at specific position', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final result = GuessResult.fromWord(word);
        
        // Act
        result.updateLetterState(0, LetterState.green);
        result.updateLetterState(1, LetterState.yellow);
        
        // Assert
        expect(result[0], equals(LetterState.green));
        expect(result[1], equals(LetterState.yellow));
        expect(result[2], equals(LetterState.gray));
        expect(result[3], equals(LetterState.gray));
        expect(result[4], equals(LetterState.gray));
      });

      test('updates multiple letter states', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final result = GuessResult.fromWord(word);
        
        // Act
        result.updateLetterStates([
          LetterState.green,
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
        ]);
        
        // Assert
        expect(result[0], equals(LetterState.green));
        expect(result[1], equals(LetterState.green));
        expect(result[2], equals(LetterState.yellow));
        expect(result[3], equals(LetterState.gray));
        expect(result[4], equals(LetterState.gray));
      });

      test('validates letter state update bounds', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final result = GuessResult.fromWord(word);
        
        // Act & Assert
        expect(() => result.updateLetterState(5, LetterState.green), 
               throwsRangeError);
        expect(() => result.updateLetterState(-1, LetterState.green), 
               throwsRangeError);
      });
    });

    group('Guess Result Validation', () {
      test('validates letter states length matches word length', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final invalidStates = [
          LetterState.green,
          LetterState.yellow,
        ];
        
        // Act & Assert
        expect(() => GuessResult(word: word, letterStates: invalidStates), 
               throwsA(isA<InvalidGuessResultException>()));
      });

      test('validates letter states are not null', () {
        // Arrange
        final word = Word.fromString('CRANE');
        
        // Act & Assert
        expect(() => GuessResult(word: word, letterStates: []), 
               throwsA(isA<InvalidGuessResultException>()));
      });

      test('validates word is not null', () {
        // Arrange
        final letterStates = [
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
        ];
        
        // Act & Assert
        expect(() => GuessResult(word: null, letterStates: letterStates), 
               throwsA(isA<InvalidGuessResultException>()));
      });
    });

    group('Guess Result Analysis', () {
      test('finds positions of green letters', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.green,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final greenPositions = result.getGreenPositions();
        
        // Assert
        expect(greenPositions, equals([0, 3]));
      });

      test('finds positions of yellow letters', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.green,
          LetterState.yellow,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final yellowPositions = result.getYellowPositions();
        
        // Assert
        expect(yellowPositions, equals([1, 4]));
      });

      test('finds positions of gray letters', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.green,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final grayPositions = result.getGrayPositions();
        
        // Assert
        expect(grayPositions, equals([2, 4]));
      });

      test('gets letters by state', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.green,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final greenLetters = result.getLettersByState(LetterState.green);
        final yellowLetters = result.getLettersByState(LetterState.yellow);
        final grayLetters = result.getLettersByState(LetterState.gray);
        
        // Assert
        expect(greenLetters, equals(['C', 'N']));
        expect(yellowLetters, equals(['R']));
        expect(grayLetters, equals(['A', 'E']));
      });
    });

    group('Guess Result Serialization', () {
      test('serializes to JSON correctly', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final json = result.toJson();
        
        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['word'], isA<Map<String, dynamic>>());
        expect(json['letterStates'], isA<List>());
        expect(json['letterStates'].length, equals(5));
      });

      test('deserializes from JSON correctly', () {
        // Arrange
        final json = {
          'word': {'value': 'CRANE', 'isValid': true},
          'letterStates': ['green', 'yellow', 'gray', 'gray', 'gray']
        };
        
        // Act
        final result = GuessResult.fromJson(json);
        
        // Assert
        expect(result.word.value, equals('CRANE'));
        expect(result.letterStates[0], equals(LetterState.green));
        expect(result.letterStates[1], equals(LetterState.yellow));
        expect(result.letterStates[2], equals(LetterState.gray));
      });

      test('handles invalid JSON gracefully', () {
        // Arrange
        final invalidJson = {'invalid': 'data'};
        
        // Act & Assert
        expect(() => GuessResult.fromJson(invalidJson), 
               throwsA(isA<FormatException>()));
      });
    });

    group('Guess Result Edge Cases', () {
      test('handles result with all green letters', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act & Assert
        expect(result.isCorrect, isTrue);
        expect(result.greenCount, equals(5));
        expect(result.yellowCount, equals(0));
        expect(result.grayCount, equals(0));
      });

      test('handles result with all gray letters', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act & Assert
        expect(result.isCorrect, isFalse);
        expect(result.greenCount, equals(0));
        expect(result.yellowCount, equals(0));
        expect(result.grayCount, equals(5));
        expect(result.hasCorrectLetters, isFalse);
      });

      test('handles result with mixed states', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.yellow,
          LetterState.green,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act & Assert
        expect(result.isCorrect, isFalse);
        expect(result.greenCount, equals(2));
        expect(result.yellowCount, equals(2));
        expect(result.grayCount, equals(1));
        expect(result.hasCorrectLetters, isTrue);
      });
    });

    group('Guess Result Performance', () {
      test('creates result quickly', () {
        // Arrange
        final word = Word.fromString('CRANE');
        
        // Act
        final stopwatch = Stopwatch()..start();
        final result = GuessResult.fromWord(word);
        stopwatch.stop();
        
        // Assert
        expect(result.word, equals(word));
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });

      test('analyzes result quickly', () {
        // Arrange
        final word = Word.fromString('CRANE');
        final letterStates = [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
        ];
        final result = GuessResult(word: word, letterStates: letterStates);
        
        // Act
        final stopwatch = Stopwatch()..start();
        final greenCount = result.greenCount;
        final yellowCount = result.yellowCount;
        final grayCount = result.grayCount;
        stopwatch.stop();
        
        // Assert
        expect(greenCount, equals(1));
        expect(yellowCount, equals(1));
        expect(grayCount, equals(3));
        expect(stopwatch.elapsedMilliseconds, lessThan(1));
      });
    });
  });
}
