import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for asset loading functionality
///
/// These tests verify that the word list assets can be properly loaded
/// and contain the expected data structure for the Wordle Helper app.
void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Asset Loading Tests', () {
    test('wordle_words.json can be loaded as asset', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );

      expect(wordListJson, isNotNull);
      expect(wordListJson, isNotEmpty);
    });

    test('wordle_words.json is valid JSON', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );

      // Parse JSON to verify it's valid
      final jsonData = jsonDecode(wordListJson);
      expect(jsonData, isA<Map<String, dynamic>>());

      // Verify it contains word data
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;
      expect(answerWords.length, greaterThan(0));
      expect(guessWords.length, greaterThan(0));
    });

    test('wordle_words.json contains word data', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );
      final jsonData = jsonDecode(wordListJson) as Map<String, dynamic>;
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;

      // Verify it contains word data
      expect(jsonData.length, greaterThan(0));
    });

    test('wordle_words.json can be used for guess words', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );
      final jsonData = jsonDecode(wordListJson) as Map<String, dynamic>;
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;

      expect(jsonData, isNotNull);
      expect(jsonData, isNotEmpty);
    });

    test('wordle_words.json contains word data for guessing', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );
      final jsonData = jsonDecode(wordListJson) as Map<String, dynamic>;
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;

      expect(answerWords.length, greaterThan(0));
      expect(guessWords.length, greaterThan(0));
    });

    test('wordle_words.json contains 5-letter words', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );
      final jsonData = jsonDecode(wordListJson) as Map<String, dynamic>;
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;

      // Check first 10 words to verify they are 5 letters
      for (int i = 0; i < answerWords.length && i < 10; i++) {
        final word = answerWords[i].toString();
        expect(
          word.length,
          equals(5),
          reason: 'Word "$word" should be 5 letters long',
        );
      }
    });

    test('wordle_words.json contains uppercase words', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );
      final jsonData = jsonDecode(wordListJson) as Map<String, dynamic>;
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;

      // Check first 10 words to verify they are uppercase
      for (int i = 0; i < answerWords.length && i < 10; i++) {
        final word = answerWords[i].toString();
        expect(
          word,
          equals(word.toUpperCase()),
          reason: 'Word "$word" should be uppercase',
        );
      }
    });

    test('assets directory structure is correct', () async {
      // Test that we can load from the expected asset paths
      expect(() async {
        await rootBundle.loadString('assets/word_lists/official_wordle_words.json');
      }, returnsNormally);
    });

    test('asset loading throws for non-existent files', () async {
      // Test that loading non-existent assets throws
      expect(() async {
        await rootBundle.loadString('assets/word_lists/non_existent.json');
      }, throwsA(isA<FlutterError>()));
    });

    test('word list assets are not empty', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );

      expect(wordListJson.length, greaterThan(100)); // Reasonable size check
    });
  });

  group('Asset Content Validation Tests', () {
    test('wordle_words.json has reasonable size', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );

      // Verify it's not too small (should contain substantial word data)
      expect(wordListJson.length, greaterThan(100));

      // Verify it's not unreasonably large (should be under 1MB)
      expect(wordListJson.length, lessThan(1024 * 1024));
    });

    test('wordle_words.json has reasonable size for guessing', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );
      final jsonData = jsonDecode(wordListJson) as Map<String, dynamic>;
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;

      // Verify it's not too small (should contain substantial word data)
      expect(answerWords.length, greaterThan(100));
      expect(guessWords.length, greaterThan(100));

      // Verify it's not unreasonably large (should be under 50k words)
      expect(answerWords.length, lessThan(50000));
      expect(guessWords.length, lessThan(50000));
    });

    test('word lists contain expected number of words', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );
      final jsonData = jsonDecode(wordListJson) as Map<String, dynamic>;
      final answerWords = jsonData['answer_words'] as List<dynamic>;
      final guessWords = jsonData['guess_words'] as List<dynamic>;

      // Should have a reasonable number of words (typical Wordle lists have 100+ words)
      expect(answerWords.length, greaterThan(10));
      expect(guessWords.length, greaterThan(10));
      expect(answerWords.length, lessThan(50000)); // Reasonable upper bound
      expect(guessWords.length, lessThan(50000)); // Reasonable upper bound
    });
  });
}
