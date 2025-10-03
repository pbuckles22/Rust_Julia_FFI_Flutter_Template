import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/word_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'dart:math';

void main() {
  group('Game Simulation Benchmark Tests', () {
    late WordService wordService;
    late List<String> answerWords;
    late List<String> guessWords;
    
    setUpAll(() async {
      // Initialize Flutter binding for asset loading
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize FFI once
      await RustLib.init();
      await FfiService.initialize();
      
      // For benchmarking, use full production word lists, not test word lists
      wordService = WordService();
      
      // Load full production word lists for accurate benchmarking
      await wordService.loadWordList('assets/word_lists/official_wordle_words.json');
      await wordService.loadGuessWords('assets/word_lists/official_guess_words.txt');
      await wordService.loadAnswerWords('assets/word_lists/official_wordle_words.json');
      
      // Load full word lists to Rust for benchmarking
      FfiService.loadWordListsToRust(
        wordService.answerWords.map((w) => w.value).toList(),
        wordService.guessWords.map((w) => w.value).toList(),
      );
      
      // Get word lists for simulation
      answerWords = wordService.answerWords.map((w) => w.value).toList();
      guessWords = wordService.guessWords.map((w) => w.value).toList();
    });

    test('Benchmark: Simulate 100 games to test optimized performance', () {
      print('\n🎮 Starting Game Simulation Benchmark...');
      print('📊 Testing with ${answerWords.length} answer words and ${guessWords.length} guess words');
      
      final results = <GameResult>[];
      final stopwatch = Stopwatch()..start();
      
      // Simulate 100 games for quick performance test
      for (int i = 0; i < 100; i++) {
        final targetWord = answerWords[Random().nextInt(answerWords.length)];
        final gameResult = simulateGame(targetWord, guessWords);
        results.add(gameResult);
        
        if (i % 10 == 0) {
          print('🎯 Completed ${i + 1}/100 games...');
        }
      }
      
      stopwatch.stop();
      
      // Calculate statistics
      final wonGames = results.where((r) => r.won).length;
      final successRate = (wonGames / results.length) * 100;
      final averageGuesses = results.map((r) => r.guessCount).reduce((a, b) => a + b) / results.length;
      final averageTime = stopwatch.elapsedMilliseconds / results.length;
      
      // Performance analysis
      final fastGames = results.where((r) => r.totalTime < 200).length;
      final performanceRate = (fastGames / results.length) * 100;
      
      print('\n📈 BENCHMARK RESULTS:');
      print('=' * 50);
      print('🎯 Success Rate: ${successRate.toStringAsFixed(1)}% (${wonGames}/${results.length})');
      print('📊 Average Guesses: ${averageGuesses.toStringAsFixed(2)}');
      print('⏱️  Average Time per Game: ${averageTime.toStringAsFixed(1)}ms');
      print('🚀 Performance Rate (<200ms): ${performanceRate.toStringAsFixed(1)}%');
      print('⏱️  Total Benchmark Time: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s');
      
      // Distribution analysis
      final guessDistribution = <int, int>{};
      for (final result in results) {
        guessDistribution[result.guessCount] = (guessDistribution[result.guessCount] ?? 0) + 1;
      }
      
      print('\n📊 Guess Distribution:');
      for (int i = 1; i <= 6; i++) {
        final count = guessDistribution[i] ?? 0;
        final percentage = (count / results.length) * 100;
        print('  ${i} guesses: ${count} games (${percentage.toStringAsFixed(1)}%)');
      }
      
      // Performance targets validation
      print('\n🎯 TARGET VALIDATION:');
      print('✅ Success Rate Target: 99.8% | Actual: ${successRate.toStringAsFixed(1)}% | ${successRate >= 99.8 ? 'PASS' : 'FAIL'}');
      print('✅ Average Guesses Target: 3.66 | Actual: ${averageGuesses.toStringAsFixed(2)} | ${averageGuesses <= 3.66 ? 'PASS' : 'FAIL'}');
      print('✅ Response Time Target: <200ms | Actual: ${averageTime.toStringAsFixed(1)}ms | ${averageTime < 200 ? 'PASS' : 'FAIL'}');
      
      // Test assertions for 500-game benchmark
      expect(successRate, greaterThanOrEqualTo(95.0), reason: 'Success rate should be at least 95%');
      expect(averageGuesses, lessThanOrEqualTo(4.5), reason: 'Average guesses should be at most 4.5');
      expect(averageTime, lessThan(2000), reason: 'Average response time should be less than 2000ms');
    });

    test('Benchmark: Stress test with 50 games using full word list', () {
      print('\n🔥 Starting Stress Test Benchmark...');
      
      // Load full word list for stress test
      final fullAnswerWords = wordService.answerWords.map((w) => w.value).toList();
      final fullGuessWords = wordService.guessWords.map((w) => w.value).toList();
      
      print('📊 Stress testing with ${fullAnswerWords.length} answer words and ${fullGuessWords.length} guess words');
      
      final results = <GameResult>[];
      final stopwatch = Stopwatch()..start();
      
      // Simulate 50 games with full word list
      for (int i = 0; i < 50; i++) {
        final targetWord = fullAnswerWords[Random().nextInt(fullAnswerWords.length)];
        final gameResult = simulateGame(targetWord, fullGuessWords);
        results.add(gameResult);
        
        if (i % 10 == 0) {
          print('🎯 Completed ${i + 1}/50 stress test games...');
        }
      }
      
      stopwatch.stop();
      
      // Calculate statistics
      final wonGames = results.where((r) => r.won).length;
      final successRate = (wonGames / results.length) * 100;
      final averageGuesses = results.map((r) => r.guessCount).reduce((a, b) => a + b) / results.length;
      final averageTime = stopwatch.elapsedMilliseconds / results.length;
      
      print('\n🔥 STRESS TEST RESULTS:');
      print('=' * 50);
      print('🎯 Success Rate: ${successRate.toStringAsFixed(1)}% (${wonGames}/${results.length})');
      print('📊 Average Guesses: ${averageGuesses.toStringAsFixed(2)}');
      print('⏱️  Average Time per Game: ${averageTime.toStringAsFixed(1)}ms');
      print('⏱️  Total Stress Test Time: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s');
      
      // Stress test assertions (more lenient)
      expect(successRate, greaterThanOrEqualTo(90.0), reason: 'Stress test success rate should be at least 90%');
      expect(averageGuesses, lessThanOrEqualTo(5.0), reason: 'Stress test average guesses should be at most 5.0');
      expect(averageTime, lessThan(500), reason: 'Stress test average response time should be less than 500ms');
    });
  });
}

