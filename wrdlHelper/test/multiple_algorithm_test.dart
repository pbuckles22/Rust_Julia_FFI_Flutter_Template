import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Multiple Algorithm Test', () {
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

    test('Test algorithm with 10 random games', () async {
      var gamesWon = 0;
      var totalGuesses = 0;
      
      for (var game = 1; game <= 10; game++) {
        print('\n🎮 GAME $game');
        print('==========');
        
        // Create a new game
        final gameState = gameService.createNewGame();
        final targetWord = gameState.targetWord!;
        
        print('🎯 Target: ${targetWord.value}');
        
        var guesses = 0;
        var gameWon = false;
        
        while (guesses < 6 && !gameWon) {
          // Get intelligent guess
          final suggestion = gameService.getBestNextGuess(gameState);
          if (suggestion == null) {
            print('❌ No suggestion available!');
            break;
          }
          
          // Simulate guess result
          final guessResult = _simulateGuessResult(suggestion, targetWord);
          
          try {
            gameState.addGuess(suggestion, guessResult);
            guesses++;
            
            // Check if won
            if (guessResult.isCorrect) {
              gameWon = true;
              gamesWon++;
              print('🎉 WON in $guesses guesses!');
            }
          } catch (e) {
            print('❌ Error adding guess: $e');
            break;
          }
        }
        
        if (!gameWon) {
          print('❌ LOST - Could not solve in 6 guesses');
          print('🎯 Target was: ${targetWord.value}');
        }
        
        totalGuesses += guesses;
      }
      
      final successRate = (gamesWon / 10) * 100;
      final avgGuesses = totalGuesses / 10;
      
      print('\n📊 RESULTS');
      print('==========');
      print('Games won: $gamesWon/10');
      print('Success rate: ${successRate.toStringAsFixed(1)}%');
      print('Average guesses: ${avgGuesses.toStringAsFixed(2)}');
      
      // Check if success rate is reasonable
      expect(successRate, greaterThanOrEqualTo(80.0), 
        reason: 'Success rate should be at least 80%');
    });
  });
}

/// Simulate a guess result for debugging
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
