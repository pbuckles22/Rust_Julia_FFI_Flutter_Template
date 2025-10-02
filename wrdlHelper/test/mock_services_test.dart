import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';

void main() {
  group('Mock Services Tests', () {
    test('MockWordService should provide mock words', () {
      // Set up mock services
      setupMockServices();

      // Get the mock word service
      final wordService = sl<WordService>();

      // Test that it has mock data
      expect(wordService.guessWords.length, greaterThan(0));
      expect(wordService.answerWords.length, greaterThan(0));
      expect(wordService.isGuessWordsLoaded, true);
      expect(wordService.isLoaded, true);

      // Test that it can find words
      final crane = wordService.findWord('CRANE');
      expect(crane, isNotNull);
      expect(crane!.value, 'CRANE');
    });

    test('MockGameService should create games', () {
      // Set up mock services
      setupMockServices();

      // Get the mock game service
      final gameService = sl<GameService>();

      // Test that it can create a new game
      final gameState = gameService.createNewGame();
      expect(gameState, isNotNull);
      expect(gameState.maxGuesses, 5);

      // Test that it can suggest guesses
      final suggestion = gameService.suggestNextGuess(gameState);
      expect(suggestion, isNotNull);
      expect(suggestion!.value, 'CRANE');
    });

    test('MockAppService should initialize instantly', () async {
      // Set up mock services
      setupMockServices();

      // Get the mock app service
      final appService = sl<AppService>();

      // Test that it initializes instantly (no hanging)
      final stopwatch = Stopwatch()..start();
      await appService.initialize();
      stopwatch.stop();

      expect(appService.isInitialized, true);
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be instant
    });
  });
}
