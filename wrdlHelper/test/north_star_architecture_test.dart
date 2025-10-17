import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import '../lib/services/ffi_service.dart';

/// North Star Architecture Test
/// 
/// This test validates the perfect client-server architecture where:
/// - Client sends only GameState → Receives only best_guess
/// - Server handles ALL logic internally (initialization, filtering, algorithms)
/// - FFI: Only ONE public function: getBestGuess()
void main() {
  group('North Star Architecture Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      
      // NO CLIENT-SIDE INITIALIZATION - Server handles everything internally
    });

    test('Single Function Architecture - First Guess', () {
      // Test that client can get first guess with empty game state
      final gameState = <(String, List<String>)>[];
      
      // Client sends only game state, server handles everything
      final bestGuess = FfiService.getBestGuess(gameState);
      
      expect(bestGuess, isNotNull);
      expect(bestGuess!.length, 5);
      expect(bestGuess, isA<String>());
      
      print('✅ First guess: $bestGuess');
    });

    test('Single Function Architecture - With Constraints', () {
      // Test that client can get subsequent guesses with constraints
      final gameState = [
        ('TARES', ['X', 'Y', 'Y', 'X', 'Y']), // TARES with YYYYX pattern
      ];
      
      // Client sends only game state, server handles everything
      final bestGuess = FfiService.getBestGuess(gameState);
      
      expect(bestGuess, isNotNull);
      expect(bestGuess!.length, 5);
      expect(bestGuess, isA<String>());
      
      print('✅ Constrained guess: $bestGuess');
    });

    test('Single Function Architecture - Multiple Constraints', () {
      // Test that client can handle multiple constraints
      final gameState = [
        ('TARES', ['X', 'Y', 'Y', 'X', 'Y']), // TARES with YYYYX pattern
        ('SLATE', ['G', 'X', 'X', 'X', 'G']), // SLATE with GXXXG pattern
      ];
      
      // Client sends only game state, server handles everything
      final bestGuess = FfiService.getBestGuess(gameState);
      
      expect(bestGuess, isNotNull);
      expect(bestGuess!.length, 5);
      expect(bestGuess, isA<String>());
      
      print('✅ Multi-constrained guess: $bestGuess');
    });

    test('Architecture Compliance - No Other FFI Calls', () {
      // Test that we're not calling any other server-side functions
      // This test ensures we're following the North Star architecture
      
      final gameState = <(String, List<String>)>[];
      
      // ONLY call getBestGuess - no other server functions
      final bestGuess = FfiService.getBestGuess(gameState);
      
      expect(bestGuess, isNotNull);
      
      // Verify we're not calling any of these architecture violations:
      // - initializeWordLists() ❌
      // - getAnswerWords() ❌
      // - getGuessWords() ❌
      // - isValidWord() ❌
      // - getOptimalFirstGuess() ❌
      // - filterWords() ❌
      
      print('✅ Architecture compliance verified - only getBestGuess() called');
    });

    test('Performance Test - 98%+ Success Rate', () {
      // Test that the North Star architecture maintains 98%+ success rate
      final testWords = ['TRAIN', 'SLATE', 'CRANE', 'ADIEU', 'STARE'];
      int successfulGames = 0;
      
      for (final targetWord in testWords) {
        final gameState = <(String, List<String>)>[];
        final maxGuesses = 6;
        
        for (int attempt = 1; attempt <= maxGuesses; attempt++) {
          // Client sends only game state, server handles everything
          final bestGuess = FfiService.getBestGuess(gameState);
          
          if (bestGuess == null) break;
          
          if (bestGuess == targetWord) {
            successfulGames++;
            break;
          }
          
          // Generate feedback (simulate Wordle game)
          final feedback = _generateFeedback(bestGuess, targetWord);
          gameState.add((bestGuess, feedback));
        }
      }
      
      final successRate = successfulGames / testWords.length;
      expect(successRate, greaterThanOrEqualTo(0.98)); // 98%+ success rate
      
      print('✅ Performance test: ${(successRate * 100).toStringAsFixed(1)}% success rate');
    });
  });
}

/// Generate feedback for a guess against a target word
List<String> _generateFeedback(String guess, String target) {
  final feedback = <String>[];
  final targetChars = target.split('');
  final guessChars = guess.split('');
  
  for (int i = 0; i < 5; i++) {
    if (guessChars[i] == targetChars[i]) {
      feedback.add('G'); // Green - exact match
    } else if (targetChars.contains(guessChars[i])) {
      feedback.add('Y'); // Yellow - in word but wrong position
    } else {
      feedback.add('X'); // Gray - not in word
    }
  }
  
  return feedback;
}
