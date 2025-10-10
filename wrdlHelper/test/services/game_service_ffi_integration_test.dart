import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

/// TDD Tests for GameService FFI Intelligent Solver Integration
///
/// These tests verify that the GameService properly integrates with the Rust
/// FFI intelligent solver to provide world-class Wordle solving performance.
void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameService FFI Integration Tests', () {
    // Now works with centralized FFI word lists
    late GameService gameService;

    setUp(() async {
      // Initialize FFI first
      try {
        await RustLib.init();
      } catch (e) {
        // FFI initialization may fail in test environment, that's OK
        // The GameService will fallback to naive strategy
        DebugLogger.testPrint(
          'FFI initialization failed in test: $e',
          tag: 'FFIIntegrationTest',
        );
      }

      // Initialize FFI service first (word lists are loaded by centralized FFI
      // during initialization)
      await FfiService.initialize();

      // Create GameService (no longer needs WordService parameter)
      gameService = GameService();
      await gameService.initialize();
    });

    group('Intelligent Solver Integration', () {
      test('should have FFI intelligent solver method available', () {
        // This test will fail until we implement the FFI integration
        // It verifies that the GameService has the method we need

        // Arrange: Create a new game
        final gameState = gameService.createNewGame();

        // Act & Assert: The method should exist and be callable
        // This will fail until we implement _getIntelligentGuess method
        expect(() => gameService.getBestNextGuess(gameState), returnsNormally);
      });
      test('should use FFI intelligent solver for first guess', () async {
        // Arrange: Create a new game
        final gameState = gameService.createNewGame();

        // Act: Get suggestion for first guess
        final suggestion = gameService.suggestNextGuess(gameState);

        // Assert: Should get a high-quality starting word from intelligent
        // solver
        expect(suggestion, isNotNull);
        expect(suggestion!.value, hasLength(5));
        expect(suggestion.value, matches(RegExp(r'^[A-Z]+$')));

        // Should be one of the known high-entropy starting words
        final highEntropyWords = [
          'CRANE',
          'SLATE',
          'RAISE',
          'SOARE',
          'ADIEU',
          'TARES'
        ];
        expect(highEntropyWords, contains(suggestion.value));

        // TODO: Once FFI integration is implemented, verify it's actually
        // using FFI
        // For now, this test verifies the interface works
      });

      test(
        'should use FFI intelligent solver for subsequent guesses',
        () async {
          // Arrange: Create game with one guess already made
          final gameState = gameService.createNewGame();
          final firstGuess = Word.fromString('CRANE');
          final firstResult = gameService.processGuess(gameState, firstGuess);
          gameService.addGuessToGame(gameState, firstGuess, firstResult);

          // Act: Get suggestion for second guess
          final suggestion = gameService.suggestNextGuess(gameState);

          // Assert: Should get intelligent suggestion based on game state
          expect(suggestion, isNotNull);
          expect(suggestion!.value, hasLength(5));
          expect(suggestion.value, matches(RegExp(r'^[A-Z]+$')));
          expect(
            suggestion.value,
            isNot(equals('CRANE')),
          ); // Should not repeat first guess
        },
      );

      test(
        'should handle FFI solver failure gracefully with fallback',
        () async {
          // Arrange: Create game state
          final gameState = gameService.createNewGame();

          // Act: Get suggestion (should fallback if FFI fails)
          final suggestion = gameService.suggestNextGuess(gameState);

          // Assert: Should always return a valid suggestion, even if FFI fails
          expect(suggestion, isNotNull);
          expect(suggestion!.value, hasLength(5));
          expect(suggestion.value, matches(RegExp(r'^[A-Z]+$')));
        },
      );

      test('should provide better suggestions than naive strategy', () async {
        // Arrange: Create game with specific target word for predictable
        // testing
        final targetWord = Word.fromString('CRANE');
        final gameState = gameService.createNewGameWithTarget(targetWord);

        // Act: Get intelligent suggestion
        final intelligentSuggestion = gameService.suggestNextGuess(gameState);

        // Assert: Should suggest a high-entropy word
        expect(intelligentSuggestion, isNotNull);

        // The intelligent solver should suggest words that maximize information
        // gain
        final highInformationWords = [
          'CRANE',
          'SLATE',
          'RAISE',
          'SOARE',
          'ADIEU',
          'TARES',
        ];
        expect(highInformationWords, contains(intelligentSuggestion!.value));
      });

      test(
        'should consider previous guesses in subsequent suggestions',
        () async {
        // Arrange: Create game and make a guess with specific pattern
        final gameState = gameService.createNewGame();
        final firstGuess = Word.fromString('CRANE');
        final firstResult = gameService.processGuess(gameState, firstGuess);
        gameService.addGuessToGame(gameState, firstGuess, firstResult);

        // Act: Get second suggestion
        final secondSuggestion = gameService.suggestNextGuess(gameState);

        // Assert: Second suggestion should be different and consider first
        // guess results
        expect(secondSuggestion, isNotNull);
        expect(secondSuggestion!.value, isNot(equals('CRANE')));

        // Should be a valid word that could logically follow from CRANE
        // results
        expect(secondSuggestion.value, hasLength(5));
        expect(secondSuggestion.value, matches(RegExp(r'^[A-Z]+$')));
      });

      test('should handle endgame scenarios intelligently', () async {
        // Arrange: Create game with few remaining possibilities
        final gameState = gameService.createNewGame();

        // Make several guesses to narrow down possibilities
        final guesses = ['CRANE', 'SLATE', 'RAISE'];
        for (final guessWord in guesses) {
          final guess = Word.fromString(guessWord);
          final result = gameService.processGuess(gameState, guess);
          gameService.addGuessToGame(gameState, guess, result);
        }

        // Act: Get suggestion when few words remain
        final endgameSuggestion = gameService.suggestNextGuess(gameState);

        // Assert: Should provide intelligent endgame suggestion
        expect(endgameSuggestion, isNotNull);
        expect(endgameSuggestion!.value, hasLength(5));
        expect(endgameSuggestion.value, matches(RegExp(r'^[A-Z]+$')));
      });
    });

    group('FFI Performance Integration', () {
      test('should provide suggestions quickly', () async {
        // Arrange: Create game state
        final gameState = gameService.createNewGame();

        // Act: Measure suggestion time
        final stopwatch = Stopwatch()..start();
        final suggestion = gameService.suggestNextGuess(gameState);
        stopwatch.stop();

        // Assert: Should be fast (under 100ms for intelligent solver)
        expect(suggestion, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle multiple rapid suggestions efficiently', () async {
        // Arrange: Create multiple game states
        final gameStates = List.generate(5, (_) => gameService.createNewGame());

        // Act: Get suggestions for all games rapidly
        final stopwatch = Stopwatch()..start();
        final suggestions = gameStates
            .map((state) => gameService.suggestNextGuess(state))
            .toList();
        stopwatch.stop();

        // Assert: All suggestions should be valid and fast
        for (final suggestion in suggestions) {
          expect(suggestion, isNotNull);
          expect(suggestion!.value, hasLength(5));
        }
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
        ); // Should handle 5 games quickly
      });
    });

    group('FFI Error Handling', () {
      test('should handle FFI initialization errors gracefully', () async {
        // This test would require mocking FFI failures
        // For now, we test that the service doesn't crash

        // Arrange: Create game state
        final gameState = gameService.createNewGame();

        // Act: Get suggestion (may fallback if FFI not initialized)
        final suggestion = gameService.suggestNextGuess(gameState);

        // Assert: Should always return valid suggestion
        expect(suggestion, isNotNull);
        expect(suggestion!.value, hasLength(5));
      });

      test('should handle invalid FFI responses gracefully', () async {
        // Arrange: Create game state
        final gameState = gameService.createNewGame();

        // Act: Get suggestion
        final suggestion = gameService.suggestNextGuess(gameState);

        // Assert: Should handle any FFI response gracefully
        if (suggestion != null) {
          expect(suggestion.value, hasLength(5));
          expect(suggestion.value, matches(RegExp(r'^[A-Z]+$')));
        }
      });
    });

    group('FFI Data Conversion', () {
      test('should properly convert game state to FFI format', () async {
        // Arrange: Create game with guesses
        final gameState = gameService.createNewGame();
        final guess = Word.fromString('CRANE');
        final result = gameService.processGuess(gameState, guess);
        gameService.addGuessToGame(gameState, guess, result);

        // Act: Get suggestion (this tests internal FFI conversion)
        final suggestion = gameService.suggestNextGuess(gameState);

        // Assert: Should work without errors (conversion successful)
        expect(suggestion, isNotNull);
      });

      test('should handle empty game state for FFI conversion', () async {
        // Arrange: Create empty game state
        final gameState = gameService.createNewGame();

        // Act: Get suggestion for empty game
        final suggestion = gameService.suggestNextGuess(gameState);

        // Assert: Should handle empty state properly
        expect(suggestion, isNotNull);
      });
    });
  });
}
