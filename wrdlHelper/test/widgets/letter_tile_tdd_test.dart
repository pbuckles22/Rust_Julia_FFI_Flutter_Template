import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/widgets/letter_tile_tdd.dart';
import 'package:wrdlhelper/service_locator.dart';

void main() {
  group('LetterTile TDD Tests', () {
    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });
    
    tearDownAll(resetAllServices);
    testWidgets('should display letter correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'A', onTap: () {}),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should display empty tile when letter is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LetterTile(letter: null, onTap: () {})),
        ),
      );

      // Empty tile should not display any text
      expect(find.text('A'), findsNothing);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'A', onTap: () => wasTapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(LetterTile));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should show correct color for gray state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.gray,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.grey[400]));
    });

    testWidgets('should show correct color for yellow state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.yellow,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.yellow[400]));
    });

    testWidgets('should show correct color for green state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.green,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.green[400]));
    });

    testWidgets('should show default color when state is not specified', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'A', onTap: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.grey[200]));
    });

    testWidgets('should show disabled state when disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'A', isDisabled: true, onTap: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.grey[300]));
    });

    testWidgets('should not call onTap when disabled', (
      tester,
    ) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              isDisabled: true,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LetterTile));
      await tester.pump();

      expect(wasTapped, isFalse);
    });

    testWidgets('should show correct text color for different states', (
      tester,
    ) async {
      // Test gray state text color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.gray,
              onTap: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('A'));
      expect(textWidget.style?.color, equals(Colors.white));

      // Test yellow state text color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.yellow,
              onTap: () {},
            ),
          ),
        ),
      );

      final yellowTextWidget = tester.widget<Text>(find.text('A'));
      expect(yellowTextWidget.style?.color, equals(Colors.white));

      // Test green state text color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.green,
              onTap: () {},
            ),
          ),
        ),
      );

      final greenTextWidget = tester.widget<Text>(find.text('A'));
      expect(greenTextWidget.style?.color, equals(Colors.white));
    });

    testWidgets('should have proper sizing constraints', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'A', onTap: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.minWidth, equals(48));
      expect(container.constraints?.minHeight, equals(48));
    });

    testWidgets('should have proper border radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'A', onTap: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LetterTile),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(4)));
    });

    testWidgets('should show letter in uppercase', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'a', onTap: () {}),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should handle special characters correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'É', onTap: () {}),
          ),
        ),
      );

      expect(find.text('É'), findsOneWidget);
    });

    testWidgets('should have proper accessibility support', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.green,
              onTap: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(LetterTile));
      expect(semantics.label, contains('A'));
      expect(semantics.label, contains('green'));
    });

    testWidgets('should handle rapid tapping correctly', (
      tester,
    ) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(letter: 'A', onTap: () => tapCount++),
          ),
        ),
      );

      // Rapid taps
      await tester.tap(find.byType(LetterTile));
      await tester.tap(find.byType(LetterTile));
      await tester.tap(find.byType(LetterTile));
      await tester.pump();

      expect(tapCount, equals(3));
    });

    testWidgets('should maintain state across rebuilds', (
      tester,
    ) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.green,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Rebuild with same properties
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetterTile(
              letter: 'A',
              state: LetterState.green,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LetterTile));
      await tester.pump();

      expect(wasTapped, isTrue);
      expect(find.text('A'), findsOneWidget);
    });
  });
}
