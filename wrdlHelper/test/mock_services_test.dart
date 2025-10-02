import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';

void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Real Services Tests', () {
    setUp(() async {
      // Reset services and setup real services for testing
      resetAllServices();
      await setupServices();
    });

    test('WordService should provide real words', () async {
      // Get the real word service
      final wordService = sl<WordService>();

      // Test that it has real data
      expect(wordService.guessWords.length, greaterThan(10000));
      expect(wordService.answerWords.length, greaterThan(2000));
      expect(wordService.isGuessWordsLoaded, true);
      expect(wordService.isLoaded, true);

      // Test that it can find words
      final crane = wordService.findWord('CRANE');
      expect(crane, isNotNull);
      expect(crane!.value, 'CRANE');
    });

    test('GameService should create games', () async {
      // Set up real services

      // Get the real game service
      final gameService = sl<GameService>();

      // Test that it can create a new game
      final gameState = gameService.createNewGame();
      expect(gameState, isNotNull);
      expect(gameState.maxGuesses, 5);

      // Test that it can suggest guesses (now using real intelligent solver)
      final suggestion = gameService.suggestNextGuess(gameState);
      expect(suggestion, isNotNull);
      // Real solver should return an optimal word, not hardcoded CRANE
      expect(suggestion!.value.length, 5);
    });

    test('AppService should initialize with real services', () async {
      // Get the real app service
      final appService = sl<AppService>();

      // Test that it initializes with real services
      expect(appService.isInitialized, true);
      expect(appService.wordService.isLoaded, true);
      expect(appService.gameService, isNotNull);
    });
  });
}