class GameResult {
  final String targetWord;
  final bool won;
  final int guessCount;
  final int totalTime;
  final List<String> guesses;
  
  GameResult({
    required this.targetWord,
    required this.won,
    required this.guessCount,
    required this.totalTime,
    required this.guesses,
  });
}

GameResult simulateGame(String targetWord, List<String> availableWords) {
  final gameStopwatch = Stopwatch()..start();
  final guesses = <String>[];
  final guessResults = <(String, List<String>)>[];
  var remainingWords = List<String>.from(availableWords);
  
  for (int attempt = 1; attempt <= 6; attempt++) {
    // Get intelligent guess
    final guess = FfiService.getBestGuessFast(remainingWords, guessResults);
    if (guess == null) break;
    
    guesses.add(guess);
    
    // Check if we won
    if (guess == targetWord) {
      gameStopwatch.stop();
      return GameResult(
        targetWord: targetWord,
        won: true,
        guessCount: attempt,
        totalTime: gameStopwatch.elapsedMilliseconds,
        guesses: guesses,
      );
    }
    
    // Simulate guess result
    final pattern = FfiService.simulateGuessPattern(guess, targetWord);
    final patternList = pattern.split('').map((c) => c == 'G' ? 'G' : c == 'Y' ? 'Y' : 'X').toList();
    guessResults.add((guess, patternList));
    
    // Filter remaining words
    remainingWords = FfiService.filterWords(remainingWords, guessResults);
    
    // If no words left, we can't continue
    if (remainingWords.isEmpty) break;
  }
  
  gameStopwatch.stop();
  return GameResult(
    targetWord: targetWord,
    won: false,
    guessCount: guesses.length,
    totalTime: gameStopwatch.elapsedMilliseconds,
    guesses: guesses,
  );
}
