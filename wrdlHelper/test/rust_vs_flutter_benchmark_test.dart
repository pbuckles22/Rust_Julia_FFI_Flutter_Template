import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

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
      DebugLogger.info('\n🎯 Rust vs Flutter Performance Comparison (50 games)', tag: 'Benchmark');
      DebugLogger.info('=' * 60, tag: 'Benchmark');
      
      final stopwatch = Stopwatch()..start();
      var gamesWon = 0;
      var totalGuesses = 0;
      final gameTimes = <double>[];

      // Run 50 games with Flutter FFI
      for (var game = 1; game <= 50; game++) {
        final gameStopwatch = Stopwatch()..start();
        final gameState = gameService.createNewGame();
        var gameWon = false;
        var guesses = 0;

        // Play game until win or 6 guesses
        while (guesses < 6 && !gameWon) {
          final suggestion = gameService.getBestNextGuess(gameState);
          if (suggestion == null) break;

          final guessResult = _simulateGuessResult(
            suggestion,
            gameState.targetWord!,
          );
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
          DebugLogger.info('  Game $game/50 completed', tag: 'Benchmark');
        }
      }

      stopwatch.stop();
      final successRate = (gamesWon / 50) * 100;
      final averageGuesses = totalGuesses / 50;
      final totalTime = stopwatch.elapsedMilliseconds / 1000.0;
      final averageTime = totalTime / 50;

      DebugLogger.info('\n📊 Flutter FFI Benchmark Results (50 games):', tag: 'Benchmark');
      DebugLogger.info('  🎯 Success Rate: ${successRate.toStringAsFixed(1)}%', tag: 'Benchmark');
      DebugLogger.info('  📈 Average Guesses: ${averageGuesses.toStringAsFixed(2)}', tag: 'Benchmark');
      DebugLogger.info('  ⏱️  Average Time per Game: ${averageTime.toStringAsFixed(3)}s', tag: 'Benchmark');
      DebugLogger.info('  🏆 Games Won: $gamesWon/50', tag: 'Benchmark');
      DebugLogger.info('  📝 Total Guesses: $totalGuesses', tag: 'Benchmark');
      DebugLogger.info('  🕐 Total Time: ${totalTime.toStringAsFixed(1)}s', tag: 'Benchmark');

      DebugLogger.info('\n📊 Comparison with Rust Benchmark:', tag: 'Benchmark');
      DebugLogger.info(
        '  🦀 Rust (500 games): 100.0% success, 3.57 avg guesses, '
        '0.947s per game',
        tag: 'Benchmark',
      );
      DebugLogger.info(
        '  🎯 Flutter (50 games): ${successRate.toStringAsFixed(1)}% success, '
        '${averageGuesses.toStringAsFixed(2)} avg guesses, '
        '${averageTime.toStringAsFixed(3)}s per game',
        tag: 'Benchmark',
      );
      
      final successGap = 100.0 - successRate;
      final guessGap = averageGuesses - 3.57;
      final timeGap = averageTime - 0.947;
      
      DebugLogger.info('\n📈 Performance Gap Analysis:', tag: 'Benchmark');
      DebugLogger.info(
        '  🔴 Success Rate Gap: ${successGap.toStringAsFixed(1)}% '
        '(Flutter underperforming)',
        tag: 'Benchmark',
      );
      DebugLogger.info(
        '  🟡 Average Guesses Gap: ${guessGap.toStringAsFixed(2)} '
        '(Flutter using more guesses)',
        tag: 'Benchmark',
      );
      DebugLogger.info(
        '  🟢 Time Gap: ${timeGap.toStringAsFixed(3)}s '
        '(Flutter slower but acceptable)',
        tag: 'Benchmark',
      );
      
      if (successGap > 5.0) {
        DebugLogger.warning('\n🚨 CRITICAL: Large success rate gap detected!', tag: 'Benchmark');
        DebugLogger.warning(
          '   This indicates a fundamental difference between Rust and '
          'Flutter implementations.',
          tag: 'Benchmark',
        );
        DebugLogger.warning('   Possible causes:', tag: 'Benchmark');
        DebugLogger.warning('   - Different candidate word selection', tag: 'Benchmark');
        DebugLogger.warning('   - Different algorithm configuration', tag: 'Benchmark');
        DebugLogger.warning('   - Data format conversion issues', tag: 'Benchmark');
        DebugLogger.warning('   - Word list synchronization problems', tag: 'Benchmark');
      } else if (successGap > 2.0) {
        DebugLogger.warning('\n⚠️  MODERATE: Noticeable success rate gap detected.', tag: 'Benchmark');
        DebugLogger.warning(
          '   This suggests minor differences in implementation or '
          'configuration.',
          tag: 'Benchmark',
        );
      } else {
        DebugLogger.info('\n✅ GOOD: Success rate gap is within acceptable range.', tag: 'Benchmark');
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
  for (var i = 0; i < 5; i++) {
    if (guessLetters[i] == targetLetters[i]) {
      result.add(LetterState.green);
      usedTargetPositions.add(i);
      usedGuessPositions.add(i);
    } else {
      result.add(LetterState.gray); // Will be updated in second pass
    }
  }

  // Second pass: find partial matches (yellow)
  for (var i = 0; i < 5; i++) {
    if (!usedGuessPositions.contains(i)) {
      for (var j = 0; j < 5; j++) {
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
