import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';

import 'mock_game_service.mocks.dart';

// Generate mocks using Mockito
@GenerateMocks([GameService])
void main() {}

/// Mock GameService for unit tests
/// 
/// This provides a lightweight, fast mock implementation that doesn't
/// perform expensive FFI calls or real game logic.
class MockGameService extends Mock implements GameService {
  @override
  GameState createNewGame() {
    return GameState.newGame();
  }

  @override
  Word? suggestNextGuess(GameState gameState) {
    // Always return CRANE for testing consistency
    return Word.fromString('CRANE');
  }

  @override
  GameState processGuess(GameState gameState, Word guess) {
    // Simple mock implementation - just add the guess
    final newGuesses = List<Word>.from(gameState.guesses);
    newGuesses.add(guess);
    
    return GameState(
      targetWord: gameState.targetWord,
      guesses: newGuesses,
      results: gameState.results,
      maxGuesses: gameState.maxGuesses,
      isGameOver: newGuesses.length >= gameState.maxGuesses,
      hasWon: false, // Mock never wins for testing
    );
  }
}
