import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

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

    test('100-game benchmark with centralized FFI', () async {
      print('\n🎯 Starting 100-game benchmark with centralized FFI...');
      
      final stopwatch = Stopwatch()..start();
      int gamesWon = 0;
      int totalGuesses = 0;
      final List<double> gameTimes = [];

      // Run 100 games
      for (int game = 1; game <= 100; game++) {
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
          final guessResult = _simulateGuessResult(suggestion, gameState.targetWord!);
          
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

        if (game % 10 == 0) {
          print('  Game $game/100 completed');
        }
      }

      stopwatch.stop();

      // Calculate metrics
      final successRate = (gamesWon / 100) * 100;
      final averageGuesses = totalGuesses / 100;
      final averageTime = gameTimes.reduce((a, b) => a + b) / gameTimes.length;
      final totalTime = stopwatch.elapsedMilliseconds / 1000.0;

      // Print results
      print('\n📊 Centralized FFI Benchmark Results (100 games):');
      print('  🎯 Success Rate: ${successRate.toStringAsFixed(1)}%');
      print('  📈 Average Guesses: ${averageGuesses.toStringAsFixed(2)}');
      print('  ⏱️  Average Time per Game: ${averageTime.toStringAsFixed(3)}s');
      print('  🕐 Total Time: ${totalTime.toStringAsFixed(1)}s');
      print('  🏆 Games Won: $gamesWon/100');
      print('  📝 Total Guesses: $totalGuesses');

      // Assertions
      expect(successRate, greaterThanOrEqualTo(90.0), 
        reason: 'Success rate should be at least 90% with centralized FFI');
      expect(averageGuesses, lessThanOrEqualTo(4.5), 
        reason: 'Average guesses should be ≤ 4.5 with centralized FFI');
      expect(averageTime, lessThan(2.0), 
        reason: 'Average time per game should be < 2s with centralized FFI');
      expect(totalTime, lessThan(300.0), 
        reason: 'Total time for 100 games should be < 300s with centralized FFI');
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
