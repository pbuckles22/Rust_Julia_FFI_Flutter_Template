import 'package:flutter/material.dart';

/// Virtual keyboard widget for the Wordle game
///
/// Displays a QWERTY layout with letter keys and action keys (ENTER, DELETE).
/// Keys can be colored based on their state and disabled when needed.
class VirtualKeyboard extends StatelessWidget {
  /// Callback when a key is pressed
  final Function(String)? onKeyPress;
  
  /// Colors for specific keys based on guess results
  final Map<String, Color>? keyColors;
  
  /// Set of keys that are disabled
  final Set<String>? disabledKeys;

  /// Creates a new virtual keyboard widget
  const VirtualKeyboard({
    super.key,
    required this.onKeyPress,
    this.keyColors,
    this.disabledKeys,
  });

  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Virtual Keyboard',
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row: Q W E R T Y U I O P
            _buildRow(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']),
            const SizedBox(height: 8),

            // Second row: A S D F G H J K L
            _buildRow(['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']),
            const SizedBox(height: 8),

            // Third row: Z X C V B N M + ENTER + DELETE
            _buildRow(['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'ENTER', 'DELETE']),
          ],
        ),
      ),
    );

  Widget _buildRow(List<String> keys) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map(_buildKey).toList(),
    );

  Widget _buildKey(String key) {
    final isDisabled = disabledKeys?.contains(key) ?? false;
    final keyColor = keyColors?[key] ?? Colors.grey[300];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isDisabled ? Colors.grey[400] : keyColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: isDisabled ? null : () => onKeyPress?.call(key),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDisabled ? Colors.grey[400]! : Colors.grey[600]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey[500] : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
