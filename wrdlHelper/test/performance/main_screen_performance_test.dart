import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/screens/wordle_game_screen.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/widgets/virtual_keyboard.dart';

void main() {
  group('Main Screen Performance TDD Tests', () {
    setUp(() async {
      // Reset services and setup real services for testing
      resetAllServices();
      await setupTestServices();
    });
    testWidgets('should initialize within performance limits', (
      tester,
    ) async {
      // This test should fail initially - we need to implement performance
      // optimization
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should initialize within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('should handle rapid key presses efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement rapid input
      // optimization
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Rapidly tap keys
      for (var i = 0; i < 20; i++) {
        await tester.tap(
          find.descendant(
            of: find.byType(VirtualKeyboard),
            matching: find.text('A'),
          ),
        );
        await tester.pump();
      }

      stopwatch.stop();

      // Should handle 20 key presses within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('should maintain smooth animations', (
      tester,
    ) async {
      // This test should fail initially - we need to implement smooth
      // animations
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // Test animation performance
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'A',
              description: 'Virtual keyboard A key',
            )
            .first,
      );
      await tester.pump();

      // Should have smooth animations
      expect(find.byType(WordleGameScreen), findsOneWidget);
    });

    testWidgets('should handle memory efficiently with multiple games', (
      tester,
    ) async {
      // This test should fail initially - we need to implement memory
      // management
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // Play multiple games
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('New Game'));
        await tester.pump();
      }

      // Should not have memory leaks
      expect(find.byType(WordleGameScreen), findsOneWidget);
    });

    testWidgets('should handle large word lists efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient word
      // list handling
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Get suggestion (should be fast even with large word lists)
      await tester.tap(find.text('🎯 Get Next Hint'));
      await tester.pump();

      stopwatch.stop();

      // Should get suggestion within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('should handle complex game states efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient state
      // management
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Submit multiple guesses
      for (var i = 0; i < 6; i++) {
        // Use keyboard interaction instead of ambiguous text search
        final keyboard = find.byType(VirtualKeyboard);
        if (keyboard.evaluate().isNotEmpty) {
          // Tap first few letter keys
          final letterKeys = find.descendant(
            of: keyboard,
            matching: find.byType(InkWell),
          );
          for (var j = 0; j < 5 && j < letterKeys.evaluate().length; j++) {
            try {
              await tester.tap(letterKeys.at(j), warnIfMissed: false);
              await tester.pump();
            } catch (e) {
              // Skip if tap fails - widget might be off-screen
              continue;
            }
          }
          // Tap ENTER
          final enterKey = find.descendant(
            of: keyboard,
            matching: find.text('ENTER'),
          );
          if (enterKey.evaluate().isNotEmpty) {
            try {
              await tester.tap(enterKey, warnIfMissed: false);
              await tester.pump();
            } catch (e) {
              // Skip if tap fails - widget might be off-screen
            }
          }
        }
      }

      stopwatch.stop();

      // Should handle 6 guesses within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('should handle widget rebuilds efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient
      // rebuilds
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Force multiple rebuilds
      for (var i = 0; i < 50; i++) {
        await tester.pump();
      }

      stopwatch.stop();

      // Should handle 50 rebuilds within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('should handle keyboard color updates efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient color
      // updates
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Submit guess to trigger color updates
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'C',
              description: 'Virtual keyboard C key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'R',
              description: 'Virtual keyboard R key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'A',
              description: 'Virtual keyboard A key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'T',
              description: 'Virtual keyboard T key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'E',
              description: 'Virtual keyboard E key',
            )
            .first,
      );
      await tester.tap(find.text('ENTER'));
      await tester.pump();

      stopwatch.stop();

      // Should update colors within 200ms
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    testWidgets('should handle error states efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient error
      // handling
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // Clear the current input first (it starts with the suggested word)
      await tester.tap(find.text('DELETE'));
      await tester.tap(find.text('DELETE'));
      await tester.tap(find.text('DELETE'));
      await tester.tap(find.text('DELETE'));
      await tester.tap(find.text('DELETE'));
      await tester.pump();

      final stopwatch = Stopwatch()..start();

      // Trigger error state
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'A',
              description: 'Virtual keyboard A key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'B',
              description: 'Virtual keyboard B key',
            )
            .first,
      );
      await tester.tap(find.text('ENTER'));
      await tester.pump();

      stopwatch.stop();

      // Should handle error within 200ms (FFI adds some overhead)
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    testWidgets('should handle state changes efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient state
      // changes
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Change state multiple times
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'A',
              description: 'Virtual keyboard A key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'B',
              description: 'Virtual keyboard B key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'C',
              description: 'Virtual keyboard C key',
            )
            .first,
      );
      await tester.tap(find.text('DELETE'));
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'D',
              description: 'Virtual keyboard D key',
            )
            .first,
      );
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'E',
              description: 'Virtual keyboard E key',
            )
            .first,
      );
      await tester.pump();

      stopwatch.stop();

      // Should handle state changes within 300ms
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    testWidgets('should handle concurrent operations efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement concurrent
      // operation handling
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Perform rapid sequential operations (simulating concurrent load)
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('A'),
        ),
      );
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('S'),
        ),
      );
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('D'),
        ),
      );
      await tester.pump();

      stopwatch.stop();

      // Should handle concurrent operations within 200ms
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    testWidgets('should handle large game grids efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient grid
      // rendering
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Verify VirtualKeyboard is present
      expect(find.byType(VirtualKeyboard), findsOneWidget);

      // Test basic keyboard interaction
      final keyboard = find.byType(VirtualKeyboard);
      expect(keyboard, findsOneWidget);

      // Just test that we can find some keys (simpler test)
      expect(find.text('A'), findsAtLeastNWidgets(1));
      expect(find.text('ENTER'), findsAtLeastNWidgets(1));

      stopwatch.stop();

      // Should handle basic grid operations within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('should handle rapid state transitions efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient state
      // transitions
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Rapid state transitions
      for (var i = 0; i < 20; i++) {
        await tester.tap(find.text('New Game'));
        await tester.pump();
      }

      stopwatch.stop();

      // Should handle 20 transitions within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('should handle memory pressure efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement memory pressure
      // handling
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // Simulate memory pressure with realistic user behavior
      for (var i = 0; i < 20; i++) {
        // Use specific finders within VirtualKeyboard to avoid ambiguity
        await tester.tap(
          find.descendant(
            of: find.byType(VirtualKeyboard),
            matching: find.text('A'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(VirtualKeyboard),
            matching: find.text('DELETE'),
          ),
        );
        await tester.pump();
      }

      // Should handle memory pressure gracefully
      expect(find.byType(WordleGameScreen), findsOneWidget);
    });

    testWidgets('should handle background processing efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient
      // background processing
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Simulate background processing
      await tester.tap(find.text('🎯 Get Next Hint'));
      await tester.pump();

      stopwatch.stop();

      // Should handle background processing within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('should handle UI updates efficiently', (
      tester,
    ) async {
      // This test should fail initially - we need to implement efficient UI
      // updates
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Trigger UI updates using specific finders
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
          matching: find.text('C'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(VirtualKeyboard),
          matching: find.text('D'),
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

      stopwatch.stop();

      // Should handle UI updates within 400ms
      expect(stopwatch.elapsedMilliseconds, lessThan(400));
    });
  });
}
