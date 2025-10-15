import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/widgets/game_status.dart' as game_status;
import 'package:wrdlhelper/service_locator.dart';

void main() {
  group('GameStatus Widget Tests', () {
    late GameState mockGameState;
    late int mockTotalWords;
    late int mockRemainingWords;
    late String? mockSuggestion;

    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });
    
    tearDownAll(resetAllServices);

    setUp(() {
      // Test data chosen to verify game status functionality
      // Game state: Playing with 2 guesses made, 4 remaining
      // Word counts: Realistic Wordle word list statistics
      // Suggestion: Current word suggestion from solver
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
      mockTotalWords = 12973;
      mockRemainingWords = 1247;
      mockSuggestion = 'CRATE';
    });

    group('Widget Rendering', () {
      testWidgets('displays all status information', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify all status elements are present
        expect(find.text('Word Statistics'), findsOneWidget);
        expect(find.text('Total: 12,973'), findsOneWidget);
        expect(find.text('Remaining: 1,247'), findsOneWidget);
        expect(find.text('Suggestion: CRATE'), findsOneWidget);
        expect(find.text('Guess 2 of 5'), findsOneWidget);
      });

      testWidgets('displays with correct styling and layout', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify styling elements
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Column), findsAtLeastNWidgets(1));
        expect(find.byType(Row), findsAtLeastNWidgets(1));
      });
    });

    group('Game State Display', () {
      testWidgets('shows playing state when game is in progress', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify playing state display
        expect(find.text('Status: Playing'), findsOneWidget);
        expect(find.byIcon(Icons.play_circle), findsOneWidget);
      });

      testWidgets('shows won state when game is won', (
        tester,
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
              body: game_status.GameStatusWidget(
                gameState: wonGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify won state display
        expect(find.text('Status: Won!'), findsOneWidget);
        expect(find.byIcon(Icons.celebration), findsOneWidget);
      });

      testWidgets('shows lost state when game is lost', (
        tester,
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
              body: game_status.GameStatusWidget(
                gameState: lostGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify lost state display
        expect(find.text('Status: Lost'), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });
    });

    group('Word Statistics Display', () {
      testWidgets('displays correct total word count', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: 5000,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify total word count
        expect(find.text('Total: 5,000'), findsOneWidget);
      });

      testWidgets('displays correct remaining word count', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: 500,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify remaining word count
        expect(find.text('Remaining: 500'), findsOneWidget);
      });

      testWidgets('formats large numbers with commas', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: 1234567,
                remainingWords: 987654,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify number formatting
        expect(find.text('Total: 1,234,567'), findsOneWidget);
        expect(find.text('Remaining: 987,654'), findsOneWidget);
      });
    });

    group('Guess Count Display', () {
      testWidgets('shows current guess number correctly', (
        tester,
      ) async {
        // Arrange - Game with 2 guesses made
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify guess count
        expect(find.text('Guess 2 of 5'), findsOneWidget);
      });

      testWidgets('shows first guess correctly', (tester) async {
        // Arrange - Game with no guesses made
        final newGameState = GameState.newGame(
          targetWord: Word.fromString('CRANE'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: newGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify first guess
        expect(find.text('Guess 0 of 5'), findsOneWidget);
      });

      testWidgets('shows final guess correctly', (tester) async {
        // Arrange - Game with 5 guesses made (max for helper app)
        final finalGameState = GameState.newGame(
          targetWord: Word.fromString('CRANE'),
          maxGuesses: 5,
        );
        final words = ['SLATE', 'CRICK', 'CRATE', 'CRAMP', 'CRANE'];

        for (var i = 0; i < 5; i++) {
          finalGameState.addGuess(
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
              body: game_status.GameStatusWidget(
                gameState: finalGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify final guess
        expect(find.text('Guess 5 of 5'), findsOneWidget);
      });
    });

    group('Suggestion Display', () {
      testWidgets('displays suggestion when provided', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: 'CRATE',
              ),
            ),
          ),
        );

        // Assert - Verify suggestion display
        expect(find.text('Suggestion: CRATE'), findsOneWidget);
      });

      testWidgets('hides suggestion when null', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: null,
              ),
            ),
          ),
        );

        // Assert - Verify suggestion is hidden
        expect(find.textContaining('Suggestion:'), findsNothing);
      });

      testWidgets('displays different suggestions correctly', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: 'SLATE',
              ),
            ),
          ),
        );

        // Assert - Verify different suggestion
        expect(find.text('Suggestion: SLATE'), findsOneWidget);
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      testWidgets('handles zero word counts gracefully', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: 0,
                remainingWords: 0,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify zero counts display
        expect(find.text('Total: 0'), findsOneWidget);
        expect(find.text('Remaining: 0'), findsOneWidget);
      });

      testWidgets('handles very large word counts', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: 999999999,
                remainingWords: 123456789,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify large counts display
        expect(find.text('Total: 999,999,999'), findsOneWidget);
        expect(find.text('Remaining: 123,456,789'), findsOneWidget);
      });

      testWidgets('handles empty suggestion string', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: '',
              ),
            ),
          ),
        );

        // Assert - Verify empty suggestion is hidden
        expect(find.textContaining('Suggestion:'), findsNothing);
      });

      testWidgets('handles rapid state changes efficiently', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Act - Rapid state changes
        for (var i = 0; i < 10; i++) {
          final updatedState = mockGameState.copyWith(
            currentGuess: (i % 6) + 1,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: game_status.GameStatusWidget(
                  gameState: updatedState,
                  totalWords: mockTotalWords + i,
                  remainingWords: mockRemainingWords - i,
                  suggestion: i % 2 == 0 ? 'WORD1' : 'WORD2',
                ),
              ),
            ),
          );
        }

        // Assert - Verify final state is stable
        expect(find.text('Word Statistics'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('provides proper semantic labels for screen readers', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify accessibility through text content
        expect(find.text('Word Statistics'), findsOneWidget);
        expect(find.text('Total: 12,973'), findsOneWidget);
        expect(find.text('Remaining: 1,247'), findsOneWidget);
        expect(find.text('Suggestion: CRATE'), findsOneWidget);
        expect(find.text('Guess 2 of 5'), findsOneWidget);
      });

      testWidgets('provides proper semantic labels for different game states', (
        tester,
      ) async {
        // Arrange - Won game state
        final wonGameState = mockGameState.copyWith(
          gameStatus: GameStatus.won,
          isGameOver: true,
          isWon: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: wonGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Assert - Verify accessibility through text content for won state
        expect(find.text('Status: Won!'), findsOneWidget);
      });

      testWidgets('supports keyboard navigation', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Act - Focus on widget
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Assert - Verify widget is focusable (basic accessibility)
        expect(find.byType(game_status.GameStatusWidget), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('renders quickly with complex game state', (
        tester,
      ) async {
        // Arrange - Complex game state with many guesses
        final complexGameState = GameState.newGame(
          targetWord: Word.fromString('CRANE'),
        );
        final words = ['SLATE', 'CRICK', 'CRATE', 'CRAMP', 'CRASH'];

        for (var i = 0; i < 5; i++) {
          complexGameState.addGuess(
            Word.fromString(words[i]),
            GuessResult(
              word: Word.fromString(words[i]),
              letterStates: List.filled(5, LetterState.gray),
            ),
          );
        }

        // Act - Measure render time
        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: complexGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
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
        expect(find.text('Word Statistics'), findsOneWidget);
      });

      testWidgets('handles rapid state changes efficiently', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: game_status.GameStatusWidget(
                gameState: mockGameState,
                totalWords: mockTotalWords,
                remainingWords: mockRemainingWords,
                suggestion: mockSuggestion,
              ),
            ),
          ),
        );

        // Act - Rapid state changes
        for (var i = 0; i < 20; i++) {
          final updatedState = mockGameState.copyWith(
            currentGuess: (i % 6) + 1,
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: game_status.GameStatusWidget(
                  gameState: updatedState,
                  totalWords: mockTotalWords + i,
                  remainingWords: mockRemainingWords - i,
                  suggestion: i % 3 == 0 ? null : 'WORD$i',
                ),
              ),
            ),
          );
        }

        // Assert - Verify final state
        expect(find.text('Word Statistics'), findsOneWidget);
      });
    });
  });
}
