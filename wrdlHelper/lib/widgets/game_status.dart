import 'package:flutter/material.dart';
import 'package:wrdlhelper/models/game_state.dart';

/// Game status widget for Wordle game
///
/// Displays game statistics, current state, and word suggestions
/// with proper formatting and accessibility support.
class GameStatusWidget extends StatelessWidget {
  final GameState gameState;
  final int totalWords;
  final int remainingWords;
  final String? suggestion;

  const GameStatusWidget({
    super.key,
    required this.gameState,
    required this.totalWords,
    required this.remainingWords,
    this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildWordStatistics(),
            const SizedBox(height: 8),
            _buildGameState(),
            const SizedBox(height: 8),
            _buildGuessCount(),
            if (suggestion != null && suggestion!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSuggestion(),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Semantics(
      label: 'Word Statistics',
      textDirection: TextDirection.ltr,
      child: const Text(
        'Word Statistics',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Builds the word statistics section
  Widget _buildWordStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Total words: ${_formatNumber(totalWords)}',
          textDirection: TextDirection.ltr,
          child: Text(
            'Total: ${_formatNumber(totalWords)}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 4),
        Semantics(
          label: 'Remaining words: ${_formatNumber(remainingWords)}',
          textDirection: TextDirection.ltr,
          child: Text(
            'Remaining: ${_formatNumber(remainingWords)}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Builds the game state section
  Widget _buildGameState() {
    final statusText = _getStatusText();
    final statusIcon = _getStatusIcon();

    return Row(
      children: [
        statusIcon,
        const SizedBox(width: 8),
        Semantics(
          label: 'Game Status: $statusText',
          textDirection: TextDirection.ltr,
          child: Text(
            'Status: $statusText',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Builds the guess count section
  Widget _buildGuessCount() {
    final guessText =
        'Guess ${gameState.guesses.length} of ${gameState.maxGuesses}';

    return Semantics(
      label: guessText,
      textDirection: TextDirection.ltr,
      child: Text(guessText, style: const TextStyle(fontSize: 14)),
    );
  }

  /// Builds the suggestion section
  Widget _buildSuggestion() {
    return Semantics(
      label: 'Current suggestion: $suggestion',
      textDirection: TextDirection.ltr,
      child: Text(
        'Suggestion: $suggestion',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Gets the status text based on game state
  String _getStatusText() {
    switch (gameState.gameStatus) {
      case GameStatus.playing:
        return 'Playing';
      case GameStatus.won:
        return 'Won!';
      case GameStatus.lost:
        return 'Lost';
    }
  }

  /// Gets the status icon based on game state
  Widget _getStatusIcon() {
    switch (gameState.gameStatus) {
      case GameStatus.playing:
        return const Icon(Icons.play_circle, size: 16);
      case GameStatus.won:
        return const Icon(Icons.celebration, size: 16);
      case GameStatus.lost:
        return const Icon(Icons.cancel, size: 16);
    }
  }

  /// Formats numbers with commas for better readability
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}
