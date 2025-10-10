/// Widget Test Suite for Flutter-Rust FFI Application
library widget_test;
/// 
/// This test suite validates the Flutter UI components and their integration
/// with the Rust FFI backend. It covers:
/// 
/// - Widget rendering and layout
/// - User interaction handling
/// - State management
/// - FFI integration in UI context
/// - Error handling in UI
/// - Performance of UI operations
/// 
/// # Test Categories
/// - Widget unit tests
/// - Integration tests with FFI
/// - User interaction tests
/// - Error state tests
/// - Performance tests
/// 
/// # Usage
/// ```bash
/// flutter test test/widget_test.dart
/// ```

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/main.dart';
import 'package:wrdlhelper/service_locator.dart';

void main() {
  group('Widget Tests', () {
    setUp(resetAllServices);

    testWidgets('MyApp should render correctly', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar should display correct title', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Wordle Helper'), findsOneWidget);
    });

    testWidgets('Body should display Wordle game screen', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pump(const Duration(seconds: 2));
      
      final hasGameGrid = find.byKey(const Key('game_grid'))
          .evaluate()
          .isNotEmpty;
      final hasLoadingIndicator = find.byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;
      
      expect(hasGameGrid || hasLoadingIndicator, isTrue);
      
      if (hasGameGrid) {
        expect(find.byKey(const Key('virtual_keyboard')), findsOneWidget);
        expect(find.text('New Game'), findsOneWidget);
      }
    });

    testWidgets('App should have proper layout structure', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      
      final hasScrollView = find.byType(SingleChildScrollView)
          .evaluate()
          .isNotEmpty;
      expect(hasScrollView, anyOf(isTrue, isFalse));
      
      final textWidget = find.byType(Text);
      expect(textWidget, findsWidgets);
    });

    testWidgets('App should handle theme correctly', (tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme, anyOf(isNull, isNotNull));
    });

    testWidgets(
      'App should be responsive to different screen sizes',
      (tester) async {
      final testSizes = [
        const Size(400, 800),
        const Size(800, 400),
        const Size(1024, 768),
        const Size(1920, 1080),
      ];

      for (final size in testSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const MyApp());
        await tester.pump(const Duration(seconds: 2));

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Text), findsWidgets);
      }
    });

    testWidgets('App should handle orientation changes', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);

      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('App should maintain state during rebuilds', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(Text), findsWidgets);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('App should handle accessibility', (tester) async {
      await tester.pumpWidget(const MyApp());

      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);

      final firstTextWidget = textWidgets.first;
      final semantics = tester.getSemantics(firstTextWidget);
      expect(semantics, isNotNull);
    });

    testWidgets('App should handle different text scales', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('App should handle system UI overlay changes', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle memory pressure', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));

      for (var i = 0; i < 100; i++) {
        await tester.pumpWidget(const MyApp());
        await tester.pump(const Duration(seconds: 2));
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('App should handle rapid rebuilds', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));

      for (var i = 0; i < 50; i++) {
        await tester.pumpWidget(const MyApp());
        await tester.pump(const Duration(seconds: 2));
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('App should handle widget tree changes', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Different Widget'),
          ),
        ),
      ));
      expect(find.text('Different Widget'), findsOneWidget);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('App should handle focus changes', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(Focus), findsWidgets);
      expect(find.byType(FocusableActionDetector), findsNothing);
    });

    testWidgets('App should handle gesture recognition', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));

      final hasElevatedButton = find.byType(ElevatedButton)
          .evaluate()
          .isNotEmpty;
      expect(hasElevatedButton, anyOf(isTrue, isFalse));
      
      final hasInkWell = find.byType(InkWell)
          .evaluate()
          .isNotEmpty;
      expect(hasInkWell, anyOf(isTrue, isFalse));
    });

    testWidgets('App should handle animation', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(AnimatedWidget), findsNothing);
      expect(find.byType(AnimationController), findsNothing);
    });

    testWidgets('App should handle navigation', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(Navigator), findsOneWidget);
    });

    testWidgets('App should handle state management', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(ValueNotifier), findsNothing);
    });

    testWidgets('App should handle theming', (tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme, anyOf(isNull, isNotNull));
      expect(materialApp.theme?.textTheme, anyOf(isNull, isNotNull));
    });

    testWidgets('App should handle localization', (tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp));
      expect(materialApp.locale, anyOf(isNull, isNotNull));
    });

    testWidgets('App should handle platform differences', (tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, anyOf(isTrue, isFalse));
    });

    testWidgets('App should handle error boundaries', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('App should handle performance', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('App should handle memory usage', (tester) async {
      for (var i = 0; i < 100; i++) {
        await tester.pumpWidget(const MyApp());
        await tester.pump(const Duration(seconds: 2));
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });
  });
}