import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/widgets/virtual_keyboard.dart';

void main() {
  group('VirtualKeyboard', () {
    testWidgets('displays QWERTY layout', (WidgetTester tester) async {
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

    testWidgets('calls onKeyPress when letter key is tapped', (
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

    testWidgets('calls onKeyPress when action key is tapped', (
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

    testWidgets('shows correct color states for keys', (
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
          matching: find.byType(Container),
        ),
      );
      expect(qKeyFinder, findsWidgets);
      final qKey = tester.widget<Container>(qKeyFinder.last);
      final decoration = qKey.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.green));

      // Check that W key has yellow color
      final wKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('W'),
          matching: find.byType(Container),
        ),
      );
      expect(wKeyFinder, findsWidgets);
      final wKey = tester.widget<Container>(wKeyFinder.last);
      final wDecoration = wKey.decoration as BoxDecoration;
      expect(wDecoration.color, equals(Colors.yellow));

      // Check that E key has grey color
      final eKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('E'),
          matching: find.byType(Container),
        ),
      );
      expect(eKeyFinder, findsWidgets);
      final eKey = tester.widget<Container>(eKeyFinder.last);
      final eDecoration = eKey.decoration as BoxDecoration;
      expect(eDecoration.color, equals(Colors.grey));
    });

    testWidgets('disables keys when in disabledKeys set', (
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

    testWidgets('shows disabled state visually', (WidgetTester tester) async {
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
          matching: find.byType(Container),
        ),
      );
      expect(qKeyFinder, findsWidgets);
      final qKey = tester.widget<Container>(qKeyFinder.last);
      final decoration = qKey.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF787C7E)));

      final wKeyFinder = find.descendant(
        of: find.byType(VirtualKeyboard),
        matching: find.ancestor(
          of: find.text('W'),
          matching: find.byType(Container),
        ),
      );
      expect(wKeyFinder, findsWidgets);
      final wKey = tester.widget<Container>(wKeyFinder.last);
      final wDecoration = wKey.decoration as BoxDecoration;
      expect(wDecoration.color, equals(const Color(0xFF787C7E)));
    });

    testWidgets('has proper key sizing and spacing', (
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

      // With flexible layout, keys adapt to available space
      expect(qKey.constraints?.minWidth, greaterThan(0));
      expect(qKey.constraints?.minHeight, greaterThan(0));
    });
  });
}
