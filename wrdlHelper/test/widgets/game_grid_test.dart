import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/widgets/game_grid.dart';
import 'package:wrdlhelper/widgets/letter_tile.dart';

void main() {
  group('GameGrid', () {
    testWidgets('displays empty grid with correct dimensions', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should display 5 rows of 5 tiles each
      expect(find.byType(LetterTile), findsNWidgets(25)); // 5 rows × 5 columns
    });

    testWidgets('displays guesses in correct positions', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      // Add guesses using proper GameState interface
      final word1 = Word.fromString('CRANE');
      final result1 = GuessResult.fromWord(word1);
      gameState.addGuess(word1, result1);

      final word2 = Word.fromString('SLATE');
      final result2 = GuessResult.fromWord(word2);
      gameState.addGuess(word2, result2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // First row should show CRANE
      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('A'), findsAtLeastNWidgets(1));
      expect(find.text('N'), findsOneWidget);
      expect(find.text('E'), findsAtLeastNWidgets(1));

      // Second row should show SLATE
      expect(find.text('S'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('shows correct letter states for each guess', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      // Add guess with specific letter states
      final word = Word.fromString('CRANE');
      final result = GuessResult.withStates(
        word: word,
        letterStates: [
          LetterState.green,
          LetterState.gray,
          LetterState.gray,
          LetterState.gray,
          LetterState.green,
        ],
      );
      gameState.addGuess(word, result);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should display tiles with correct states
      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('displays current input correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = 'SLATE';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should show SLATE in first row
      expect(find.text('S'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('A'), findsAtLeastNWidgets(1));
      expect(find.text('T'), findsOneWidget);
      expect(find.text('E'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles partial current input correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = 'SL';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should show S, L and 3 empty tiles in first row
      expect(find.text('S'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('handles game won state correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      // Add winning guess
      final word = Word.fromString('CRANE');
      final result = GuessResult.withStates(
        word: word,
        letterStates: [
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
          LetterState.green,
        ],
      );
      gameState.addGuess(word, result);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // All tiles in first row should be green
      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('handles game lost state correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      // Add 5 guesses (max allowed for helper app) using different words
      final words = ['CRATE', 'CRANE', 'SLATE', 'BLADE', 'GRADE'];
      for (var i = 0; i < 5; i++) {
        final word = Word.fromString(words[i]);
        final result = GuessResult.fromWord(word);
        gameState.addGuess(word, result);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // All 5 rows should be filled
      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('maintains proper grid layout', (WidgetTester tester) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should have 5 rows
      expect(find.byType(Row), findsNWidgets(5));

      // Each row should have 5 tiles
      for (var i = 0; i < 5; i++) {
        final rowTiles = find.descendant(
          of: find.byType(Row).at(i),
          matching: find.byType(LetterTile),
        );
        expect(rowTiles, findsNWidgets(5));
      }
    });

    testWidgets('handles state changes correctly', (WidgetTester tester) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Add a guess
      final word = Word.fromString('CRANE');
      final result = GuessResult.fromWord(word);
      gameState.addGuess(word, result);

      // Rebuild widget with new state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('A'), findsAtLeastNWidgets(1));
      expect(find.text('N'), findsOneWidget);
      expect(find.text('E'), findsAtLeastNWidgets(1));
    });

    testWidgets('has proper accessibility support', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      final word = Word.fromString('CRANE');
      final result = GuessResult.fromWord(word);
      gameState.addGuess(word, result);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(GameGrid));
      expect(semantics.label, contains('Game Grid'));
    });

    testWidgets('handles edge case with no guesses', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should display empty grid
      expect(find.byType(LetterTile), findsNWidgets(25));

      // All tiles should be empty
      for (var i = 0; i < 25; i++) {
        final tile = find.byType(LetterTile).at(i);
        expect(tile, findsOneWidget);
      }
    });

    testWidgets('handles partial current input correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = 'CRA';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // First row: C, R, A and 2 empty tiles
      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('A'), findsAtLeastNWidgets(1));
    });

    testWidgets('maintains tile order correctly', (WidgetTester tester) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      final word = Word.fromString('CRANE');
      final result = GuessResult.fromWord(word);
      gameState.addGuess(word, result);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // First row should have C, R, A, N, E in order
      final firstRowTiles = find.descendant(
        of: find.byType(Row).first,
        matching: find.byType(LetterTile),
      );

      expect(firstRowTiles, findsNWidgets(5));
    });

    testWidgets('handles mixed guess results correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      // Add guess with mixed results
      final word = Word.fromString('CRANE');
      final result = GuessResult.withStates(
        word: word,
        letterStates: [
          LetterState.green, // C - correct
          LetterState.yellow, // R - present but wrong position
          LetterState.gray, // A - absent
          LetterState.gray, // N - absent
          LetterState.green, // E - correct
        ],
      );
      gameState.addGuess(word, result);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('handles empty current input with existing guesses', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      // Add some guesses
      final word1 = Word.fromString('CRANE');
      final result1 = GuessResult.fromWord(word1);
      gameState.addGuess(word1, result1);

      final word2 = Word.fromString('SLATE');
      final result2 = GuessResult.fromWord(word2);
      gameState.addGuess(word2, result2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should show existing guesses and empty current row
      expect(find.text('C'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('handles long current input correctly', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = 'SLATE';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should show SLATE in first row
      expect(find.text('S'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('A'), findsAtLeastNWidgets(1));
      expect(find.text('T'), findsOneWidget);
      expect(find.text('E'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles special characters in current input', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = 'CRÉPE';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      // Should show CRÉPE in first row
      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('É'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('E'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles multiple guesses with different states', (
      WidgetTester tester,
    ) async {
      final gameState = GameState.newGame();
      const currentInput = '';

      // Add first guess - all gray
      final word1 = Word.fromString('SLATE');
      final result1 = GuessResult.fromWord(word1);
      gameState.addGuess(word1, result1);

      // Add second guess - mixed states
      final word2 = Word.fromString('CRANE');
      final result2 = GuessResult.withStates(
        word: word2,
        letterStates: [
          LetterState.green,
          LetterState.yellow,
          LetterState.gray,
          LetterState.gray,
          LetterState.green,
        ],
      );
      gameState.addGuess(word2, result2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, currentInput: currentInput),
          ),
        ),
      );

      expect(find.byType(LetterTile), findsNWidgets(25));
    });
  });
}
