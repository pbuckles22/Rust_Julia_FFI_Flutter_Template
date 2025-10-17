import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('Dart Benchmark Test', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await FfiService.initialize();
    });

    test('Dart Benchmark - 10 games with debug prints', () async {
      print('🎯 Dart Benchmark Test');
      print('================================');
      
      final answerWords = FfiService.getAnswerWords();
      print('📚 Loaded ${answerWords.length} answer words');
      
      final testWords = answerWords.take(10).toList();
      print('🎯 Running 10-Game Dart Benchmark...');
      print('📊 Testing on 10 random Wordle answer words...');
      
      int totalGames = 0;
      int totalGuesses = 0;
      int wins = 0;
      final startTime = DateTime.now();
      
      for (int i = 0; i < testWords.length; i++) {
        final targetWord = testWords[i];
        print('\n🔍 DART BENCHMARK GAME ${i + 1}');
        print('  • Target word: $targetWord');
        
        final gameResult = simulateGame(targetWord, 6);
        totalGames++;
        totalGuesses += gameResult['guessCount'] as int;
        
        if (gameResult['solved'] as bool) {
          wins++;
          print('  ✅ Solved in ${gameResult['guessCount']} guesses');
        } else {
          print('  ❌ Failed to solve');
        }
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('\n📈 DART BENCHMARK REPORT');
      print('=====================================');
      print('🎯 PERFORMANCE SUMMARY');
      print('Sample Size: $totalGames words');
      print('Benchmark Duration: ${duration.inMilliseconds / 1000}s');
      print('📈 Performance Summary:');
      print('Success Rate: ${(wins / totalGames * 100).toStringAsFixed(1)}% (Human: 89.0%)');
      print('Average Guesses: ${(totalGuesses / totalGames).toStringAsFixed(2)} (Human: 4.10)');
      print('Average Speed: ${(duration.inMilliseconds / totalGames / 1000).toStringAsFixed(3)}s per game');
      print('Total Games: $totalGames');
      print('Total Time: ${duration.inMilliseconds / 1000}s');
    });
  });
}

/// Simulate a single game (exactly like Rust benchmark)
Map<String, dynamic> simulateGame(String targetWord, int maxGuesses) {
  final guesses = <String>[];
  final guessResults = <(String, List<String>)>[];
  
  for (int attempt = 1; attempt <= maxGuesses; attempt++) {
    // DEBUG: Show complete game state payload (same as Rust benchmark)
    print('🔍 DART GAME STATE PAYLOAD - Attempt $attempt');
    print('  • Target word: $targetWord');
    print('  • Total constraints: ${guessResults.length}');
    print('  • Complete payload structure:');
    print('    guess_results: Vec<(String, List<String>)> = [');
    for (int i = 0; i < guessResults.length; i++) {
      final (word, pattern) = guessResults[i];
      print('      ("$word", ${pattern}), // constraint ${i + 1}');
    }
    print('    ]');
    print('  • This is the EXACT payload passed to: FfiService.getBestGuess(guessResults)');
    
    // Get best guess using new client-server architecture
    String? bestGuess;
    if (guessResults.isEmpty) {
      print('  • First guess - using optimal first guess');
      bestGuess = FfiService.getOptimalFirstGuess();
    } else {
      print('  • Subsequent guess - using server-side algorithm');
      bestGuess = FfiService.getBestGuess(guessResults);
    }
    
    if (bestGuess == null) {
      print('  • No valid guess available');
      break;
    }
    
    print('  • Algorithm suggested: $bestGuess');
    guesses.add(bestGuess);
    
    // Check if we solved it
    if (bestGuess == targetWord) {
      return {
        'targetWord': targetWord,
        'guesses': guesses,
        'guessCount': attempt,
        'solved': true,
        'maxGuesses': maxGuesses,
      };
    }
    
    // Generate feedback for this guess
    final feedback = generateFeedback(bestGuess, targetWord);
    guessResults.add((bestGuess, feedback));
  }
  
  return {
    'targetWord': targetWord,
    'guesses': guesses,
    'guessCount': guesses.length,
    'solved': false,
    'maxGuesses': maxGuesses,
  };
}

/// Generate feedback for a guess against target word
List<String> generateFeedback(String guess, String target) {
  final guessChars = guess.split('');
  final targetChars = target.split('');
  final result = List<String>.filled(5, 'X');
  
  // First pass: mark exact matches (green)
  for (int i = 0; i < 5; i++) {
    if (guessChars[i] == targetChars[i]) {
      result[i] = 'G';
      targetChars[i] = ' '; // Mark as used
    }
  }
  
  // Second pass: mark partial matches (yellow)
  for (int i = 0; i < 5; i++) {
    if (result[i] == 'X') {
      final letter = guessChars[i];
      final targetIndex = targetChars.indexOf(letter);
      if (targetIndex != -1) {
        result[i] = 'Y';
        targetChars[targetIndex] = ' '; // Mark as used
      }
    }
  }
  
  return result;
}
