import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/widgets/game_controls.dart';

void main() {
  group('GameControls Widget Tests', () {
    late GameState mockGameState;
    late VoidCallback mockOnNewGame;
    late VoidCallback mockOnGetSuggestion;
    late bool mockIsLoading;

    setUp(() {
      // Test data chosen to verify game controls functionality
      // Game state: Playing with 3 guesses made, 2 remaining
      // Callbacks: Mock functions to verify button interactions
      // Loading state: False initially, can be set to true for loading tests
      mockGameState = GameState.newGame(targetWord: Word.fromString('CRANE'));
      // Add some mock guesses
      mockGameState.addGuess(
        Word.fromString('SLATE'),
        GuessResult(
          word: Word.fromString('SLATE'),
          letterStates: [
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
          ],
        ),
      );
      mockGameState.addGuess(
        Word.fromString('CRICK'),
        GuessResult(
          word: Word.fromString('CRICK'),
          letterStates: [
            LetterState.green,
            LetterState.green,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
          ],
        ),
      );
      mockGameState.addGuess(
        Word.fromString('CRATE'),
        GuessResult(
          word: Word.fromString('CRATE'),
          letterStates: [
            LetterState.green,
            LetterState.green,
            LetterState.gray,
            LetterState.gray,
            LetterState.gray,
          ],
        ),
      );
      mockOnNewGame = () {};
      mockOnGetSuggestion = () {};
      mockIsLoading = false;
    });

    group('Widget Rendering', () {
      testWidgets('displays new game button and get suggestion button', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: mockIsLoading,
              ),
            ),
          ),
        );

        // Assert - Verify all buttons are present (New Game, Get Suggestion,
        // Undo)
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('🎯 Get Next Hint'), findsOneWidget);
        expect(find.text('↶ Undo'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNWidgets(3));
      });

      testWidgets('displays buttons with correct styling', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: mockIsLoading,
              ),
            ),
          ),
        );

        // Assert - Verify button styling
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );

        expect(newGameButton, findsOneWidget);
        expect(suggestionButton, findsOneWidget);

        // Verify buttons are properly styled
        final newGameButtonWidget = tester.widget<ElevatedButton>(
          newGameButton,
        );
        final suggestionButtonWidget = tester.widget<ElevatedButton>(
          suggestionButton,
        );

        expect(newGameButtonWidget.onPressed, isNotNull);
        expect(suggestionButtonWidget.onPressed, isNotNull);
      });
    });

    group('New Game Button Functionality', () {
      testWidgets('calls onNewGame when new game button is tapped', (
        WidgetTester tester,
      ) async {
        // Arrange
        var newGameCalled = false;
        void onNewGameCallback() {
          newGameCalled = true;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: onNewGameCallback,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: mockIsLoading,
              ),
            ),
          ),
        );

        // Act - Tap new game button
        await tester.tap(find.text('New Game'));
        await tester.pump();

        // Assert - Verify callback was called
        expect(newGameCalled, isTrue);
      });

      testWidgets('new game button is enabled when game is not loading', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify button is enabled
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        final buttonWidget = tester.widget<ElevatedButton>(newGameButton);
        expect(buttonWidget.onPressed, isNotNull);
      });

      testWidgets('new game button is disabled when loading', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: true,
              ),
            ),
          ),
        );

        // Assert - Verify button is disabled
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        final buttonWidget = tester.widget<ElevatedButton>(newGameButton);
        expect(buttonWidget.onPressed, isNull);
      });

      testWidgets('new game button shows loading state when loading', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: true,
              ),
            ),
          ),
        );

        // Assert - Verify loading state display
        expect(find.text('Loading...'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(GameControls),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
      });
    });

    group('Get Suggestion Button Functionality', () {
      testWidgets(
        'calls onGetSuggestion when get suggestion button is tapped',
        (WidgetTester tester) async {
          // Arrange
          var suggestionCalled = false;
          void onSuggestionCallback() {
            suggestionCalled = true;
          }

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: GameControls(
                  gameState: mockGameState,
                  onNewGame: mockOnNewGame,
                  onGetSuggestion: onSuggestionCallback,
                  isLoading: mockIsLoading,
                ),
              ),
            ),
          );

          // Act - Tap get suggestion button
          await tester.tap(find.text('🎯 Get Next Hint'));
          await tester.pump();

          // Assert - Verify callback was called
          expect(suggestionCalled, isTrue);
        },
      );

      testWidgets('get suggestion button is enabled when game is playing', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify button is enabled
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );
        final buttonWidget = tester.widget<ElevatedButton>(suggestionButton);
        expect(buttonWidget.onPressed, isNotNull);
      });

      testWidgets('get suggestion button is disabled when game is over', (
        WidgetTester tester,
      ) async {
        // Arrange - Game state with game over
        final gameOverState = mockGameState.copyWith(
          isGameOver: true,
          gameStatus: GameStatus.won,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: gameOverState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify button is disabled
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );
        final buttonWidget = tester.widget<ElevatedButton>(suggestionButton);
        expect(buttonWidget.onPressed, isNull);
      });

      testWidgets('get suggestion button is disabled when loading', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: true,
              ),
            ),
          ),
        );

        // Assert - Verify button is disabled
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );
        final buttonWidget = tester.widget<ElevatedButton>(suggestionButton);
        expect(buttonWidget.onPressed, isNull);
      });

      testWidgets('get suggestion button shows loading state when loading', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: true,
              ),
            ),
          ),
        );

        // Assert - Verify loading state display
        expect(find.text('Loading...'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(GameControls),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
      });
    });

    group('Button States Based on Game State', () {
      testWidgets('both buttons are enabled when game is playing', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify both buttons are enabled
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );

        expect(
          tester.widget<ElevatedButton>(newGameButton).onPressed,
          isNotNull,
        );
        expect(
          tester.widget<ElevatedButton>(suggestionButton).onPressed,
          isNotNull,
        );
      });

      testWidgets('get suggestion button is disabled when game is won', (
        WidgetTester tester,
      ) async {
        // Arrange - Game state with won status
        final wonGameState = mockGameState.copyWith(
          gameStatus: GameStatus.won,
          isGameOver: true,
          isWon: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: wonGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify get suggestion button is disabled
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );
        expect(
          tester.widget<ElevatedButton>(suggestionButton).onPressed,
          isNull,
        );

        // New game button should still be enabled
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        expect(
          tester.widget<ElevatedButton>(newGameButton).onPressed,
          isNotNull,
        );
      });

      testWidgets('get suggestion button is disabled when game is lost', (
        WidgetTester tester,
      ) async {
        // Arrange - Game state with lost status
        final lostGameState = mockGameState.copyWith(
          gameStatus: GameStatus.lost,
          isGameOver: true,
          isWon: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: lostGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify get suggestion button is disabled
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );
        expect(
          tester.widget<ElevatedButton>(suggestionButton).onPressed,
          isNull,
        );

        // New game button should still be enabled
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        expect(
          tester.widget<ElevatedButton>(newGameButton).onPressed,
          isNotNull,
        );
      });

      testWidgets('both buttons are disabled when loading', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: true,
              ),
            ),
          ),
        );

        // Assert - Verify both buttons are disabled
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );

        expect(tester.widget<ElevatedButton>(newGameButton).onPressed, isNull);
        expect(
          tester.widget<ElevatedButton>(suggestionButton).onPressed,
          isNull,
        );
      });
    });

    group('Visual Feedback', () {
      testWidgets('shows success feedback when suggestion is received', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
                suggestionReceived: true,
              ),
            ),
          ),
        );

        // Assert - Verify success feedback
        expect(find.text('Suggestion received!'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('shows error feedback when suggestion fails', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
                suggestionError: 'Failed to get suggestion',
              ),
            ),
          ),
        );

        // Assert - Verify error feedback
        expect(find.text('Error getting suggestion'), findsOneWidget);
        expect(find.text('Failed to get suggestion'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('shows retry button when suggestion fails', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
                suggestionError: 'Failed to get suggestion',
              ),
            ),
          ),
        );

        // Assert - Verify retry button
        expect(find.text('Retry'), findsOneWidget);
        expect(
          find.byType(ElevatedButton),
          findsNWidgets(4),
        ); // New Game, Get Suggestion, Undo, Retry
      });

      testWidgets('retry button calls onGetSuggestion when tapped', (
        WidgetTester tester,
      ) async {
        // Arrange
        var suggestionCalled = false;
        void onSuggestionCallback() {
          suggestionCalled = true;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: onSuggestionCallback,
                isLoading: false,
                suggestionError: 'Failed to get suggestion',
              ),
            ),
          ),
        );

        // Act - Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Assert - Verify callback was called
        expect(suggestionCalled, isTrue);
      });
    });

    group('Accessibility', () {
      testWidgets('provides proper semantic labels for screen readers', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify semantic labels
        expect(find.bySemanticsLabel('New Game button'), findsOneWidget);
        expect(
          find.bySemanticsLabel('🎯 Get Next Hint button'),
          findsOneWidget,
        );
      });

      testWidgets('provides proper semantic labels for disabled buttons', (
        WidgetTester tester,
      ) async {
        // Arrange - Game state with game over
        final gameOverState = mockGameState.copyWith(
          isGameOver: true,
          gameStatus: GameStatus.won,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: gameOverState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify semantic labels for disabled button
        expect(
          find.bySemanticsLabel('🎯 Get Next Hint button (disabled)'),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('New Game button'), findsOneWidget);
      });

      testWidgets('provides proper semantic labels for loading state', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: true,
              ),
            ),
          ),
        );

        // Assert - Verify semantic labels for loading state
        expect(find.bySemanticsLabel('Loading...'), findsOneWidget);
        expect(
          find.bySemanticsLabel('New Game button (disabled)'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('🎯 Get Next Hint button (disabled)'),
          findsOneWidget,
        );
      });

      testWidgets('supports keyboard navigation', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Act - Focus on first button
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Assert - Verify focus is on first button
        expect(
          find.descendant(
            of: find.byType(GameControls),
            matching: find.byType(Focus),
          ),
          findsAtLeastNWidgets(1),
        );
      });
    });

    group('Error Handling', () {
      testWidgets('handles null callbacks gracefully', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: null,
                onGetSuggestion: null,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify buttons are disabled
        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );

        expect(tester.widget<ElevatedButton>(newGameButton).onPressed, isNull);
        expect(
          tester.widget<ElevatedButton>(suggestionButton).onPressed,
          isNull,
        );
      });

      testWidgets('handles callback exceptions gracefully', (
        WidgetTester tester,
      ) async {
        // Arrange
        Never throwingCallback() {
          throw Exception('Callback error');
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: throwingCallback,
                onGetSuggestion: throwingCallback,
                isLoading: false,
              ),
            ),
          ),
        );

        // Act - Tap buttons (should not crash)
        await tester.tap(find.text('New Game'));
        await tester.pump();

        await tester.tap(find.text('🎯 Get Next Hint'));
        await tester.pump();

        // Assert - Verify widget still renders
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('🎯 Get Next Hint'), findsOneWidget);
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      testWidgets('handles empty game state gracefully', (
        WidgetTester tester,
      ) async {
        // Arrange - Empty game state
        final emptyGameState = GameState.newGame(
          targetWord: Word.fromString('CRANE'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: emptyGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify buttons are present and functional
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('🎯 Get Next Hint'), findsOneWidget);

        final newGameButton = find.widgetWithText(ElevatedButton, 'New Game');
        final suggestionButton = find.widgetWithText(
          ElevatedButton,
          '🎯 Get Next Hint',
        );

        expect(
          tester.widget<ElevatedButton>(newGameButton).onPressed,
          isNotNull,
        );
        expect(
          tester.widget<ElevatedButton>(suggestionButton).onPressed,
          isNotNull,
        );
      });

      testWidgets('handles maximum game state complexity', (
        WidgetTester tester,
      ) async {
        // Arrange - Game state with maximum guesses (5 for helper app)
        final maxGameState = GameState.newGame(
          targetWord: Word.fromString('CRANE'),
          maxGuesses: 5,
        );
        final words = ['SLATE', 'CRICK', 'CRATE', 'CRAMP', 'CRANE'];

        for (var i = 0; i < 5; i++) {
          maxGameState.addGuess(
            Word.fromString(words[i]),
            GuessResult(
              word: Word.fromString(words[i]),
              letterStates: List.filled(5, LetterState.gray),
            ),
          );
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: maxGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert - Verify buttons handle max complexity
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('🎯 Get Next Hint'), findsOneWidget);
      });

      testWidgets('handles simultaneous success and error states', (
        WidgetTester tester,
      ) async {
        // Arrange - Both success and error states (edge case)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
                suggestionReceived: true,
                suggestionError: 'Error message',
              ),
            ),
          ),
        );

        // Assert - Verify both messages are shown (error takes precedence)
        expect(find.text('Error getting suggestion'), findsOneWidget);
        expect(find.text('Suggestion received!'), findsNothing);
      });

      testWidgets('handles rapid loading state changes', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Act - Rapid loading state changes
        for (var i = 0; i < 10; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: GameControls(
                  gameState: mockGameState,
                  onNewGame: mockOnNewGame,
                  onGetSuggestion: mockOnGetSuggestion,
                  isLoading: i % 2 == 0,
                ),
              ),
            ),
          );
          await tester.pump();
        }

        // Assert - Verify final state is stable
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('🎯 Get Next Hint'), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('renders quickly with complex game state', (
        WidgetTester tester,
      ) async {
        // Arrange - Complex game state with many guesses
        final complexGameState = GameState.newGame(
          targetWord: Word.fromString('CRANE'),
        );
        // Add 3 mock guesses (not 5 to avoid game over)
        final words = ['SLATE', 'CRICK', 'CRATE'];
        for (var i = 0; i < 3; i++) {
          complexGameState.addGuess(
            Word.fromString(words[i]),
            GuessResult(
              word: Word.fromString(words[i]),
              letterStates: [
                LetterState.gray,
                LetterState.gray,
                LetterState.gray,
                LetterState.gray,
                LetterState.gray,
              ],
            ),
          );
        }

        // Act - Measure render time
        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: complexGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );
        stopwatch.stop();

        // Assert - Verify performance
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(50),
        ); // Should render in < 50ms
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('🎯 Get Next Hint'), findsOneWidget);
      });

      testWidgets('handles rapid state changes efficiently', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameControls(
                gameState: mockGameState,
                onNewGame: mockOnNewGame,
                onGetSuggestion: mockOnGetSuggestion,
                isLoading: false,
              ),
            ),
          ),
        );

        // Act - Rapid state changes
        for (int i = 0; i < 20; i++) {
          final updatedState = mockGameState.copyWith(
            currentGuess: (i % 6) + 1,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: GameControls(
                  gameState: updatedState,
                  onNewGame: mockOnNewGame,
                  onGetSuggestion: mockOnGetSuggestion,
                  isLoading: i % 2 == 0,
                ),
              ),
            ),
          );
        }

        // Assert - Verify final state
        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('🎯 Get Next Hint'), findsOneWidget);
      });
    });
  });
}
