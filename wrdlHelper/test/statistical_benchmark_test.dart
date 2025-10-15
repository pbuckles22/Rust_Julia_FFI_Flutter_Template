import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Statistical Benchmark Tests', () {
    late GameService gameService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      gameService = GameService();
      await gameService.initialize();
    });

    tearDownAll(() {
      try {
        RustLib.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    });

    test('200-game statistical benchmark', () async {
      print('\n🎯 STATISTICAL BENCHMARK TEST');
      print('==============================');
      print('📚 Running 200 games for statistical significance');
      print('');
      
      final stopwatch = Stopwatch()..start();
      var gamesWon = 0;
      var totalGuesses = 0;
      final gameTimes = <double>[];
      final guessDistribution = <int, int>{};

      // Run 200 games for high statistical significance
      for (var game = 1; game <= 200; game++) {
        final gameStopwatch = Stopwatch()..start();
        
        // Create new game
        final gameState = gameService.createNewGame();
        var guesses = 0;
        var gameWon = false;

        // Play game until win or 6 guesses
        while (guesses < 6 && !gameWon) {
          // Get intelligent guess
          final suggestion = gameService.getBestNextGuess(gameState);
          if (suggestion == null) break;

          // Simulate guess result
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

        // Progress updates every 50 games
        if (game % 50 == 0) {
          final currentSuccessRate = (gamesWon / game) * 100;
          final currentAvgGuesses = totalGuesses / game;
          print(
            '📊 Progress Update - Games $game: Success Rate: '
            '${currentSuccessRate.toStringAsFixed(1)}%, '
            'Avg Guesses: ${currentAvgGuesses.toStringAsFixed(2)}',
          );
        }
      }

      stopwatch.stop();

      // Calculate metrics
      final successRate = (gamesWon / 200) * 100;
      final averageGuesses = totalGuesses / 200;
      final averageTime = gameTimes.reduce((a, b) => a + b) / gameTimes.length;
      final totalTime = stopwatch.elapsedMilliseconds / 1000.0;

      // Print comprehensive results
      print('');
      print('📈 STATISTICAL BENCHMARK REPORT');
      print('================================');
      print('');
      print('🎯 PERFORMANCE SUMMARY');
      print('Sample Size: 200 words');
      print(
        'Benchmark Duration: ${totalTime.toStringAsFixed(2)}s',
      );
      print(
        'Success Rate: ${successRate.toStringAsFixed(1)}% '
        '(Target: ≥98%)',
      );
      print(
        'Average Guesses: ${averageGuesses.toStringAsFixed(2)} '
        '(Target: ≤4.0)',
      );
      print(
        'Average Speed: ${averageTime.toStringAsFixed(3)}s per game',
      );
      print('');
      print('📊 GUESS DISTRIBUTION');
      for (var i = 1; i <= 6; i++) {
        final count = guessDistribution[i] ?? 0;
        final percentage = (count / 200) * 100;
        print(
          '  ${i} guess${i == 1 ? '' : 'es'}: $count games (${percentage.toStringAsFixed(1)}%)',
        );
      }
      print('');
      print('🎯 STATISTICAL SIGNIFICANCE');
      print('Sample size of 200 provides high confidence');
      print('in algorithm performance metrics.');

      // Assertions - Target 98%+ success rate
      expect(successRate, greaterThanOrEqualTo(98.0), 
        reason: 'Success rate should be at least 98% with statistical significance');
      expect(averageGuesses, lessThanOrEqualTo(4.0), 
        reason: 'Average guesses should be ≤ 4.0 with statistical significance');
      expect(averageTime, lessThan(0.5), 
        reason: 'Average time per game should be < 0.5s with statistical significance');
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

  return GuessResult(
    word: guess,
    letterStates: result,
  );
}
