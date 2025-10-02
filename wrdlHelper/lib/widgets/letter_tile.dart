import 'package:flutter/material.dart';

/// Letter tile widget for the Wordle game grid
///
/// Displays a single letter with appropriate styling based on its state:
/// - Empty: Gray border
/// - Input: Black border
/// - Correct: Green background
/// - Present: Yellow background
/// - Absent: Gray background
class LetterTile extends StatelessWidget {
  final String letter;
  final LetterTileState state;
  final bool isRevealed;
  final VoidCallback? onTap;

  const LetterTile({
    super.key,
    required this.letter,
    required this.state,
    required this.isRevealed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available space or default to 56px
        final size =
            constraints.maxWidth.isFinite && constraints.maxHeight.isFinite
            ? constraints.maxWidth.clamp(20.0, 56.0)
            : 56.0;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              border: Border.all(
                color: _getBorderColor(),
                width: state == LetterTileState.input ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // Main shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                // Input focus glow (Apple Calculator style)
                if (state == LetterTileState.input)
                  BoxShadow(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                    spreadRadius: 4,
                  ),
                // Subtle inner shadow for depth
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _getTextColor(),
                  letterSpacing: 1.2,
                  shadows: state != LetterTileState.empty
                      ? [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Text(letter.toUpperCase()),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (!isRevealed) {
      return Colors.white;
    }

    switch (state) {
      case LetterTileState.correct:
        return const Color(0xFF6AAA64); // Green
      case LetterTileState.present:
        return const Color(0xFFC9B458); // Yellow
      case LetterTileState.absent:
        return const Color(0xFF787C7E); // Gray
      case LetterTileState.input:
        return Colors.white;
      case LetterTileState.empty:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case LetterTileState.input:
        return const Color(0xFF878A8C); // Dark gray
      case LetterTileState.empty:
        return const Color(0xFFD3D6DA); // Light gray
      default:
        return _getBackgroundColor();
    }
  }

  Color _getTextColor() {
    if (!isRevealed) {
      return Colors.black;
    }

    switch (state) {
      case LetterTileState.correct:
      case LetterTileState.present:
      case LetterTileState.absent:
        return Colors.white;
      case LetterTileState.input:
        return Colors.black;
      case LetterTileState.empty:
        return Colors.black;
    }
  }
}

/// Letter tile states for the Wordle game
enum LetterTileState {
  /// Empty tile (no letter)
  empty,

  /// Tile with current input letter
  input,

  /// Letter is in the correct position
  correct,

  /// Letter is in the word but wrong position
  present,

  /// Letter is not in the word
  absent,
}
