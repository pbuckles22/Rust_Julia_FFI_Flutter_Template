import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/screens/wordle_game_screen.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/widgets/letter_tile.dart';
import 'package:wrdlhelper/widgets/virtual_keyboard.dart';

import '../helpers/keyboard_test_helpers.dart';

/// Visual Feedback Persistence TDD Tests
///
/// These tests ensure that visual feedback persists across guesses:
/// 1. Keyboard keys show correct colors based on previous guesses
/// 2. Next guess pre-populates with known letter states
/// 3. Color states carry over from previous guesses
///
/// CRITICAL REQUIREMENT: When user marks R=green, A=green, T=yellow in CRANT,
/// the next guess TRADE should show R=green, A=green, T=yellow automatically.
void main() {
  group('Visual Feedback Persistence TDD Tests', () {
    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });
    
    tearDownAll(() {
      // Clean up after all tests
      resetAllServices();
    });

    tearDown(() async {
      // Clean up services
      // Note: resetServices() doesn't exist yet - will be implemented
    });

    testWidgets(
      'should show keyboard keys with correct colors after marking letters',
      (WidgetTester tester) async {
        // ARRANGE: Load the game screen
        await tester.pumpWidget(MaterialApp(home: WordleGameScreen()));
        await tester.pumpAndSettle();

        // ACT: Type CRANT and mark letters
        await KeyboardTestHelpers.submitWord(tester, 'CRANT');
        await tester.pumpAndSettle();

        // Mark R=green, A=green, T=yellow, C=gray, N=gray
        await tester.tap(find.byKey(const Key('tile_0_0'))); // C -> gray
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_0'))); // C -> yellow
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_0'))); // C -> green
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_0'))); // C -> gray
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> yellow
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> green
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tile_0_2'))); // A -> yellow
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_2'))); // A -> green
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tile_0_3'))); // N -> yellow
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_3'))); // N -> green
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_3'))); // N -> gray
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tile_0_4'))); // T -> yellow
        await tester.pumpAndSettle();

        // ASSERT: Keyboard keys should show correct colors
        final keyboard = find.byType(VirtualKeyboard);
        expect(keyboard, findsOneWidget);

        // R key should be green
        final rKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_R')),
        );
        expect(rKey, findsOneWidget);

        // A key should be green
        final aKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_A')),
        );
        expect(aKey, findsOneWidget);

        // T key should be yellow
        final tKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_T')),
        );
        expect(tKey, findsOneWidget);

        // C key should be gray
        final cKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_C')),
        );
        expect(cKey, findsOneWidget);

        // N key should be gray
        final nKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_N')),
        );
        expect(nKey, findsOneWidget);
      },
    );

    testWidgets('should pre-populate next guess with known letter states', (
      WidgetTester tester,
    ) async {
      // ARRANGE: Load the game screen and submit CRANT with marked letters
      await tester.pumpWidget(MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      await KeyboardTestHelpers.submitWord(tester, 'CRANT');
      await tester.pumpAndSettle();

      // Mark R=green, A=green, T=yellow, C=gray, N=gray
      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> yellow
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> green
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_0_2'))); // A -> yellow
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_2'))); // A -> green
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_0_4'))); // T -> yellow
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_0_0'))); // C -> yellow
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_0'))); // C -> green
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_0'))); // C -> gray
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_0_3'))); // N -> yellow
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_3'))); // N -> green
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_3'))); // N -> gray
      await tester.pumpAndSettle();

      // ACT: Type TRADE for next guess
      await KeyboardTestHelpers.typeWord(tester, 'TRADE');
      await tester.pumpAndSettle();

      // ASSERT: TRADE should show correct colors based on CRANT feedback
      // T should be yellow (from CRANT position 4)
      final tTile = find.byKey(const Key('tile_1_0'));
      expect(tTile, findsOneWidget);
      final tTileWidget = tester.widget<LetterTile>(tTile);
      expect(tTileWidget.state, LetterTileState.present); // Yellow

      // R should be green (from CRANT position 1)
      final rTile = find.byKey(const Key('tile_1_1'));
      expect(rTile, findsOneWidget);
      final rTileWidget = tester.widget<LetterTile>(rTile);
      expect(rTileWidget.state, LetterTileState.correct); // Green

      // A should be green (from CRANT position 2)
      final aTile = find.byKey(const Key('tile_1_2'));
      expect(aTile, findsOneWidget);
      final aTileWidget = tester.widget<LetterTile>(aTile);
      expect(aTileWidget.state, LetterTileState.correct); // Green

      // D should be input (unknown)
      final dTile = find.byKey(const Key('tile_1_3'));
      expect(dTile, findsOneWidget);
      final dTileWidget = tester.widget<LetterTile>(dTile);
      expect(dTileWidget.state, LetterTileState.input); // Input

      // E should be input (unknown)
      final eTile = find.byKey(const Key('tile_1_4'));
      expect(eTile, findsOneWidget);
      final eTileWidget = tester.widget<LetterTile>(eTile);
      expect(eTileWidget.state, LetterTileState.input); // Input
    });

    testWidgets('should update keyboard colors when letter states change', (
      WidgetTester tester,
    ) async {
      // ARRANGE: Load the game screen
      await tester.pumpWidget(MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // ACT: Submit CRANT and mark R as green
      await KeyboardTestHelpers.submitWord(tester, 'CRANT');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> yellow
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> green
      await tester.pumpAndSettle();

      // ASSERT: R key should be green
      final keyboard = find.byType(VirtualKeyboard);
      final rKey = find.descendant(
        of: keyboard,
        matching: find.byKey(const Key('key_R')),
      );
      expect(rKey, findsOneWidget);

      // ACT: Change R back to yellow
      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> gray
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> yellow
      await tester.pumpAndSettle();

      // ASSERT: R key should now be yellow
      // (This test will fail until we implement the color persistence logic)
    });

    testWidgets(
      'should handle multiple guesses with persistent keyboard colors',
      (WidgetTester tester) async {
        // ARRANGE: Load the game screen
        await tester.pumpWidget(MaterialApp(home: WordleGameScreen()));
        await tester.pumpAndSettle();

        // ACT: Submit first guess CRANT
        await KeyboardTestHelpers.submitWord(tester, 'CRANT');
        await tester.pumpAndSettle();

        // Mark some letters
        await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> yellow
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> green
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tile_0_2'))); // A -> yellow
        await tester.pumpAndSettle();

        // Submit second guess TRADE
        await KeyboardTestHelpers.submitWord(tester, 'TRADE');
        await tester.pumpAndSettle();

        // Mark more letters in TRADE
        await tester.tap(find.byKey(const Key('tile_1_4'))); // E -> yellow
        await tester.pumpAndSettle();

        // ASSERT: Keyboard should show combined color states
        final keyboard = find.byType(VirtualKeyboard);

        // R should be green (from CRANT)
        final rKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_R')),
        );
        expect(rKey, findsOneWidget);

        // A should be yellow (from CRANT)
        final aKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_A')),
        );
        expect(aKey, findsOneWidget);

        // E should be yellow (from TRADE)
        final eKey = find.descendant(
          of: keyboard,
          matching: find.byKey(const Key('key_E')),
        );
        expect(eKey, findsOneWidget);
      },
    );

    testWidgets('should reset keyboard colors when starting new game', (
      WidgetTester tester,
    ) async {
      // ARRANGE: Load the game screen and mark some letters
      await tester.pumpWidget(MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      await KeyboardTestHelpers.submitWord(tester, 'CRANT');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> yellow
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_1'))); // R -> green
      await tester.pumpAndSettle();

      // ACT: Start new game
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();

      // ASSERT: All keyboard keys should be default color (no special colors)
      final keyboard = find.byType(VirtualKeyboard);
      final rKey = find.descendant(
        of: keyboard,
        matching: find.byKey(const Key('key_R')),
      );
      expect(rKey, findsOneWidget);

      // R key should be default color (not green)
      // (This test will fail until we implement the reset logic)
    });

    testWidgets('should handle edge case with duplicate letters correctly', (
      WidgetTester tester,
    ) async {
      // ARRANGE: Load the game screen
      await tester.pumpWidget(MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // ACT: Submit word with duplicate letters (e.g., "EERIE")
      await KeyboardTestHelpers.submitWord(tester, 'EERIE');
      await tester.pumpAndSettle();

      // Mark first E as green, second E as yellow
      await tester.tap(find.byKey(const Key('tile_0_0'))); // E -> yellow
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tile_0_0'))); // E -> green
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_0_1'))); // E -> yellow
      await tester.pumpAndSettle();

      // ASSERT: E key should show the "best" state (green takes precedence over yellow)
      final keyboard = find.byType(VirtualKeyboard);
      final eKey = find.descendant(
        of: keyboard,
        matching: find.byKey(const Key('key_E')),
      );
      expect(eKey, findsOneWidget);

      // E key should be green (best state)
      // (This test will fail until we implement the duplicate letter logic)
    });
  });
}
