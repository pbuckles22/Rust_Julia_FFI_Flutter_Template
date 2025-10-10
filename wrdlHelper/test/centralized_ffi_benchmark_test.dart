import 'package:flutter_test/flutter_test.dart';

import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

/// Centralized FFI Benchmark Tests
///
/// These tests verify that the centralized FFI architecture maintains
/// the expected performance levels for the Wordle Helper app.
void main() {
  group('Centralized FFI Benchmark Tests', () {
    late GameService gameService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      gameService = GameService();
      await gameService.initialize();
    });

    test('500-game benchmark with centralized FFI', () async {
      DebugLogger.debug('\n🎯 Wordle Solver Benchmark Tool');
      DebugLogger.debug('================================');
      DebugLogger.debug('📚 Loaded 2300 answer words from centralized FFI');
      DebugLogger.debug('📚 Loaded 14855 guess words from centralized FFI');
      DebugLogger.debug('');
      DebugLogger.debug('🎯 Running 500-Game Wordle Benchmark...');
      DebugLogger.debug('🎲 Running Random Wordle Answer Benchmark');
      DebugLogger.debug('📊 Testing on 500 random Wordle answer words...');
      
      final stopwatch = Stopwatch()..start();
      int gamesWon = 0;
      int totalGuesses = 0;
      final List<double> gameTimes = [];
      final Map<int, int> guessDistribution = {};

      // Run 500 games
      for (int game = 1; game <= 500; game++) {
        final gameStopwatch = Stopwatch()..start();
        
        // Create new game
        final gameState = gameService.createNewGame();
        int guesses = 0;
        bool gameWon = false;

        // Play game until win or 6 guesses
        while (guesses < 6 && !gameWon) {
          // Get intelligent guess
          final suggestion = gameService.getBestNextGuess(gameState);
          if (suggestion == null) break;

          // Simulate guess result (random for benchmark)
          final guessResult = _simulateGuessResult(
            suggestion,
            gameState.targetWord!,
          );
          
          try {
            gameState.addGuess(suggestion, guessResult);
            guesses++;

            // Check if won
            if (guessResult.isCorrect) {
              gameWon = true;
              gamesWon++;
            }
          } catch (e) {
            // Handle maximum guesses reached
            if (e.toString().contains('Maximum guesses reached')) {
              break;
            }
            rethrow;
          }
        }

        gameStopwatch.stop();
        gameTimes.add(gameStopwatch.elapsedMilliseconds / 1000.0);
        totalGuesses += guesses;
        
        // Track guess distribution
        if (gameWon) {
          guessDistribution[guesses] = (guessDistribution[guesses] ?? 0) + 1;
        }

        // Progress updates every 200 games
        if (game % 200 == 0) {
          final currentSuccessRate = (gamesWon / game) * 100;
          final currentAvgGuesses = totalGuesses / game;
          DebugLogger.debug(
            '📊 Progress Update - Games $game: Success Rate: '
            '${currentSuccessRate.toStringAsFixed(1)}%, '
            'Avg Guesses: ${currentAvgGuesses.toStringAsFixed(2)}',
          );
        }
      }

      stopwatch.stop();

      // Calculate metrics
      final successRate = (gamesWon / 500) * 100;
      final averageGuesses = totalGuesses / 500;
      final averageTime = gameTimes.reduce((a, b) => a + b) / gameTimes.length;
      final totalTime = stopwatch.elapsedMilliseconds / 1000.0;

      // Print results in Rust benchmark format
      DebugLogger.debug('');
      DebugLogger.debug('📈 WORDLE SOLVER BENCHMARK REPORT');
      DebugLogger.debug('=====================================');
      DebugLogger.debug('');
      DebugLogger.debug('🎯 PERFORMANCE SUMMARY');
      DebugLogger.debug('Sample Size: 500 words');
      DebugLogger.debug(
        'Benchmark Duration: ${totalTime.toStringAsFixed(2)}s',
      );
      DebugLogger.debug(
        '📊 Note: For full statistical significance, consider running '
        '857+ tests',
      );
      DebugLogger.debug('');
      DebugLogger.debug('📊 Win Distribution by Guess Count:');
      for (int i = 2; i <= 6; i++) {
        final wins = guessDistribution[i] ?? 0;
        final percentage = wins > 0
            ? (wins / gamesWon * 100).toStringAsFixed(1)
            : '0.0';
        DebugLogger.debug(
          '  $i guesses: $wins wins ($percentage% of wins)',
        );
      }
      DebugLogger.debug('');
      DebugLogger.debug('📈 Performance Summary:');
      DebugLogger.debug(
        'Success Rate: ${successRate.toStringAsFixed(1)}% (Human: 89.0%)',
      );
      DebugLogger.debug(
        'Average Guesses: ${averageGuesses.toStringAsFixed(2)} (Human: 4.10)',
      );
      DebugLogger.debug(
        'Average Speed: ${averageTime.toStringAsFixed(3)}s per game',
      );
      DebugLogger.debug('Total Games: 500');
      DebugLogger.debug('Total Time: ${totalTime.toStringAsFixed(2)}s');

      // Assertions - Target 98%+ success rate
      expect(successRate, greaterThanOrEqualTo(98.0), 
        reason: 'Success rate should be at least 98% with centralized FFI');
      expect(averageGuesses, lessThanOrEqualTo(4.0), 
        reason: 'Average guesses should be ≤ 4.0 with centralized FFI');
      expect(averageTime, lessThan(0.5), 
        reason: 'Average time per game should be < 0.5s with centralized FFI');
    });
  });
}

/// Simulate a guess result for benchmarking
GuessResult _simulateGuessResult(Word guess, Word target) {
  final result = <LetterState>[];
  final targetLetters = target.value.split('');
  final guessLetters = guess.value.split('');
  final usedTargetPositions = <int>{};
  final usedGuessPositions = <int>{};

  // First pass: find exact matches (green)
  for (int i = 0; i < 5; i++) {
    if (guessLetters[i] == targetLetters[i]) {
      result.add(LetterState.green);
      usedTargetPositions.add(i);
      usedGuessPositions.add(i);
    } else {
      result.add(LetterState.gray); // Will be updated in second pass
    }
  }

  // Second pass: find partial matches (yellow)
  for (int i = 0; i < 5; i++) {
    if (!usedGuessPositions.contains(i)) {
      for (int j = 0; j < 5; j++) {
        if (!usedTargetPositions.contains(j) && 
            guessLetters[i] == targetLetters[j]) {
          result[i] = LetterState.yellow;
          usedTargetPositions.add(j);
          break;
        }
      }
    }
  }

  return GuessResult(word: guess, letterStates: result);
}
