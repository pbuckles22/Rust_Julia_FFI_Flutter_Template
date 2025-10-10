import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'global_test_setup.dart';

void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Real Services Tests', () {
    setUpAll(() async {
      // Initialize FFI once for all tests in this group
      await GlobalTestSetup.initializeOnce();
    });

    setUp(() {
      // Reset services for individual test isolation
      GlobalTestSetup.resetForTest();
    });

    tearDownAll(() {
      // Clean up global resources
      GlobalTestSetup.cleanup();
    });

    test('FFI Service should provide real words', () async {
      // Test that FFI service has comprehensive algorithm-testing data
      expect(
        FfiService.getGuessWords().length,
        greaterThan(200), // Comprehensive word list has ~250 words
      );
      expect(
        FfiService.getAnswerWords().length,
        greaterThan(200), // Comprehensive word list has ~250 words
      );
      expect(FfiService.isInitialized, true);

      // Test that it can validate words
      expect(FfiService.isValidWord('CRANE'), isTrue);
      expect(FfiService.isValidWord('SLATE'), isTrue);
      expect(FfiService.isValidWord('XXXXX'), isFalse);
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

      // Test that it initializes with real services (WordService removed,
      // using centralized FFI)
      expect(appService.isInitialized, true);
      expect(appService.gameService, isNotNull);
    });
  });
}
