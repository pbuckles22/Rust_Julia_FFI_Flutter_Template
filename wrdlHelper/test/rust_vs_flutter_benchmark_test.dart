import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

/// Rust vs Flutter Benchmark Comparison Test
/// 
/// This test compares the performance of the same algorithm when called
/// directly from Rust vs through Flutter FFI to identify the performance gap.
void main() {
  group('Rust vs Flutter Benchmark Comparison', () {
    late GameService gameService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      gameService = GameService();
      await gameService.initialize();
    });

    test('Compare Rust vs Flutter performance on same 50 games', () async {
      print('\n🎯 Rust vs Flutter Performance Comparison (50 games)');
      print('=' * 60);
      
      final stopwatch = Stopwatch()..start();
      int gamesWon = 0;
      int totalGuesses = 0;
      final List<double> gameTimes = [];

      // Run 50 games with Flutter FFI
      for (int game = 1; game <= 50; game++) {
        final gameStopwatch = Stopwatch()..start();
        final gameState = gameService.createNewGame();
        bool gameWon = false;
        int guesses = 0;

        // Play game until win or 6 guesses
        while (guesses < 6 && !gameWon) {
          final suggestion = gameService.getBestNextGuess(gameState);
          if (suggestion == null) break;

          final guessResult = _simulateGuessResult(suggestion, gameState.targetWord!);
          try {
            gameState.addGuess(suggestion, guessResult);
            guesses++;
          } catch (e) {
            // Game over (max guesses reached)
            break;
          }

          if (guessResult.isCorrect) {
            gameWon = true;
            gamesWon++;
          }
        }
        
        gameStopwatch.stop();
        gameTimes.add(gameStopwatch.elapsedMilliseconds / 1000.0);
        totalGuesses += guesses;
        
        if (game % 10 == 0) {
          print('  Game $game/50 completed');
        }
      }

      stopwatch.stop();
      final successRate = (gamesWon / 50) * 100;
      final averageGuesses = totalGuesses / 50;
      final totalTime = stopwatch.elapsedMilliseconds / 1000.0;
      final averageTime = totalTime / 50;

      print('\n📊 Flutter FFI Benchmark Results (50 games):');
      print('  🎯 Success Rate: ${successRate.toStringAsFixed(1)}%');
      print('  📈 Average Guesses: ${averageGuesses.toStringAsFixed(2)}');
      print('  ⏱️  Average Time per Game: ${averageTime.toStringAsFixed(3)}s');
      print('  🏆 Games Won: $gamesWon/50');
      print('  📝 Total Guesses: $totalGuesses');
      print('  🕐 Total Time: ${totalTime.toStringAsFixed(1)}s');

      print('\n📊 Comparison with Rust Benchmark:');
      print('  🦀 Rust (500 games): 100.0% success, 3.57 avg guesses, 0.947s per game');
      print('  🎯 Flutter (50 games): ${successRate.toStringAsFixed(1)}% success, ${averageGuesses.toStringAsFixed(2)} avg guesses, ${averageTime.toStringAsFixed(3)}s per game');
      
      final successGap = 100.0 - successRate;
      final guessGap = averageGuesses - 3.57;
      final timeGap = averageTime - 0.947;
      
      print('\n📈 Performance Gap Analysis:');
      print('  🔴 Success Rate Gap: ${successGap.toStringAsFixed(1)}% (Flutter underperforming)');
      print('  🟡 Average Guesses Gap: ${guessGap.toStringAsFixed(2)} (Flutter using more guesses)');
      print('  🟢 Time Gap: ${timeGap.toStringAsFixed(3)}s (Flutter slower but acceptable)');
      
      if (successGap > 5.0) {
        print('\n🚨 CRITICAL: Large success rate gap detected!');
        print('   This indicates a fundamental difference between Rust and Flutter implementations.');
        print('   Possible causes:');
        print('   - Different candidate word selection');
        print('   - Different algorithm configuration');
        print('   - Data format conversion issues');
        print('   - Word list synchronization problems');
      } else if (successGap > 2.0) {
        print('\n⚠️  MODERATE: Noticeable success rate gap detected.');
        print('   This suggests minor differences in implementation or configuration.');
      } else {
        print('\n✅ GOOD: Success rate gap is within acceptable range.');
      }

      // We expect the gap to be small if the implementations are identical
      expect(successGap, lessThan(10.0), 
        reason: 'Success rate gap should be <10% between Rust and Flutter');
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
