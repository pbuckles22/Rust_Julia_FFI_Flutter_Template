import 'package:flutter/material.dart';
import 'package:wrdlhelper/models/game_state.dart';

/// Game controls widget for Wordle game
///
/// Provides buttons for starting a new game and getting suggestions
/// with proper state management and visual feedback.
class GameControls extends StatelessWidget {
  final GameState gameState;
  final VoidCallback? onNewGame;
  final VoidCallback? onGetSuggestion;
  final VoidCallback? onUndo;
  final bool isLoading;
  final bool suggestionReceived;
  final String? suggestionError;

  const GameControls({
    super.key,
    required this.gameState,
    this.onNewGame,
    this.onGetSuggestion,
    this.onUndo,
    this.isLoading = false,
    this.suggestionReceived = false,
    this.suggestionError,
  });

  @override
  Widget build(BuildContext context) {
    final feedbackMessage = _buildFeedbackMessage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButtons(),
        if (isLoading) _buildLoadingIndicator(),
        if (feedbackMessage != null) feedbackMessage,
      ],
    );
  }

  /// Builds the main control buttons row
  Widget _buildControlButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildNewGameButton(),
        _buildSuggestionButton(),
        if (gameState.guesses.isNotEmpty) _buildUndoButton(),
      ],
    );
  }

  /// Builds the appropriate feedback message based on state
  /// Error takes precedence over success message
  Widget? _buildFeedbackMessage() {
    if (suggestionError != null) {
      return _buildErrorMessage();
    } else if (suggestionReceived) {
      return _buildSuccessMessage();
    }
    return null;
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildNewGameButton() {
    return _buildButton(
      text: 'New Game',
      onPressed: onNewGame,
      isDisabled: isLoading,
    );
  }

  Widget _buildSuggestionButton() {
    final isDisabled = isLoading || gameState.isGameOver;

    return _buildButton(
      text: '🎯 Get Next Hint',
      onPressed: onGetSuggestion,
      isDisabled: isDisabled,
    );
  }

  Widget _buildUndoButton() {
    return _buildButton(text: '↶ Undo', onPressed: onUndo, isDisabled: false);
  }

  /// Builds a button with consistent styling and error handling
  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isDisabled,
  }) {
    final semanticLabel = isDisabled
        ? '$text button (disabled)'
        : '$text button';

    return Semantics(
      label: semanticLabel,
      child: ElevatedButton(
        onPressed: (isDisabled || onPressed == null)
            ? null
            : _safeCallback(onPressed),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.2),
        ),
        child: Text(text),
      ),
    );
  }

  /// Safely executes a callback with exception handling
  VoidCallback _safeCallback(VoidCallback callback) {
    return () {
      try {
        callback();
      } catch (e) {
        // Handle exception gracefully - widget continues to render
        // In a real app, you might want to log this error
      }
    };
  }

  Widget _buildSuccessMessage() {
    return _buildFeedbackContainer(
      color: Colors.green,
      icon: Icons.check_circle,
      message: 'Suggestion received!',
    );
  }

  Widget _buildErrorMessage() {
    return _buildFeedbackContainer(
      color: Colors.red,
      icon: Icons.error,
      message: 'Error getting suggestion',
      details: suggestionError,
      showRetryButton: true,
    );
  }

  /// Builds a consistent feedback container with optional details and retry button
  Widget _buildFeedbackContainer({
    required MaterialColor color,
    required IconData icon,
    required String message,
    String? details,
    bool showRetryButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color[700], size: 16),
              const SizedBox(width: 8),
              Text(message, style: TextStyle(color: color[700])),
            ],
          ),
          if (details != null) ...[
            const SizedBox(height: 4),
            Text(details, style: TextStyle(color: color[600], fontSize: 12)),
          ],
          if (showRetryButton && onGetSuggestion != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _safeCallback(onGetSuggestion!),
              style: ElevatedButton.styleFrom(
                backgroundColor: color[50],
                foregroundColor: color[700],
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
