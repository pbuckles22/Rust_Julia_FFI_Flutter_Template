import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

/// Simple Benchmark Test - Runs directly from terminal
/// 
/// This test runs the same benchmark as Cargo but using Dart
/// to verify the Dart implementation matches the Rust performance.
void main() {
  group('Simple Benchmark Test', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      
      // Initialize benchmark solver (exactly like Cargo benchmark)
      FfiService.initializeBenchmarkSolver();
    });

    test('Simple Benchmark - 10 games like Cargo benchmark', () {
      print('🎯 Starting Simple Benchmark - 10 games');
      print('=====================================');
      
      final testWords = [
        'TRAIN', 'CRANE', 'SLATE', 'TRACE', 'CRATE', 
        'SLANT', 'LEAST', 'STARE', 'TARES', 'RAISE'
      ];
      
      final results = <GameResult>[];
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < testWords.length; i++) {
        final targetWord = testWords[i];
        final gameResult = simulateGame(targetWord, 6);
        results.add(gameResult);
        
        print('Game ${i + 1}/${testWords.length}: ${targetWord} - ${gameResult.solved ? "✅ SOLVED" : "❌ FAILED"} in ${gameResult.guessCount} guesses');
        if (gameResult.guesses.isNotEmpty) {
          print('  Guesses: ${gameResult.guesses.join(" → ")}');
        }
      }
      
      stopwatch.stop();
      
      // Calculate statistics like Cargo benchmark
      final totalGames = results.length;
      final solvedGames = results.where((r) => r.solved).length;
      final successRate = solvedGames / totalGames;
      final totalGuesses = results.fold(0, (sum, r) => sum + r.guessCount);
      final averageGuesses = totalGuesses / totalGames;
      
      print('\n📊 SIMPLE BENCHMARK RESULTS');
      print('==========================');
      print('Total games: $totalGames');
      print('Solved games: $solvedGames');
      print('Success rate: ${(successRate * 100).toStringAsFixed(1)}%');
      print('Average guesses: ${averageGuesses.toStringAsFixed(2)}');
      print('Total time: ${stopwatch.elapsedMilliseconds}ms');
      print('Time per game: ${(stopwatch.elapsedMilliseconds / totalGames).toStringAsFixed(0)}ms');
      
      // Verify we match Cargo benchmark performance
      expect(successRate, greaterThanOrEqualTo(0.9), reason: 'Should have high success rate like Cargo benchmark');
      expect(averageGuesses, lessThanOrEqualTo(4.0), reason: 'Should be efficient like Cargo benchmark');
      
      print('\n🎉 Simple benchmark completed successfully!');
      print('✅ Success rate: ${(successRate * 100).toStringAsFixed(1)}% (target: ≥90%)');
      print('✅ Average guesses: ${averageGuesses.toStringAsFixed(2)} (target: ≤4.0)');
    });
  });
}

/// Game result matching Cargo benchmark structure
class GameResult {
  final String targetWord;
  final List<String> guesses;
  final int guessCount;
  final bool solved;
  final int maxGuesses;

  GameResult({
    required this.targetWord,
    required this.guesses,
    required this.guessCount,
    required this.solved,
    required this.maxGuesses,
  });
}

/// Simulate a single game exactly like Cargo benchmark
GameResult simulateGame(String targetWord, int maxGuesses) {
  final guesses = <String>[];
  final guessResults = <(String, List<String>)>[];
  
  // Get answer words (like Cargo benchmark)
  final answerWords = FfiService.getAnswerWords();
  var remainingWords = List<String>.from(answerWords);
  
  for (int attempt = 1; attempt <= maxGuesses; attempt++) {
    // Get the best guess from our intelligent solver (exactly like Cargo benchmark)
    final candidateWords = remainingWords.isEmpty ? answerWords : remainingWords;
    final bestGuess = FfiService.getBenchmarkGuess(candidateWords, guessResults);
    
    if (bestGuess == null) {
      break; // No valid guess available
    }
    
    guesses.add(bestGuess);
    
    // Check if we solved it (like Cargo benchmark)
    if (bestGuess == targetWord) {
      return GameResult(
        targetWord: targetWord,
        guesses: guesses,
        guessCount: attempt,
        solved: true,
        maxGuesses: maxGuesses,
      );
    }
    
    // Generate feedback for this guess (like Cargo benchmark)
    final feedback = generateFeedback(bestGuess, targetWord);
    guessResults.add((bestGuess, feedback));
    
    // Filter remaining words based on feedback (exactly like Cargo benchmark)
    remainingWords = FfiService.filterBenchmarkWords(remainingWords, guessResults);
  }
  
  return GameResult(
    targetWord: targetWord,
    guesses: guesses,
    guessCount: guesses.length,
    solved: false,
    maxGuesses: maxGuesses,
  );
}

/// Generate feedback for a guess against a target word (like Cargo benchmark)
List<String> generateFeedback(String guess, String target) {
  final guessChars = guess.split('');
  final targetChars = target.split('');
  final results = List<String>.filled(5, 'X'); // Start with all gray
  
  // First pass: mark exact matches (green) - like Cargo benchmark
  for (int i = 0; i < 5; i++) {
    if (guessChars[i] == targetChars[i]) {
      results[i] = 'G';
      targetChars[i] = ' '; // Mark as used
    }
  }
  
  // Second pass: mark partial matches (yellow) - like Cargo benchmark
  for (int i = 0; i < 5; i++) {
    if (results[i] == 'X') {
      final letter = guessChars[i];
      final pos = targetChars.indexOf(letter);
      if (pos != -1) {
        results[i] = 'Y';
        targetChars[pos] = ' '; // Mark as used
      }
    }
  }
  
  return results;
}
