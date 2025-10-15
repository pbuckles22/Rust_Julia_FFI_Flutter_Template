import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/widgets/letter_tile.dart';

void main() {
  group('LetterTile', () {
    testWidgets('displays letter correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.input,
              isRevealed: false,
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('displays empty tile correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: '',
              state: LetterTileState.empty,
              isRevealed: false,
            ),
          ),
        ),
      );

      // Empty tile should not display any text
      expect(find.text('A'), findsNothing);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('shows correct color for gray state when revealed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.absent,
              isRevealed: true,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF787C7E))); // Gray color
    });

    testWidgets('shows correct color for yellow state when revealed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.present,
              isRevealed: true,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFC9B458))); // Yellow color
    });

    testWidgets('shows correct color for green state when revealed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.correct,
              isRevealed: true,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF6AAA64))); // Green color
    });

    testWidgets('shows white background when not revealed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.correct,
              isRevealed: false,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
    });

    testWidgets('shows correct text color for different states when revealed', (
      tester,
    ) async {
      // Test gray state text color
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.absent,
              isRevealed: true,
            ),
          ),
        ),
      );

      final animatedTextStyle = tester.widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      );
      expect(animatedTextStyle.style.color, equals(Colors.white));

      // Test yellow state text color
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.present,
              isRevealed: true,
            ),
          ),
        ),
      );

      final yellowAnimatedTextStyle = tester.widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      );
      expect(yellowAnimatedTextStyle.style.color, equals(Colors.white));

      // Test green state text color
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.correct,
              isRevealed: true,
            ),
          ),
        ),
      );

      final greenAnimatedTextStyle = tester.widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      );
      expect(greenAnimatedTextStyle.style.color, equals(Colors.white));
    });

    testWidgets('shows black text color when not revealed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.correct,
              isRevealed: false,
            ),
          ),
        ),
      );

      final animatedTextStyle = tester.widget<AnimatedDefaultTextStyle>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedDefaultTextStyle),
        ),
      );
      expect(animatedTextStyle.style.color, equals(Colors.black));
    });

    testWidgets('has proper sizing constraints', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.input,
              isRevealed: false,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.constraints?.minWidth, equals(56));
      expect(container.constraints?.minHeight, equals(56));
    });

    testWidgets('has proper border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.input,
              isRevealed: false,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('shows letter in uppercase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'a',
              state: LetterTileState.input,
              isRevealed: false,
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('handles special characters correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'É',
              state: LetterTileState.input,
              isRevealed: false,
            ),
          ),
        ),
      );

      expect(find.text('É'), findsOneWidget);
    });

    testWidgets('shows correct border color for input state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.input,
              isRevealed: false,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.border?.top.color,
        equals(const Color(0xFF878A8C)),
      ); // Dark gray border
    });

    testWidgets('shows correct border color for empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: '',
              state: LetterTileState.empty,
              isRevealed: false,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.border?.top.color,
        equals(const Color(0xFFD3D6DA)),
      ); // Light gray border
    });

    testWidgets('has proper animation duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.input,
              isRevealed: false,
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.duration, equals(const Duration(milliseconds: 600)));
    });

    testWidgets('maintains state across rebuilds', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.correct,
              isRevealed: true,
            ),
          ),
        ),
      );

      // Rebuild with same properties
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterTileState.correct,
              isRevealed: true,
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF6AAA64))); // Green color
    });

    testWidgets('handles all letter tile states correctly', (
      tester,
    ) async {
      final states = [
        LetterTileState.empty,
        LetterTileState.input,
        LetterTileState.correct,
        LetterTileState.present,
        LetterTileState.absent,
      ];

      for (final state in states) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LetterTile(letter: 'A', state: state, isRevealed: true),
            ),
          ),
        );

        expect(find.text('A'), findsOneWidget);
        expect(find.byType(LetterTile), findsOneWidget);
      }
    });

    testWidgets('handles empty letter with different states', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: '',
              state: LetterTileState.empty,
              isRevealed: false,
            ),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
      expect(find.byType(LetterTile), findsOneWidget);
    });
  });
}
