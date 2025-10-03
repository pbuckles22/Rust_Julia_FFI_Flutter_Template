import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/word_service.dart';

import 'mock_word_service.mocks.dart';

// Generate mocks using Mockito
@GenerateMocks([WordService])
void main() {}

/// Mock WordService for unit tests
/// 
/// This provides a lightweight, fast mock implementation that doesn't
/// load real word lists or perform expensive operations.
class MockWordService extends Mock implements WordService {
  // Override specific methods with predictable behavior for testing
  @override
  List<Word> get guessWords => [
    Word.fromString('CRANE'),
    Word.fromString('SLATE'),
    Word.fromString('TRACE'),
    Word.fromString('CRATE'),
    Word.fromString('ADIEU'),
  ];

  @override
  List<Word> get answerWords => [
    Word.fromString('CRANE'),
    Word.fromString('SLATE'),
    Word.fromString('TRACE'),
    Word.fromString('CRATE'),
    Word.fromString('ADIEU'),
  ];

  @override
  bool get isGuessWordsLoaded => true;

  @override
  bool get isAnswerWordsLoaded => true;

  @override
  bool get isLoaded => true;

  @override
  Word? findWord(String word) {
    if (word == 'CRANE') return Word.fromString('CRANE');
    if (word == 'SLATE') return Word.fromString('SLATE');
    if (word == 'TRACE') return Word.fromString('TRACE');
    if (word == 'CRATE') return Word.fromString('CRATE');
    if (word == 'ADIEU') return Word.fromString('ADIEU');
    return null;
  }

  @override
  List<Word> filterWords({
    List<String>? mustContain,
    List<String>? mustNotContain,
    List<String>? mustContainAtPosition,
    List<String>? mustNotContainAtPosition,
  }) {
    // Simple mock implementation - return all words for testing
    return guessWords;
  }
}
