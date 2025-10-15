import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Simple Algorithm Test', () {
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

    test('Test algorithm with known target word', () async {
      // Create a game with a specific target word
      final gameState = gameService.createNewGame();
      final targetWord = gameState.targetWord!;
      
      print('🎯 Target word: ${targetWord.value}');
      
      var guesses = 0;
      var gameWon = false;
      
      while (guesses < 6 && !gameWon) {
        print('\n--- GUESS ${guesses + 1} ---');
        
        // Get intelligent guess
        final suggestion = gameService.getBestNextGuess(gameState);
        if (suggestion == null) {
          print('❌ No suggestion available!');
          break;
        }
        
        print('🤖 Algorithm suggests: ${suggestion.value}');
        
        // Simulate guess result
        final guessResult = _simulateGuessResult(suggestion, targetWord);
        print('📊 Result: ${_formatGuessResult(guessResult)}');
        
        try {
          gameState.addGuess(suggestion, guessResult);
          guesses++;
          
          // Check if won
          if (guessResult.isCorrect) {
            gameWon = true;
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
      
      // Check success
      expect(gameWon, isTrue, reason: 'Algorithm should solve the game');
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

/// Format guess result for debugging
String _formatGuessResult(GuessResult result) {
  return result.letterStates.map((state) {
    switch (state) {
      case LetterState.gray:
        return 'X';
      case LetterState.yellow:
        return 'Y';
      case LetterState.green:
        return 'G';
    }
  }).join('');
}
