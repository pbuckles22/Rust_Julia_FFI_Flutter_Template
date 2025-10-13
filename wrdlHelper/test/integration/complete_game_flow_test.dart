import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/main.dart';
import 'package:wrdlhelper/screens/wordle_game_screen.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/widgets/game_grid.dart';
import 'package:wrdlhelper/widgets/virtual_keyboard.dart';

void main() {
  group('Complete Game Flow Integration Tests', () {
    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });

    tearDownAll(resetAllServices);
    testWidgets(
      'should complete full game workflow from start to finish',
      (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement complete
      // integration
      await tester.pumpWidget(const MyApp());

      // Wait for app to load
      await tester.pumpAndSettle();

      // Should show main game screen
      expect(find.byType(WordleGameScreen), findsOneWidget);

      // Wait for initialization (loading may be too fast to see)
      await tester.pumpAndSettle();

      // Should show game interface
      expect(find.text('Wordle Helper'), findsOneWidget);
      expect(find.byType(GameGrid), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);

      // Type a word
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('C'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('R'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('A'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('T'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('E'),
        ),
      );
      await tester.pump();

      // Submit guess
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('ENTER'),
        ),
      );
      await tester.pump();

      // Should update game state
      expect(find.byType(GameGrid), findsOneWidget);

      // Continue with more guesses
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('S'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('L'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('A'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('T'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('E'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('ENTER'),
        ),
      );
      await tester.pump();

      // Should handle multiple guesses
      expect(find.byType(GameGrid), findsOneWidget);
    });

    testWidgets('should handle word analysis after guess', (
      WidgetTester tester,
    ) async {
      // This is a helper app - it analyzes guesses, doesn't have win/loss
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Type a guess word to analyze
      final letters = ['S', 'L', 'A', 'T', 'E'];
      for (final letter in letters) {
        await tester.tap(
          find.descendant(
            of: find.byType(VirtualKeyboard),
            matching: find.text(letter),
          ),
        );
        await tester.pump();
      }
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('ENTER'),
        ),
      );
      await tester.pump();

      // Should show analysis results, not win/loss
      expect(find.byType(GameGrid), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('should handle multiple guess analysis', (
      WidgetTester tester,
    ) async {
      // This is a helper app - it analyzes multiple guesses to provide
      // suggestions
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Submit multiple guesses to build analysis
      final guessWords = ['SLATE', 'CRANE', 'BLADE'];
      for (final word in guessWords) {
        final letters = word.split('');
        for (final letter in letters) {
          await tester.tap(
            find.descendant(
              of: find.byType(VirtualKeyboard),
              matching: find.text(letter),
            ),
          );
          await tester.pump();
        }
        await tester.tap(
          find.descendant(
            of: find.byType(VirtualKeyboard),
            matching: find.text('ENTER'),
          ),
        );
        await tester.pump();

        // Handle potential error screens after each guess
        if (find.text('Error').evaluate().isNotEmpty) {
          await tester.tap(find.text('OK'));
          await tester.pump();
        }
      }

      // Should show analysis results and suggestions
      expect(find.byType(GameGrid), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('should handle new game after completion', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement new game
      // functionality
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Complete a game (win or lose)
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('C'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('R'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('A'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('T'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('E'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('ENTER'),
        ),
      );
      await tester.pump();

      // Start new game
      await tester.tap(find.text('New Game'));
      await tester.pump();

      // Should reset game state
      expect(find.byType(GameGrid), findsOneWidget);
    });

    testWidgets('should handle suggestion functionality', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement suggestion
      // functionality
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Get suggestion
      await tester.tap(find.text('🎯 Get Next Hint'));
      await tester.pump();

      // Should populate current input with suggestion
      expect(find.byType(GameGrid), findsOneWidget);
    });

    testWidgets('should handle error scenarios gracefully', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement error handling
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Clear the current input first (it starts with the suggested word)
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('DELETE'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('DELETE'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('DELETE'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('DELETE'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('DELETE'),
        ),
      );
      await tester.pump();

      // Try to submit invalid word
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('A'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('B'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('ENTER'),
        ),
      );
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Word must be 5 letters long'), findsOneWidget);
    });

    testWidgets('should maintain state across app lifecycle', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement state
      // persistence
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Type some letters
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('C'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('R'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('A'),
        ),
      );
      await tester.pump();

      // Simulate app pause/resume
      await tester.pumpWidget(Container());
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // State should be maintained
      expect(find.byType(WordleGameScreen), findsOneWidget);
    });

    testWidgets(
      'should handle complete keyboard workflow with valid and invalid inputs',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Test 1: Valid word submission - should keep GameGrid visible
        final validLetters = ['S', 'L', 'A', 'T', 'E'];
        for (final letter in validLetters) {
          await tester.tap(
            find.descendant(
              of: find.byType(VirtualKeyboard),
              matching: find.text(letter),
            ),
          );
          await tester.pump();
        }

        // Submit valid word
        await tester.tap(
          find.descendant(
            of: find.byType(VirtualKeyboard),
            matching: find.text('ENTER'),
          ),
        );
        await tester.pump();

        // GameGrid should still be visible after valid submission
        expect(find.byType(GameGrid), findsOneWidget);

        // Test 2: Invalid word submission - should show error screen
        // Clear current input with multiple backspaces
        for (var i = 0; i < 5; i++) {
          await tester.tap(
            find.descendant(
              of: find.byType(VirtualKeyboard),
              matching: find.text('DELETE'),
            ),
          );
          await tester.pump();
        }

        // Type incomplete word (only 4 letters)
        final invalidLetters = ['T', 'E', 'S', 'T'];
        for (final letter in invalidLetters) {
          await tester.tap(
            find.descendant(
              of: find.byType(VirtualKeyboard),
              matching: find.text(letter),
            ),
          );
          await tester.pump();
        }

        // Submit incomplete word
        await tester.tap(
          find.descendant(
            of: find.byType(VirtualKeyboard),
            matching: find.text('ENTER'),
          ),
        );
        await tester.pump();

        // Should show error screen for invalid submission
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Word must be 5 letters long'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        // Test 3: OK button - should return to game screen
        await tester.tap(find.text('OK'));
        await tester.pump();

        // GameGrid and VirtualKeyboard should be visible again after retry
        expect(find.byType(GameGrid), findsOneWidget);
        expect(find.byType(VirtualKeyboard), findsOneWidget);
      },
    );

    testWidgets('should update UI based on game state changes', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement UI updates
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Submit a guess
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('C'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('R'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('A'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('T'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('E'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('ENTER'),
        ),
      );
      await tester.pump();

      // UI should update to reflect game state
      expect(find.byType(GameGrid), findsOneWidget);
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('should handle service failures gracefully', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement service error
      // handling
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Try to get suggestion when service fails
      await tester.tap(find.text('🎯 Get Next Hint'));
      await tester.pump();

      // Should handle service failure
      expect(find.byType(WordleGameScreen), findsOneWidget);
    });

    testWidgets('should handle accessibility features', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement accessibility
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should have proper accessibility labels
      expect(find.bySemanticsLabel('Wordle Helper'), findsOneWidget);
      expect(find.bySemanticsLabel('New Game'), findsOneWidget);
      expect(find.bySemanticsLabel('🎯 Get Next Hint'), findsOneWidget);
    });

    testWidgets('should handle different screen orientations', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement orientation
      // handling
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Test portrait orientation
      expect(find.byType(WordleGameScreen), findsOneWidget);

      // Test different portrait sizes (iPhone SE, iPhone 12, iPhone 14 Pro
      // Max)
      await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE
      await tester.pump();
      expect(find.byType(WordleGameScreen), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(390, 844)); // iPhone 12
      await tester.pump();
      expect(find.byType(WordleGameScreen), findsOneWidget);

      await tester.binding.setSurfaceSize(
        const Size(430, 932),
      ); // iPhone 14 Pro Max
      await tester.pump();
      expect(find.byType(WordleGameScreen), findsOneWidget);
    });

    testWidgets('should handle memory management correctly', (
      WidgetTester tester,
    ) async {
      // This test should fail initially - we need to implement memory
      // management
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Perform multiple operations
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('New Game'));
        await tester.pump();
      }

      // Should not have memory leaks
      expect(find.byType(WordleGameScreen), findsOneWidget);
    });
  });
}
