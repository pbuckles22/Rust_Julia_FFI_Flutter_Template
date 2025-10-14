import 'package:flutter/material.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/widgets/letter_tile.dart';

/// Game grid widget displaying the Wordle helper board
///
/// Shows 5 rows of 5 letter tiles each, representing the helper state
/// and current input. Tiles are color-coded based on guess results.
/// Row 1 is pre-filled with suggested starting word, rows 2-4 are user inputs,
/// row 5 is read-only (final guess, no interaction needed).
class GameGrid extends StatelessWidget {
  /// The current game state
  final GameState gameState;
  
  /// The current user input
  final String currentInput;
  
  /// Available height for the grid
  final double? availableHeight;
  
  /// Callback when a tile is tapped
  final Function(int row, int col)? onTileTap;
  
  /// Known letter states for tiles
  final Map<int, LetterTileState>? knownLetterStates;

  /// Creates a new game grid widget
  const GameGrid({
    super.key,
    required this.gameState,
    required this.currentInput,
    this.availableHeight,
    this.onTileTap,
    this.knownLetterStates,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Game Grid',
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available space for the grid
          final availableWidth =
              constraints.maxWidth - 24; // Account for padding
          final maxHeight = availableHeight ?? constraints.maxHeight - 24;

          // Calculate optimal tile size based on available space
          // Use responsive sizing that adapts to screen size
          final maxTileWidth = availableWidth / 5.2; // 5 tiles + gaps
          final maxTileHeight =
              maxHeight / 6.0; // 5 rows + gaps (reduced by ~10%)

          // Calculate tile size with better responsive bounds
          final screenHeight = MediaQuery.of(context).size.height;
          final isSmallScreen = screenHeight < 700;

          final minTileSize = isSmallScreen ? 24.0 : 32.0;
          final maxTileSize = isSmallScreen ? 40.0 : 56.0;

          final tileSize =
              (maxTileWidth < maxTileHeight ? maxTileWidth : maxTileHeight)
                  .clamp(minTileSize, maxTileSize);

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (rowIndex) {
                final isCurrentInputRow = rowIndex == gameState.guesses.length;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 2,
                  ),
                  decoration: isCurrentInputRow
                      ? BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        )
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (colIndex) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SizedBox(
                          width: tileSize,
                          height: tileSize,
                          child: _buildTile(rowIndex, colIndex),
                        ),
                      )),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(int rowIndex, int colIndex) {
    // Check if this tile is part of a completed guess
    if (rowIndex < gameState.guesses.length) {
      final guess = gameState.guesses[rowIndex];
      final letter = guess.word.value[colIndex];
      final result = guess.result.letterStates[colIndex];

      return LetterTile(
        key: Key('tile_${rowIndex}_$colIndex'),
        letter: letter,
        state: _getLetterState(_letterStateToString(result)),
        isRevealed: true,
        onTap: () => onTileTap?.call(rowIndex, colIndex),
      );
    }

    // Check if this is the 5th row (final row) - make it read-only
    if (rowIndex == 4) {
      return LetterTile(
        key: Key('tile_${rowIndex}_$colIndex'),
        letter: '',
        state: LetterTileState.empty,
        isRevealed: false,
      );
    }

    // Check if this tile is part of current input (only for rows 0-3)
    if (rowIndex == gameState.guesses.length &&
        colIndex < currentInput.length) {
      // Check if we have a known state for this position
      final knownState = knownLetterStates?[colIndex];
      final tileState = knownState ?? LetterTileState.input;

      return LetterTile(
        key: Key('tile_${rowIndex}_$colIndex'),
        letter: currentInput[colIndex],
        state: tileState,
        isRevealed: knownState != null, // Reveal if we have a known state
      );
    }

    // Empty tile
    return LetterTile(
      key: Key('tile_${rowIndex}_$colIndex'),
      letter: '',
      state: LetterTileState.empty,
      isRevealed: false,
    );
  }

  String _letterStateToString(LetterState state) {
    switch (state) {
      case LetterState.green:
        return 'G';
      case LetterState.yellow:
        return 'Y';
      case LetterState.gray:
        return 'X';
    }
  }

  LetterTileState _getLetterState(String result) {
    switch (result) {
      case 'G':
        return LetterTileState.correct;
      case 'Y':
        return LetterTileState.present;
      case 'X':
        return LetterTileState.absent;
      default:
        return LetterTileState.empty;
    }
  }
}
