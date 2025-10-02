import 'package:flutter/material.dart';

class VirtualKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final Map<String, Color> keyColors;
  final Set<String> disabledKeys;
  final double? availableWidth;
  final bool? isSmallScreen;

  const VirtualKeyboard({
    super.key,
    required this.onKeyPress,
    this.keyColors = const {},
    this.disabledKeys = const {},
    this.availableWidth,
    this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = isSmallScreen ?? screenHeight < 700;

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First row: Q W E R T Y U I O P
          _buildKeyboardRow([
            'Q',
            'W',
            'E',
            'R',
            'T',
            'Y',
            'U',
            'I',
            'O',
            'P',
          ], isSmall),
          SizedBox(height: isSmall ? 1 : 2),
          // Second row: A S D F G H J K L
          _buildKeyboardRow([
            'A',
            'S',
            'D',
            'F',
            'G',
            'H',
            'J',
            'K',
            'L',
          ], isSmall),
          SizedBox(height: isSmall ? 1 : 2),
          // Third row: Z X C V B N M
          _buildKeyboardRow(['Z', 'X', 'C', 'V', 'B', 'N', 'M'], isSmall),
          SizedBox(height: isSmall ? 1 : 2),
          // Fourth row: ENTER and DELETE
          _buildActionRow(isSmall),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, bool isSmall) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isSmall ? 1 : 2,
      runSpacing: isSmall ? 1 : 2,
      children: keys.map((key) => _buildKey(key, isSmall)).toList(),
    );
  }

  Widget _buildActionRow(bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionKey('ENTER', isEnter: true, isSmall: isSmall),
        SizedBox(width: isSmall ? 2 : 4),
        _buildActionKey('DELETE', isDelete: true, isSmall: isSmall),
      ],
    );
  }

  Widget _buildKey(String letter, bool isSmall) {
    final isDisabled = disabledKeys.contains(letter);
    final color = keyColors[letter] ?? const Color(0xFFD3D6DA);

    // Calculate responsive key size (increased for better touch targets)
    final keyWidth = isSmall ? 28.0 : 36.0;
    final keyHeight = isSmall ? 36.0 : 44.0;
    final fontSize = isSmall ? 14.0 : 16.0;
    final borderRadius = isSmall ? 8.0 : 10.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: InkWell(
        key: Key('key_$letter'),
        onTap: isDisabled ? null : () => onKeyPress(letter),
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          width: keyWidth,
          height: keyHeight,
          decoration: BoxDecoration(
            color: isDisabled ? const Color(0xFF787C7E) : color,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isDisabled
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Text(letter),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(
    String text, {
    bool isEnter = false,
    bool isDelete = false,
    bool isSmall = false,
  }) {
    final isDisabled =
        (isEnter && disabledKeys.contains('ENTER')) ||
        (isDelete && disabledKeys.contains('DELETE'));

    // Calculate responsive action key size
    final keyHeight = isSmall ? 28.0 : 40.0;
    final fontSize = isSmall ? 12.0 : 14.0;
    final horizontalPadding = isSmall ? 8.0 : 12.0;
    final verticalPadding = isSmall ? 6.0 : 8.0;
    final borderRadius = isSmall ? 6.0 : 8.0;

    return InkWell(
      key: Key('key_$text'),
      onTap: isDisabled ? null : () => onKeyPress(text),
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: keyHeight,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[400] : Colors.grey[600],
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isDisabled ? Colors.grey[600] : Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
