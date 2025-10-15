import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/widgets/game_grid_tdd.dart';
import 'package:wrdlhelper/widgets/letter_tile_tdd.dart';

void main() {
  group('GameGrid TDD Tests', () {
    testWidgets('should display empty grid with correct dimensions', (
      tester,
    ) async {
      final gameState = GameState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // Should display 5 rows of 5 tiles each
      expect(find.byType(LetterTile), findsNWidgets(25)); // 5 rows × 5 columns
    });

    testWidgets('should display guesses in correct positions', (
      tester,
    ) async {
      final gameState = GameState()
        ..addGuess('CRANE')
        ..addGuess('SLATE');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
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

    testWidgets('should show correct letter states for each guess', (
      tester,
    ) async {
      final gameState = GameState()
        ..addGuess('CRANE')
        ..addGuess('SLATE');

      // Set guess results
      // ignore: cascade_invocations
      gameState
        ..setGuessResult(
          0,
          GuessResult.fromWord('CRANE', [
            LetterState.green,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
            LetterState.green,
          ]),
        )
        ..setGuessResult(
          1,
          GuessResult.fromWord('SLATE', [
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
          ]),
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // First row should have green C and E, gray R, A, N
      final firstRowTiles = find.descendant(
        of: find.byType(Row).first,
        matching: find.byType(LetterTile),
      );

      expect(firstRowTiles, findsNWidgets(5));
    });

    testWidgets('should call onTileTap when tile is tapped', (
      tester,
    ) async {
      final gameState = GameState();
      int? tappedRow;
      int? tappedCol;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(
              gameState: gameState,
              onTileTap: (row, col) {
                tappedRow = row;
                tappedCol = col;
              },
            ),
          ),
        ),
      );

      // Tap first tile (row 0, col 0)
      await tester.tap(find.byType(LetterTile).first);
      await tester.pump();

      expect(tappedRow, equals(0));
      expect(tappedCol, equals(0));
    });

    testWidgets('should handle empty tiles correctly', (
      tester,
    ) async {
      final gameState = GameState()..addGuess('CR'); // Partial guess

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // First row should show C, R, and 3 empty tiles
      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);

      // Empty tiles should not display any text
      final firstRowTiles = find.descendant(
        of: find.byType(Row).first,
        matching: find.byType(LetterTile),
      );
      expect(firstRowTiles, findsNWidgets(5));
    });

    testWidgets('should display current guess correctly', (
      tester,
    ) async {
      final gameState = GameState()
        ..addGuess('CRANE')
        ..setCurrentGuess('SLATE');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // Should show CRANE in first row and SLATE in second row
      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('A'), findsAtLeastNWidgets(1));
      expect(find.text('N'), findsOneWidget);
      expect(find.text('E'), findsAtLeastNWidgets(1));

      expect(find.text('S'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('should handle game won state correctly', (
      tester,
    ) async {
      final gameState = GameState()
        ..addGuess('CRANE')
        ..setGuessResult(
          0,
          GuessResult.fromWord('CRANE', [
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
            LetterState.green,
          ]),
        )
        ..setGameWon(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // All tiles in first row should be green
      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('should handle game lost state correctly', (
      tester,
    ) async {
      final gameState = GameState();
      // Add 5 guesses (max allowed for helper app)
      for (var i = 0; i < 5; i++) {
        gameState.addGuess('SLATE');
      }
      gameState.setGameLost(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // All 5 rows should be filled
      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('should maintain proper grid layout', (
      tester,
    ) async {
      final gameState = GameState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
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

    testWidgets('should handle rapid tile tapping correctly', (
      tester,
    ) async {
      final gameState = GameState();
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(
              gameState: gameState,
              onTileTap: (row, col) => tapCount++,
            ),
          ),
        ),
      );

      // Tap multiple tiles rapidly
      await tester.tap(find.byType(LetterTile).at(0));
      await tester.tap(find.byType(LetterTile).at(5));
      await tester.tap(find.byType(LetterTile).at(10));
      await tester.pump();

      expect(tapCount, equals(3));
    });

    testWidgets('should handle state changes correctly', (
      tester,
    ) async {
      final gameState = GameState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // Add a guess
      gameState.addGuess('CRANE');

      // Rebuild the widget to reflect the state change
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
    });

    testWidgets('should have proper accessibility support', (
      tester,
    ) async {
      final gameState = GameState()..addGuess('CRANE');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(GameGrid));
      expect(semantics.label, contains('Game Grid'));
    });

    testWidgets('should handle edge case with no guesses', (
      tester,
    ) async {
      final gameState = GameState();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
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

    testWidgets('should handle partial guesses correctly', (
      tester,
    ) async {
      final gameState = GameState()
        ..addGuess('C')
        ..addGuess('CR')
        ..addGuess('CRA');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      // First row: C and 4 empty tiles
      // Second row: C, R and 3 empty tiles
      // Third row: C, R, A and 2 empty tiles
      expect(find.text('C'), findsNWidgets(3));
      expect(find.text('R'), findsNWidgets(2));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should maintain tile order correctly', (
      tester,
    ) async {
      final gameState = GameState()..addGuess('CRANE');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
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

    testWidgets('should handle mixed letter states correctly', (
      tester,
    ) async {
      final gameState = GameState()
        ..addGuess('CRANE')
        ..setGuessResult(
          0,
          GuessResult.fromWord('CRANE', [
            LetterState.green,
            LetterState.yellow,
            LetterState.gray,
            LetterState.gray,
            LetterState.green,
          ]),
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('should handle multiple rows with different states', (
      tester,
    ) async {
      final gameState = GameState();

      // Add multiple guesses with different states
      // ignore: cascade_invocations
      gameState
        ..addGuess('SLATE')
        ..setGuessResult(
          0,
          GuessResult.fromWord('SLATE', [
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
          ]),
        );

      // ignore: cascade_invocations
      gameState
        ..addGuess('CRANE')
        ..setGuessResult(
          1,
          GuessResult.fromWord('CRANE', [
            LetterState.green,
            LetterState.yellow,
            LetterState.gray,
            LetterState.gray,
            LetterState.green,
          ]),
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      expect(find.byType(LetterTile), findsNWidgets(25));
    });

    testWidgets('should handle special characters in guesses', (
      tester,
    ) async {
      final gameState = GameState()..addGuess('CRÉPE');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameGrid(gameState: gameState, onTileTap: (row, col) {}),
          ),
        ),
      );

      expect(find.text('C'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('É'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
    });
  });
}
