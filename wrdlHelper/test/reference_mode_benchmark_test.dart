import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/services/word_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'dart:math';

void main() {
  group('Reference Mode Benchmark Tests', () {
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

    test('Reference Mode: Simulate 100 games with reference configuration', () {
      print('\n🎮 Starting Reference Mode Benchmark...');
      print('📊 Testing with ${answerWords.length} answer words and ${guessWords.length} guess words');
      
      // Apply reference mode configuration
      FfiService.applyReferenceModePreset();
      final config = FfiService.getConfiguration();
      print('🔧 Configuration: referenceMode=${config.referenceMode}, includeKillerWords=${config.includeKillerWords}, candidateCap=${config.candidateCap}, entropyOnlyScoring=${config.entropyOnlyScoring}');
      
      final results = <GameResult>[];
      final stopwatch = Stopwatch()..start();
      
      // Simulate 100 games for quick performance test
      for (int i = 0; i < 100; i++) {
        final targetWord = answerWords[Random().nextInt(answerWords.length)];
        final gameResult = simulateGame(targetWord, guessWords);
        results.add(gameResult);
        
        if ((i + 1) % 10 == 0) {
          print('🎯 Completed ${i + 1}/100 games...');
        }
      }
      
      stopwatch.stop();
      
      // Calculate metrics
      final successfulGames = results.where((r) => r.solved).length;
      final successRate = (successfulGames / results.length) * 100;
      final averageGuesses = results.map((r) => r.guessCount).reduce((a, b) => a + b) / results.length;
      final averageTime = results.map((r) => r.totalTime).reduce((a, b) => a + b) / results.length;
      final fastGames = results.where((r) => r.totalTime < 200).length;
      final performanceRate = (fastGames / results.length) * 100;
      
      print('\n📈 REFERENCE MODE BENCHMARK RESULTS:');
      print('==================================================');
      print('🎯 Success Rate: ${successRate.toStringAsFixed(1)}% (${successfulGames}/${results.length})');
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
      
      // Test assertions for reference mode (more lenient than final targets)
      expect(successRate, greaterThanOrEqualTo(95.0), reason: 'Reference mode success rate should be at least 95%');
      expect(averageGuesses, lessThanOrEqualTo(4.5), reason: 'Reference mode average guesses should be at most 4.5');
      expect(averageTime, lessThan(2000), reason: 'Reference mode response time should be less than 2000ms');
    });
  });
}

class GameResult {
  final String targetWord;
  final bool solved;
  final int guessCount;
  final double totalTime;
  final List<String> guesses;

  GameResult({
    required this.targetWord,
    required this.solved,
    required this.guessCount,
    required this.totalTime,
    required this.guesses,
  });
}

GameResult simulateGame(String targetWord, List<String> guessWords) {
  final stopwatch = Stopwatch()..start();
  final guesses = <String>[];
  final guessResults = <(String, List<String>)>[];
  final remainingWords = List<String>.from(guessWords);
  
  for (int attempt = 1; attempt <= 6; attempt++) {
    // Get best guess from remaining words
    final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
    
    if (bestGuess == null) {
      break;
    }
    
    guesses.add(bestGuess);
    
    // Check if we won
    if (bestGuess == targetWord) {
      stopwatch.stop();
      return GameResult(
        targetWord: targetWord,
        solved: true,
        guessCount: attempt,
        totalTime: stopwatch.elapsedMicroseconds / 1000.0,
        guesses: guesses,
      );
    }
    
    // Generate pattern for this guess
    final pattern = generatePattern(bestGuess, targetWord);
    guessResults.add((bestGuess, pattern));
    
    // Filter remaining words based on pattern
    remainingWords.removeWhere((word) => !matchesPattern(word, bestGuess, pattern));
  }
  
  stopwatch.stop();
  return GameResult(
    targetWord: targetWord,
    solved: false,
    guessCount: 6,
    totalTime: stopwatch.elapsedMicroseconds / 1000.0,
    guesses: guesses,
  );
}

List<String> generatePattern(String guess, String target) {
  final pattern = <String>[];
  final targetChars = target.split('');
  final guessChars = guess.split('');
  final used = List<bool>.filled(5, false);
  
  // First pass: mark greens
  for (int i = 0; i < 5; i++) {
    if (guessChars[i] == targetChars[i]) {
      pattern.add('G');
      used[i] = true;
    } else {
      pattern.add('X');
    }
  }
  
  // Second pass: mark yellows
  for (int i = 0; i < 5; i++) {
    if (pattern[i] == 'G') continue;
    
    for (int j = 0; j < 5; j++) {
      if (!used[j] && guessChars[i] == targetChars[j]) {
        pattern[i] = 'Y';
        used[j] = true;
        break;
      }
    }
  }
  
  return pattern;
}

bool matchesPattern(String word, String guess, List<String> pattern) {
  final wordChars = word.split('');
  final guessChars = guess.split('');
  
  // Check greens
  for (int i = 0; i < 5; i++) {
    if (pattern[i] == 'G' && wordChars[i] != guessChars[i]) {
      return false;
    }
  }
  
  // Check yellows
  for (int i = 0; i < 5; i++) {
    if (pattern[i] == 'Y') {
      if (wordChars[i] == guessChars[i]) {
        return false; // Can't be in same position
      }
      if (!wordChars.contains(guessChars[i])) {
        return false; // Must contain the letter
      }
    }
  }
  
  // Check grays (simplified - doesn't handle duplicates perfectly)
  for (int i = 0; i < 5; i++) {
    if (pattern[i] == 'X') {
      // Check if this letter appears as green or yellow elsewhere
      bool appearsElsewhere = false;
      for (int j = 0; j < 5; j++) {
        if (i != j && (pattern[j] == 'G' || pattern[j] == 'Y') && guessChars[j] == guessChars[i]) {
          appearsElsewhere = true;
          break;
        }
      }
      
      if (!appearsElsewhere && wordChars.contains(guessChars[i])) {
        return false;
      }
    }
  }
  
  return true;
}
