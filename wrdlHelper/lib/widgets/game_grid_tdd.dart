import 'package:flutter/material.dart';
import 'package:wrdlhelper/widgets/letter_tile_tdd.dart';

/// Game grid widget displaying the Wordle helper board
///
/// Shows 5 rows of 5 letter tiles each, representing the helper state
/// and current input. Tiles are color-coded based on guess results.
/// Row 1 is pre-filled with suggested starting word, rows 2-4 are user inputs,
/// row 5 is read-only (final guess, no interaction needed).
class GameGrid extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col)? onTileTap;

  const GameGrid({super.key, required this.gameState, this.onTileTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Game Grid',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: List.generate(5, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (colIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildTile(rowIndex, colIndex),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTile(int rowIndex, int colIndex) {
    // Check if this tile is part of a completed guess
    if (rowIndex < gameState.guesses.length) {
      final guess = gameState.guesses[rowIndex];
      final letter = guess.length > colIndex ? guess[colIndex] : '';
      final result =
          gameState.guessResults.length > rowIndex &&
              gameState.guessResults[rowIndex].length > colIndex
          ? gameState.guessResults[rowIndex][colIndex]
          : LetterState.gray;

      return LetterTile(
        letter: letter,
        state: result,
        onTap: () => onTileTap?.call(rowIndex, colIndex),
      );
    }

    // Check if this tile is part of current input
    if (rowIndex == gameState.guesses.length &&
        colIndex < gameState.currentGuess.length) {
      return LetterTile(
        letter: gameState.currentGuess[colIndex],
        onTap: () => onTileTap?.call(rowIndex, colIndex),
      );
    }

    // Empty tile
    return LetterTile(
      letter: '',
      onTap: () => onTileTap?.call(rowIndex, colIndex),
    );
  }
}

/// Game state model for TDD tests
class GameState {
  List<String> guesses = [];
  List<List<LetterState>> guessResults = [];
  String currentGuess = '';
  bool isWon = false;
  bool isLost = false;

  void addGuess(String guess) {
    guesses.add(guess);
  }

  void setGuessResult(int index, GuessResult result) {
    if (index < guessResults.length) {
      guessResults[index] = result.letterStates;
    } else {
      guessResults.add(result.letterStates);
    }
  }

  void setCurrentGuess(String guess) {
    currentGuess = guess;
  }

  void setGameWon(bool won) {
    isWon = won;
  }

  void setGameLost(bool lost) {
    isLost = lost;
  }
}

/// Guess result model for TDD tests
class GuessResult {
  final List<LetterState> letterStates;

  GuessResult({required this.letterStates});

  factory GuessResult.fromWord(String word, List<LetterState> states) {
    return GuessResult(letterStates: states);
  }
}
