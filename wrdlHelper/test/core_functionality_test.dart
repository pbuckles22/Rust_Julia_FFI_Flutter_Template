import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';

void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TDD: Critical Bug Fixes', () {
    late WordService wordService;
    late GameService gameService;

    setUp(() {
      wordService = WordService();
      gameService = GameService();
    });

    group('Bug Fix 1: Mock Data Removal', () {
      test('WordService should not contain hardcoded fake words', () {
        // TDD: Verify no mock data exists in WordService
        // This test ensures the _realGuessWords constant was removed
        expect(wordService.isGuessWordsLoaded, false);

        // Verify service is not initialized (no hardcoded words)
        // This would fail if AAHED, BBXRT, CCCCM, FIGGY, JOKUL were still hardcoded
        expect(() => wordService.guessWords, throwsA(isA<Exception>()));
      });

      test('WordService should load real words from assets', () async {
        // TDD: Test that WordService can load real words
        await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');

        expect(wordService.isGuessWordsLoaded, true);
        expect(
          wordService.guessWords.length,
          greaterThan(1000),
        ); // Should have many real words

        // Verify all loaded words are 5 letters
        for (final word in wordService.guessWords) {
          expect(word.length, 5);
          expect(word.value.length, 5);
        }
      });
    });

    group('Bug Fix 2: Two-List Strategy', () {
      test('GameService should use answer words for first guess', () async {
        // TDD: Test that first guess comes from answer words (best starting words)
        await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
        await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
        await wordService.loadAnswerWords(
          'assets/word_lists/official_wordle_words.json',
        );

        // Create GameService with the loaded word service
        gameService = GameService(wordService: wordService);
        await gameService.initialize();

        final gameState = GameState.newGame();
        final suggestion = gameService.suggestNextGuess(gameState);

        // First guess should be from answer words (CRANE, SLATE, RAISE, etc.)
        final bestStartingWords = ['CRANE', 'SLATE', 'RAISE', 'SOARE', 'ADIEU'];
        expect(bestStartingWords.contains(suggestion?.value), true);
      });

      test(
        'GameService should filter subsequent guesses against both lists',
        () async {
          // TDD: Test that subsequent guesses use two-list strategy
          await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
          await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
          await wordService.loadAnswerWords(
            'assets/word_lists/official_wordle_words.json',
          );

          // Create GameService with the loaded word service
          gameService = GameService(wordService: wordService);
          await gameService.initialize();

          final gameState = GameState.newGame();
          final craneWord = Word.fromString('CRANE');
          final craneResult = GuessResult.withStates(
            word: craneWord,
            letterStates: [
              LetterState.green, // C
              LetterState.gray, // R
              LetterState.gray, // A
              LetterState.gray, // N
              LetterState.gray, // E
            ],
          );
          gameState.addGuess(craneWord, craneResult);

          final suggestion = gameService.suggestNextGuess(gameState);

          // Should suggest a word that starts with C and doesn't contain R, A, N, E
          expect(suggestion?.value.startsWith('C'), true);
          expect(suggestion?.value.contains('R'), false);
          expect(suggestion?.value.contains('A'), false);
          expect(suggestion?.value.contains('N'), false);
          expect(suggestion?.value.contains('E'), false);
        },
      );
    });

    group('Bug Fix 3: Game State Updates', () {
      test('GameState should detect win condition with all green letters', () {
        // TDD: Test that win condition works when any guess has all green letters
        final gameState = GameState.newGame();

        // Add a guess with all green letters
        final craneWord = Word.fromString('CRANE');
        final craneResult = GuessResult.withStates(
          word: craneWord,
          letterStates: [
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
          ],
        );
        gameState.addGuess(craneWord, craneResult);

        expect(gameState.isWon, true);
        expect(gameState.isGameOver, true);
      });

      test('GameState should not be won with mixed letter states', () {
        // TDD: Test that mixed letter states don't trigger win
        final gameState = GameState.newGame();

        final craneWord = Word.fromString('CRANE');
        final craneResult = GuessResult.withStates(
          word: craneWord,
          letterStates: [
            LetterState.green,
            LetterState.yellow,
            LetterState.gray,
            LetterState.green,
            LetterState.gray,
          ],
        );
        gameState.addGuess(craneWord, craneResult);

        expect(gameState.isWon, false);
      });
    });
  });
}
