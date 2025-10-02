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
  final String? letter;
  final LetterState? state;
  final bool? isDisabled;
  final VoidCallback? onTap;

  const LetterTile({
    super.key,
    required this.letter,
    this.state,
    this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _getAccessibilityLabel(),
      button: true,
      enabled: isDisabled != true,
      child: GestureDetector(
        onTap: isDisabled == true ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: Border.all(color: _getBorderColor(), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              letter?.toUpperCase() ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAccessibilityLabel() {
    final letterText = letter?.toUpperCase() ?? 'empty';
    final stateText = _getStateText();
    return '$letterText $stateText';
  }

  String _getStateText() {
    if (isDisabled == true) {
      return 'disabled';
    }

    switch (state) {
      case LetterState.gray:
        return 'gray';
      case LetterState.yellow:
        return 'yellow';
      case LetterState.green:
        return 'green';
      case null:
        return 'input';
    }
  }

  Color _getBackgroundColor() {
    if (isDisabled == true) {
      return Colors.grey[300]!;
    }

    switch (state) {
      case LetterState.gray:
        return Colors.grey[400]!;
      case LetterState.yellow:
        return Colors.yellow[400]!;
      case LetterState.green:
        return Colors.green[400]!;
      case null:
        return Colors.grey[200]!;
    }
  }

  Color _getBorderColor() {
    if (isDisabled == true) {
      return Colors.grey[300]!;
    }

    switch (state) {
      case LetterState.gray:
      case LetterState.yellow:
      case LetterState.green:
        return _getBackgroundColor();
      case null:
        return Colors.grey[200]!;
    }
  }

  Color _getTextColor() {
    if (isDisabled == true) {
      return Colors.grey[500]!;
    }

    switch (state) {
      case LetterState.gray:
      case LetterState.yellow:
      case LetterState.green:
        return Colors.white;
      case null:
        return Colors.black;
    }
  }
}

/// Letter state for the Wordle game
enum LetterState {
  /// Gray - letter not in target word
  gray,

  /// Yellow - letter in target word but wrong position
  yellow,

  /// Green - letter in target word and correct position
  green,
}
