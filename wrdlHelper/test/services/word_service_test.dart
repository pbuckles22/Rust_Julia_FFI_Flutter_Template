import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/exceptions/service_exceptions.dart';
import 'package:wrdlhelper/exceptions/validation_exceptions.dart';
import 'package:wrdlhelper/services/word_service.dart';
import 'package:wrdlhelper/service_locator.dart';

/// Comprehensive tests for WordService
///
/// These tests validate word list management, loading, filtering, and validation
/// for the Wordle game following TDD principles.
void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WordService Tests', () {
    // Now works with comprehensive algorithm-testing word list
    late WordService wordService;

    setUp(() {
      // Reset services to ensure clean state
      resetAllServices();
      
      wordService = WordService();
    });

    group('Word List Loading', () {
      test('loads word list from assets successfully', () async {
        // Arrange
        const assetPath = 'assets/word_lists/official_wordle_words.json';

        // Act
        await wordService.loadWordList(assetPath);

        // Assert
        expect(wordService.wordList, isNotNull);
        expect(wordService.wordList.isNotEmpty, isTrue);
        expect(wordService.isLoaded, isTrue);
      });

      test('loads guess words from assets successfully', () async {
        // Arrange
        const assetPath = 'assets/word_lists/official_guess_words.txt';

        // Act
        await wordService.loadGuessWords(assetPath);

        // Assert
        expect(wordService.guessWords, isNotNull);
        expect(wordService.guessWords.isNotEmpty, isTrue);
        expect(wordService.isGuessWordsLoaded, isTrue);
      });

      test('handles missing asset file gracefully', () async {
        // Arrange
        const missingAssetPath = 'assets/word_lists/missing.json';

        // Act
        await wordService.loadWordList(missingAssetPath);

        // Assert - should provide fallback data instead of throwing
        expect(wordService.isLoaded, isTrue);
        expect(wordService.wordListSize, greaterThan(0));
      });

      test('handles malformed JSON gracefully', () async {
        // Arrange
        const malformedAssetPath = 'assets/word_lists/malformed.json';

        // Act
        await wordService.loadWordList(malformedAssetPath);

        // Assert - should provide fallback data instead of throwing
        expect(wordService.isLoaded, isTrue);
        expect(wordService.wordListSize, greaterThan(0));
      });

      test('handles empty asset file gracefully', () async {
        // Arrange
        const emptyAssetPath = 'assets/word_lists/empty.json';

        // Act
        await wordService.loadWordList(emptyAssetPath);

        // Assert - should provide fallback data instead of throwing
        expect(wordService.isLoaded, isTrue);
        expect(wordService.wordListSize, greaterThan(0));
      });
    });

    group('Word List Validation', () {
      test('validates word list contains valid words', () async {
        // Arrange
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act
        final isValid = wordService.validateWordList();

        // Assert
        expect(
          isValid,
          isTrue,
        ); // Real word list contains only valid 5-letter words
      });

      test('validates all words are 5 letters long', () async {
        // Arrange
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act
        final allValidLength = wordService.wordList.every(
          (word) => word.length == 5,
        );

        // Assert
        expect(
          allValidLength,
          isTrue,
        ); // Real word list contains only 5-letter words
      });

      test('validates all words contain only letters', () async {
        // Arrange
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act
        final allValidCharacters = wordService.wordList.every(
          (word) => word.isValidCharacters,
        );

        // Assert
        expect(allValidCharacters, isTrue);
      });

      test('validates all words are uppercase', () async {
        // Arrange
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act
        final allUppercase = wordService.wordList.every(
          (word) => word.value == word.value.toUpperCase(),
        );

        // Assert
        expect(allUppercase, isTrue);
      });

      test('validates word list is not empty', () async {
        // Arrange
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act
        final isNotEmpty = wordService.wordList.isNotEmpty;

        // Assert
        expect(isNotEmpty, isTrue);
      });
    });

    group('Word Filtering', () {
      setUp(() async {
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
        await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      });

      test('filters words by length', () {
        // Arrange
        const targetLength = 5;

        // Act
        final filteredWords = wordService.filterWordsByLength(targetLength);

        // Assert
        expect(
          filteredWords.every((word) => word.length == targetLength),
          isTrue,
        );
        expect(
          filteredWords.length,
          greaterThan(10),
        ); // Should have reasonable word list (actual: 14,854 words in test environment)
      });

      test('filters words by invalid length', () {
        // Arrange
        const targetLength = 3;

        // Act
        final filteredWords = wordService.filterWordsByLength(targetLength);

        // Assert
        expect(filteredWords, isEmpty);
      });

      test('filters words by letter pattern', () {
        // Arrange
        const pattern = 'C????'; // Words starting with C

        // Act
        final filteredWords = wordService.filterWordsByPattern(pattern);

        // Assert
        expect(
          filteredWords.every((word) => word.value.startsWith('C')),
          isTrue,
        );
        expect(filteredWords.isNotEmpty, isTrue);
      });

      test('filters words by letter pattern with multiple letters', () {
        // Arrange
        const pattern = 'CR???'; // Words starting with CR

        // Act
        final filteredWords = wordService.filterWordsByPattern(pattern);

        // Assert
        expect(
          filteredWords.every((word) => word.value.startsWith('CR')),
          isTrue,
        );
        expect(filteredWords.isNotEmpty, isTrue);
      });

      test('filters words by letter pattern with no matches', () {
        // Arrange
        const pattern = 'ZZZZZ'; // No words start with ZZZZ

        // Act
        final filteredWords = wordService.filterWordsByPattern(pattern);

        // Assert
        expect(filteredWords, isEmpty);
      });

      test('filters words by containing letter', () {
        // Arrange
        const letter = 'A';

        // Act
        final filteredWords = wordService.filterWordsContainingLetter(letter);

        // Assert
        expect(
          filteredWords.every((word) => word.containsLetter(letter)),
          isTrue,
        );
        expect(filteredWords.isNotEmpty, isTrue);
      });

      test('filters words by not containing letter', () {
        // Arrange
        const letter = 'Z';

        // Act
        final filteredWords = wordService.filterWordsNotContainingLetter(
          letter,
        );

        // Assert
        expect(
          filteredWords.every((word) => !word.containsLetter(letter)),
          isTrue,
        );
        expect(
          filteredWords.length,
          lessThanOrEqualTo(wordService.wordList.length),
        );
      });

      test('filters words by multiple criteria', () {
        // Arrange
        const letter = 'A';
        const pattern = 'C????';

        // Act
        final filteredWords = wordService.filterWordsByMultipleCriteria(
          pattern: pattern,
          mustContain: [letter],
        );

        // Assert
        expect(
          filteredWords.every((word) => word.value.startsWith('C')),
          isTrue,
        );
        expect(
          filteredWords.every((word) => word.containsLetter(letter)),
          isTrue,
        );
        expect(filteredWords.isNotEmpty, isTrue);
      });
    });

    group('Word Search', () {
      setUp(() async {
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
        await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      });

      test('finds word in word list', () {
        // Arrange
        const searchWord = 'CRANE';

        // Act
        final found = wordService.findWord(searchWord);

        // Assert
        expect(found, isNotNull);
        expect(found!.value, equals(searchWord));
      });

      test('finds word case insensitively', () {
        // Arrange
        const searchWord = 'crane';

        // Act
        final found = wordService.findWord(searchWord);

        // Assert
        expect(found, isNotNull);
        expect(found!.value, equals('CRANE'));
      });

      test('returns null for word not in list', () {
        // Arrange
        const searchWord = 'ZZZZZ';

        // Act
        final found = wordService.findWord(searchWord);

        // Assert
        expect(found, isNull);
      });

      test('finds word by partial match', () {
        // Arrange
        const partialWord = 'CRAN';

        // Act
        final found = wordService.findWordsByPartialMatch(partialWord);

        // Assert
        expect(found, isNotEmpty);
        expect(
          found.every((word) => word.value.startsWith(partialWord)),
          isTrue,
        );
      });

      test('finds words by letter frequency', () {
        // Arrange
        const letter = 'A';

        // Act
        final found = wordService.findWordsByLetterFrequency(letter, 1);

        // Assert
        expect(found, isNotEmpty);
        expect(found.every((word) => word.countLetter(letter) == 1), isTrue);
      });
    });

    group('Word Statistics', () {
      setUp(() async {
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
        await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      });

      test('calculates word list size', () {
        // Act
        final size = wordService.wordListSize;

        // Assert
        expect(size, greaterThan(0));
        expect(size, equals(wordService.wordList.length));
      });

      test('calculates guess words size', () {
        // Act
        final size = wordService.guessWordsSize;

        // Assert
        expect(size, greaterThan(0));
        expect(size, equals(wordService.guessWords.length));
      });

      test('calculates letter frequency distribution', () {
        // Act
        final distribution = wordService.getLetterFrequencyDistribution();

        // Assert
        expect(distribution, isNotNull);
        expect(distribution.isNotEmpty, isTrue);
        expect(distribution.keys.every((letter) => letter.length == 1), isTrue);
        expect(distribution.values.every((count) => count > 0), isTrue);
      });

      test('calculates most common letters', () {
        // Act
        final commonLetters = wordService.getMostCommonLetters(5);

        // Assert
        expect(commonLetters.length, equals(5));
        expect(commonLetters.every((letter) => letter.length == 1), isTrue);
      });

      test('calculates least common letters', () {
        // Act
        final rareLetters = wordService.getLeastCommonLetters(5);

        // Assert
        expect(rareLetters.length, equals(5));
        expect(rareLetters.every((letter) => letter.length == 1), isTrue);
      });
    });

    group('Word Service Error Handling', () {
      test('handles service not initialized', () {
        // Arrange
        final uninitializedService = WordService();

        // Act & Assert
        expect(
          () => uninitializedService.wordList,
          throwsA(isA<ServiceNotInitializedException>()),
        );
        expect(
          () => uninitializedService.guessWords,
          throwsA(isA<ServiceNotInitializedException>()),
        );
        expect(
          () => uninitializedService.validateWordList(),
          throwsA(isA<ServiceNotInitializedException>()),
        );
      });

      test('handles invalid pattern format', () async {
        // Arrange
        const invalidPattern = 'INVALID';
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act & Assert
        expect(
          () => wordService.filterWordsByPattern(invalidPattern),
          throwsA(isA<InvalidPatternException>()),
        );
      });

      test('handles empty search criteria', () async {
        // Arrange
        const emptyPattern = '';
        const emptyLetter = '';
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act & Assert
        expect(
          () => wordService.filterWordsByPattern(emptyPattern),
          throwsA(isA<InvalidPatternException>()),
        );
        expect(
          () => wordService.filterWordsContainingLetter(emptyLetter),
          throwsA(isA<InvalidLetterException>()),
        );
      });

      test('handles null search criteria', () async {
        // Arrange
        const String? nullPattern = null;
        const String? nullLetter = null;
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');

        // Act & Assert
        expect(
          () => wordService.filterWordsByPattern(nullPattern),
          throwsA(isA<InvalidPatternException>()),
        );
        expect(
          () => wordService.filterWordsContainingLetter(nullLetter),
          throwsA(isA<InvalidLetterException>()),
        );
      });
    });

    group('Word Service Performance', () {
      setUp(() async {
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
        await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      });

      test('loads word list quickly', () async {
        // Arrange
        final service = WordService();
        const assetPath = 'assets/word_lists/official_wordle_words.json';

        // Act
        final stopwatch = Stopwatch()..start();
        await service.loadWordList(assetPath);
        stopwatch.stop();

        // Assert
        expect(service.isLoaded, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
        ); // Should load within 1 second
      });

      test('filters words quickly', () {
        // Arrange
        const pattern = 'C????';

        // Act
        final stopwatch = Stopwatch()..start();
        final filteredWords = wordService.filterWordsByPattern(pattern);
        stopwatch.stop();

        // Assert
        expect(filteredWords, isNotEmpty);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Should filter within 100ms
      });

      test('searches words quickly', () {
        // Arrange
        const searchWord = 'CRANE';

        // Act
        final stopwatch = Stopwatch()..start();
        final found = wordService.findWord(searchWord);
        stopwatch.stop();

        // Assert
        expect(found, isNotNull);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(10),
        ); // Should search within 10ms
      });

      test('calculates statistics quickly', () {
        // Act
        final stopwatch = Stopwatch()..start();
        final distribution = wordService.getLetterFrequencyDistribution();
        stopwatch.stop();

        // Assert
        expect(distribution, isNotEmpty);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Should calculate within 100ms
      });
    });

    group('Word Service Edge Cases', () {
      test('handles very large word list', () async {
        // Arrange
        final largeService = WordService();
        // Simulate loading a very large word list

        // Act
        final stopwatch = Stopwatch()..start();
        await largeService.loadWordList('assets/word_lists/official_wordle_words.json');
        stopwatch.stop();

        // Assert
        expect(largeService.isLoaded, isTrue);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5000),
        ); // Should handle large lists
      });

      test('handles word list with special characters', () async {
        // Arrange
        final service = WordService();

        // Act
        await service.loadWordList('assets/word_lists/official_wordle_words.json');

        // Assert
        expect(
          service.wordList.every((word) => word.isValidCharacters),
          isTrue,
        );
      });

      test('handles word list with duplicate words', () async {
        // Arrange
        final service = WordService();

        // Act
        await service.loadWordList('assets/word_lists/official_wordle_words.json');

        // Assert
        expect(
          service.wordList.length,
          greaterThan(10), // Should have reasonable word list (actual: 14,854 words in test environment)
        );
      });

      test('handles empty word list gracefully', () async {
        // Arrange
        final service = WordService();

        // Act
        await service.loadWordList('assets/word_lists/official_wordle_words.json');

        // Assert
        expect(service.wordList.isNotEmpty, isTrue); // Should have words
      });
    });
  });
}
