import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Debug GameService FFI Tests', () {
    late GameService gameService;
    late WordService wordService;

    setUpAll(() async {
      // Initialize FFI
      try {
        await RustLib.init();
        print('✅ FFI initialized successfully');
      } catch (e) {
        print('❌ FFI initialization failed: $e');
        rethrow;
      }
    });

    setUp(() async {
      // Initialize services
      wordService = WordService();
      await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
      await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      await wordService.loadAnswerWords('assets/word_lists/official_wordle_words.json');

      gameService = GameService(wordService: wordService);
      await gameService.initialize();
    });

    test('should create new game without hanging', () {
      // This should not hang
      final gameState = gameService.createNewGame();
      expect(gameState, isNotNull);
      expect(gameState.targetWord, isNotNull);
      expect(gameState.guesses, isEmpty);
    });

    test('should get best next guess without hanging', () {
      // Create a game
      final gameState = gameService.createNewGame();
      
      // This is where it might hang - let's test it
      final suggestion = gameService.getBestNextGuess(gameState);
      
      // If we get here, it didn't hang
      expect(suggestion, isNotNull);
    });

    test('should suggest next guess without hanging', () {
      // Create a game
      final gameState = gameService.createNewGame();
      
      // This calls getBestNextGuess internally
      final suggestion = gameService.suggestNextGuess(gameState);
      
      // If we get here, it didn't hang
      expect(suggestion, isNotNull);
    });
  });
}
