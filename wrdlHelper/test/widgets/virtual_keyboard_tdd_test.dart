import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/widgets/virtual_keyboard_tdd.dart';

void main() {
  group('VirtualKeyboard TDD Tests', () {
    testWidgets('should display QWERTY layout correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: VirtualKeyboard(onKeyPress: (key) {})),
        ),
      );

      // Check first row: Q W E R T Y U I O P
      expect(find.text('Q'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
      expect(find.text('I'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);

      // Check second row: A S D F G H J K L
      expect(find.text('A'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('G'), findsOneWidget);
      expect(find.text('H'), findsOneWidget);
      expect(find.text('J'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);

      // Check third row: Z X C V B N M
      expect(find.text('Z'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('V'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);

      // Check action keys
      expect(find.text('ENTER'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
    });

    testWidgets('should call onKeyPress when letter key is tapped', (
      WidgetTester tester,
    ) async {
      String? pressedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: (key) => pressedKey = key),
          ),
        ),
      );

      // Tap letter Q
      await tester.tap(find.text('Q'));
      await tester.pump();

      expect(pressedKey, equals('Q'));

      // Tap letter A
      await tester.tap(find.text('A'));
      await tester.pump();

      expect(pressedKey, equals('A'));
    });

    testWidgets('should call onKeyPress when action key is tapped', (
      WidgetTester tester,
    ) async {
      String? pressedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: (key) => pressedKey = key),
          ),
        ),
      );

      // Tap ENTER
      await tester.tap(find.text('ENTER'));
      await tester.pump();

      expect(pressedKey, equals('ENTER'));

      // Tap DELETE
      await tester.tap(find.text('DELETE'));
      await tester.pump();

      expect(pressedKey, equals('DELETE'));
    });

    testWidgets('should show correct color states for keys', (
      WidgetTester tester,
    ) async {
      final keyColors = {
        'Q': Colors.green,
        'W': Colors.yellow,
        'E': Colors.grey,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: (key) {}, keyColors: keyColors),
          ),
        ),
      );

      // Check that Q key has green color
      final qKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('Q'),
          matching: find.byType(Material),
        ),
      );
      expect(qKeyFinder, findsOneWidget);
      final qKey = tester.widget<Material>(qKeyFinder);
      expect(qKey.color, equals(Colors.green));

      // Check that W key has yellow color
      final wKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('W'),
          matching: find.byType(Material),
        ),
      );
      expect(wKeyFinder, findsOneWidget);
      final wKey = tester.widget<Material>(wKeyFinder);
      expect(wKey.color, equals(Colors.yellow));

      // Check that E key has grey color
      final eKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('E'),
          matching: find.byType(Material),
        ),
      );
      expect(eKeyFinder, findsOneWidget);
      final eKey = tester.widget<Material>(eKeyFinder);
      expect(eKey.color, equals(Colors.grey));
    });

    testWidgets('should disable keys when in disabledKeys set', (
      WidgetTester tester,
    ) async {
      String? pressedKey;
      final disabledKeys = {'Q', 'W', 'ENTER'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(
              onKeyPress: (key) => pressedKey = key,
              disabledKeys: disabledKeys,
            ),
          ),
        ),
      );

      // Try to tap disabled Q key
      await tester.tap(find.text('Q'));
      await tester.pump();

      expect(pressedKey, isNull);

      // Try to tap disabled ENTER key
      await tester.tap(find.text('ENTER'));
      await tester.pump();

      expect(pressedKey, isNull);

      // Tap enabled A key should work
      await tester.tap(find.text('A'));
      await tester.pump();

      expect(pressedKey, equals('A'));
    });

    testWidgets('should show disabled state visually', (
      WidgetTester tester,
    ) async {
      final disabledKeys = {'Q', 'W'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(
              onKeyPress: (key) {},
              disabledKeys: disabledKeys,
            ),
          ),
        ),
      );

      // Check that disabled keys have grey color
      final qKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('Q'),
          matching: find.byType(Material),
        ),
      );
      expect(qKeyFinder, findsOneWidget);
      final qKey = tester.widget<Material>(qKeyFinder);
      expect(qKey.color, equals(Colors.grey[400]));

      final wKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('W'),
          matching: find.byType(Material),
        ),
      );
      expect(wKeyFinder, findsOneWidget);
      final wKey = tester.widget<Material>(wKeyFinder);
      expect(wKey.color, equals(Colors.grey[400]));
    });

    testWidgets('should have proper key sizing and spacing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: VirtualKeyboard(onKeyPress: (key) {})),
        ),
      );

      // Check that letter keys have proper size
      final qKey = tester.widget<Container>(
        find
            .ancestor(of: find.text('Q'), matching: find.byType(Container))
            .first,
      );

      expect(qKey.constraints?.minWidth, equals(32));
      expect(qKey.constraints?.minHeight, equals(48));
    });

    testWidgets('should handle rapid key tapping correctly', (
      WidgetTester tester,
    ) async {
      final pressedKeys = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: pressedKeys.add),
          ),
        ),
      );

      // Rapid taps
      await tester.tap(find.text('Q'));
      await tester.tap(find.text('W'));
      await tester.tap(find.text('E'));
      await tester.pump();

      expect(pressedKeys, equals(['Q', 'W', 'E']));
    });

    testWidgets('should handle all letter keys correctly', (
      WidgetTester tester,
    ) async {
      final pressedKeys = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: pressedKeys.add),
          ),
        ),
      );

      // Test all letter keys
      final letterKeys = [
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
        'A',
        'S',
        'D',
        'F',
        'G',
        'H',
        'J',
        'K',
        'L',
        'Z',
        'X',
        'C',
        'V',
        'B',
        'N',
        'M',
      ];

      for (final key in letterKeys) {
        await tester.tap(find.text(key));
        await tester.pump();
      }

      expect(pressedKeys, equals(letterKeys));
    });

    testWidgets('should handle action keys correctly', (
      WidgetTester tester,
    ) async {
      final pressedKeys = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: pressedKeys.add),
          ),
        ),
      );

      // Test action keys
      await tester.tap(find.text('ENTER'));
      await tester.pump();

      await tester.tap(find.text('DELETE'));
      await tester.pump();

      expect(pressedKeys, equals(['ENTER', 'DELETE']));
    });

    testWidgets('should maintain state across rebuilds', (
      WidgetTester tester,
    ) async {
      final pressedKeys = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: pressedKeys.add),
          ),
        ),
      );

      // Rebuild with same properties
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: pressedKeys.add),
          ),
        ),
      );

      await tester.tap(find.text('Q'));
      await tester.pump();

      expect(pressedKeys, equals(['Q']));
    });

    testWidgets('should handle empty disabledKeys set', (
      WidgetTester tester,
    ) async {
      final pressedKeys = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(
              onKeyPress: pressedKeys.add,
              disabledKeys: {},
            ),
          ),
        ),
      );

      // All keys should work
      await tester.tap(find.text('Q'));
      await tester.tap(find.text('ENTER'));
      await tester.pump();

      expect(pressedKeys, equals(['Q', 'ENTER']));
    });

    testWidgets('should handle empty keyColors set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: (key) {}, keyColors: {}),
          ),
        ),
      );

      // Should display all keys with default colors
      expect(find.text('Q'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Z'), findsOneWidget);
      expect(find.text('ENTER'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
    });

    testWidgets('should handle null onKeyPress callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: VirtualKeyboard(onKeyPress: null)),
        ),
      );

      // Should not crash when tapping keys
      await tester.tap(find.text('Q'));
      await tester.pump();

      expect(find.text('Q'), findsOneWidget);
    });

    testWidgets('should have proper accessibility support', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: VirtualKeyboard(onKeyPress: (key) {})),
        ),
      );

      final semantics = tester.getSemantics(find.byType(VirtualKeyboard));
      expect(semantics.label, contains('Virtual Keyboard'));
    });

    testWidgets('should handle special characters in key colors', (
      WidgetTester tester,
    ) async {
      final keyColors = {'É': Colors.green, 'Ñ': Colors.yellow};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(onKeyPress: (key) {}, keyColors: keyColors),
          ),
        ),
      );

      // Should handle special characters without crashing
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('should handle large disabledKeys set', (
      WidgetTester tester,
    ) async {
      final disabledKeys = {
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
        'A',
        'S',
        'D',
        'F',
        'G',
        'H',
        'J',
        'K',
        'L',
        'Z',
        'X',
        'C',
        'V',
        'B',
        'N',
        'M',
        'ENTER',
        'DELETE',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(
              onKeyPress: (key) {},
              disabledKeys: disabledKeys,
            ),
          ),
        ),
      );

      // All keys should be disabled
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('should handle mixed key states correctly', (
      WidgetTester tester,
    ) async {
      final keyColors = {
        'Q': Colors.green,
        'W': Colors.yellow,
        'E': Colors.grey,
      };
      final disabledKeys = {'R', 'T'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualKeyboard(
              onKeyPress: (key) {},
              keyColors: keyColors,
              disabledKeys: disabledKeys,
            ),
          ),
        ),
      );

      // Should handle both color states and disabled states
      expect(find.byType(VirtualKeyboard), findsOneWidget);
    });

    testWidgets('should maintain keyboard layout consistency', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: VirtualKeyboard(onKeyPress: (key) {})),
        ),
      );

      // Should have exactly 3 rows
      expect(find.byType(Row), findsNWidgets(3));

      // First row should have 10 keys (Q-P)
      final firstRowKeys = find.descendant(
        of: find.byType(Row).at(0),
        matching: find.byType(Container),
      );
      expect(firstRowKeys, findsNWidgets(10));

      // Second row should have 9 keys (A-L)
      final secondRowKeys = find.descendant(
        of: find.byType(Row).at(1),
        matching: find.byType(Container),
      );
      expect(secondRowKeys, findsNWidgets(9));

      // Third row should have 9 keys (Z-M + ENTER + DELETE)
      final thirdRowKeys = find.descendant(
        of: find.byType(Row).at(2),
        matching: find.byType(Container),
      );
      expect(thirdRowKeys, findsNWidgets(9));
    });
  });
}
