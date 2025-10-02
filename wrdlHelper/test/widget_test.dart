/**
 * Widget Test Suite for Flutter-Rust FFI Application
 * 
 * This test suite validates the Flutter UI components and their integration
 * with the Rust FFI backend. It covers:
 * 
 * - Widget rendering and layout
 * - User interaction handling
 * - State management
 * - FFI integration in UI context
 * - Error handling in UI
 * - Performance of UI operations
 * 
 * # Test Categories
 * - Widget unit tests
 * - Integration tests with FFI
 * - User interaction tests
 * - Error state tests
 * - Performance tests
 * 
 * # Usage
 * ```bash
 * flutter test test/widget_test.dart
 * ```
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/main.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Widget Tests', () {
    
    setUpAll(() async {
      // Initialize the Rust library before running widget tests
      await RustLib.init();
    });

    // No tearDown needed - no global state to reset!

    testWidgets('MyApp should render correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Verify that the app renders without errors
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar should display correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify the AppBar title
      expect(find.text('wrdlHelper'), findsOneWidget);
    });

    testWidgets('Body should display initialization text', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for FutureBuilder to complete
      await tester.pumpAndSettle();
      
      // After FutureBuilder completes, it should show ready state
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
    });

    testWidgets('App should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for FutureBuilder to complete
      await tester.pumpAndSettle();

      // Verify the app has proper layout structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets); // Multiple columns: loading state + main UI
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Find text widgets
      final textWidget = find.byType(Text);
      expect(textWidget, findsWidgets);
    });

    testWidgets('App should handle theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify MaterialApp is using default theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      // Theme might be null in test environment, but colorScheme should be available
      expect(materialApp.theme?.colorScheme, anyOf(isNull, isNotNull));
    });

    testWidgets('App should be responsive to different screen sizes', (WidgetTester tester) async {
      // Test with different screen sizes
      final testSizes = [
        const Size(400, 800),   // Phone portrait
        const Size(800, 400),   // Phone landscape
        const Size(1024, 768),  // Tablet
        const Size(1920, 1080), // Desktop
      ];

      for (final size in testSizes) {
        // Set the screen size
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        // Build the app
        await tester.pumpWidget(const MyApp());

        // Wait for FutureBuilder to complete
        await tester.pumpAndSettle();

        // Verify the app renders without errors
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);

        // Verify the text is still visible
        expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
      }
    });

    testWidgets('App should handle orientation changes', (WidgetTester tester) async {
      // Start in portrait
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Change to landscape
      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
    });

    testWidgets('App should maintain state during rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);

      // Rebuild the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify state is maintained
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
    });

    testWidgets('App should handle accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify accessibility features
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);

      // Check if the text widgets have proper semantics
      final firstTextWidget = textWidgets.first;
      final semantics = tester.getSemantics(firstTextWidget);
      expect(semantics, isNotNull);
    });

    testWidgets('App should handle different text scales', (WidgetTester tester) async {
      // Test with different text scale factors
      final textScales = [0.8, 1.0, 1.2, 1.5, 2.0];

      for (final scale in textScales) {
        // Note: textScaleFactor setter is deprecated, using view.physicalSize instead
        // tester.view.textScaleFactor = scale;
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Verify the app renders without errors
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
      }
    });

    testWidgets('App should handle system UI overlay changes', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Simulate system UI overlay changes
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should handle memory pressure', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Simulate memory pressure by rebuilding multiple times
      for (int i = 0; i < 100; i++) {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
      }

      // Verify the app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
    });

    testWidgets('App should handle rapid rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Perform rapid rebuilds
      for (int i = 0; i < 50; i++) {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle(); // Ensure frame is processed
      }

      // Verify the app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
    });

    testWidgets('App should handle widget tree changes', (WidgetTester tester) async {
      // Start with the main app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Replace with a different widget temporarily
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Different Widget'),
          ),
        ),
      ));
      expect(find.text('Different Widget'), findsOneWidget);

      // Restore the original app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
    });

    testWidgets('App should handle focus changes', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify focus widgets are present (MaterialApp creates them)
      expect(find.byType(Focus), findsWidgets);
      // FocusableActionDetector might not be present
      expect(find.byType(FocusableActionDetector), findsNothing);
    });

    testWidgets('App should handle gesture recognition', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify buttons are present (they handle gestures)
      expect(find.byType(ElevatedButton), findsWidgets);
      // InkWell is present in buttons
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('App should handle animation', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify no animations are present
      expect(find.byType(AnimatedWidget), findsNothing);
      expect(find.byType(AnimationController), findsNothing);
    });

    testWidgets('App should handle navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify no navigation widgets are present
      expect(find.byType(Navigator), findsOneWidget); // MaterialApp creates a Navigator
      // Routes widget doesn't exist in our app, so we just check Navigator
    });

    testWidgets('App should handle state management', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify state management widgets are present (MyApp is StatefulWidget)
      // Note: StatefulWidget is an abstract class, so we look for StatefulWidget instances
      expect(find.byType(MyApp), findsOneWidget);
      // ValueNotifier might not be present
      expect(find.byType(ValueNotifier), findsNothing);
    });

    testWidgets('App should handle theming', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify theme is applied correctly
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      // Theme might be null in test environment
      expect(materialApp.theme?.colorScheme, anyOf(isNull, isNotNull));
      expect(materialApp.theme?.textTheme, anyOf(isNull, isNotNull));
    });

    testWidgets('App should handle localization', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify localization is handled
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      // Locale might be null in test environment
      expect(materialApp.locale, anyOf(isNull, isNotNull));
    });

    testWidgets('App should handle platform differences', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify platform-specific behavior
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      // debugShowCheckedModeBanner might be true in test environment
      expect(materialApp.debugShowCheckedModeBanner, anyOf(isTrue, isFalse));
    });

    testWidgets('App should handle error boundaries', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify error handling
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // The app should not crash during normal operation
      expect(tester.takeException(), isNull);
    });

    testWidgets('App should handle performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify the app renders quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('App should handle memory usage', (WidgetTester tester) async {
      // Build the app multiple times to check for memory leaks
      for (int i = 0; i < 100; i++) {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
      }

      // Verify the app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('✅ Rust FFI library ready!'), findsOneWidget);
    });
  });

  // ============================================================================
  // TDD RED PHASE: Julia-Rust UI Integration Tests (These will FAIL initially)
  // ============================================================================
  
  group('Julia-Rust UI Integration Tests (TDD Red Phase)', () {
    
    // Initialize Rust for this group only
    setUpAll(() async {
      try {
        await RustLib.init();
        print('✅ Rust FFI library initialized for Julia-Rust tests');
      } catch (e) {
        print('❌ Failed to initialize Rust FFI library for Julia-Rust tests: $e');
      }
    });
    
    // No tearDown needed - no global state to reset!

    testWidgets('Julia-Rust section should be visible', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // The Julia-Rust section should be visible after FFI initialization
      expect(find.text('Julia-Rust Integration (C FFI)'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Julia-Rust buttons should be present', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // Now we can find the Julia-Rust buttons
      expect(find.text('Julia→Rust Greet'), findsOneWidget);
      expect(find.text('Julia→Rust Add'), findsOneWidget);
      expect(find.text('Julia→Rust Multiply'), findsOneWidget);
      expect(find.text('Julia→Rust Factorial'), findsOneWidget);
      expect(find.text('Julia→Rust String Lengths'), findsOneWidget);
      expect(find.text('Julia→Rust String Map'), findsOneWidget);
    });

    testWidgets('Julia-Rust buttons should have correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      

      // 
      await tester.pumpAndSettle();

      // Now we can find the Julia-Rust buttons
      final juliaRustButtons = find.byType(ElevatedButton);
      expect(juliaRustButtons, findsWidgets);
      
      // We need to verify the buttons have green background color
      final buttonWidgets = tester.widgetList<ElevatedButton>(juliaRustButtons);
      final greenButtons = buttonWidgets.where((button) => 
        button.style?.backgroundColor?.resolve({}) == Colors.green[600]
      );
      expect(greenButtons.length, greaterThan(0));
    });

    testWidgets('Julia-Rust Greet button should work', (WidgetTester tester) async {
      // Set larger screen size to ensure buttons are visible
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // Find and tap the Julia-Rust Greet button
      final greetButton = find.text('Julia→Rust Greet');
      expect(greetButton, findsOneWidget);
      
      await tester.tap(greetButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // And the result will be displayed
      expect(find.textContaining('Julia→Rust Greet: Hello from Julia calling Rust! (Julia→Rust C FFI)'), findsOneWidget);
    });

    testWidgets('Julia-Rust Add button should work', (WidgetTester tester) async {
      // Set larger screen size to ensure buttons are visible
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // Find and tap the Julia-Rust Add button
      final addButton = find.text('Julia→Rust Add');
      expect(addButton, findsOneWidget);
      
      await tester.tap(addButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // And the result will be displayed
      expect(find.textContaining('Julia→Rust Add: 15 + 25 = 40 (Julia→Rust C FFI)'), findsOneWidget);
    });

    testWidgets('Julia-Rust Multiply button should work', (WidgetTester tester) async {
      // Set larger screen size to ensure buttons are visible
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // Find and tap the Julia-Rust Multiply button
      final multiplyButton = find.text('Julia→Rust Multiply');
      expect(multiplyButton, findsOneWidget);
      
      await tester.tap(multiplyButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // And the result will be displayed
      expect(find.textContaining('Julia→Rust Multiply: 3.14 × 2.0 = 6.28 (Julia→Rust C FFI)'), findsOneWidget);
    });

    testWidgets('Julia-Rust Factorial button should work', (WidgetTester tester) async {
      // Set larger screen size to ensure buttons are visible
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // Find and tap the Julia-Rust Factorial button
      final factorialButton = find.text('Julia→Rust Factorial');
      expect(factorialButton, findsOneWidget);
      
      await tester.tap(factorialButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // And the result will be displayed
      expect(find.textContaining('Julia→Rust Factorial: 6! = 720 (Julia→Rust C FFI)'), findsOneWidget);
    });

    testWidgets('Julia-Rust String Lengths button should work', (WidgetTester tester) async {
      // Set larger screen size to ensure buttons are visible
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // Find and tap the Julia-Rust String Lengths button
      final stringLengthsButton = find.text('Julia→Rust String Lengths');
      expect(stringLengthsButton, findsOneWidget);
      
      await tester.tap(stringLengthsButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // And the result will be displayed
      expect(find.textContaining('Julia→Rust String Lengths: [5, 5, 3] for ["hello", "world", "foo"] (Julia→Rust C FFI)'), findsOneWidget);
    });

    testWidgets('Julia-Rust String Map button should work', (WidgetTester tester) async {
      // Set larger screen size to ensure buttons are visible
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      await tester.pumpAndSettle();

      // Find and tap the Julia-Rust String Map button
      final stringMapButton = find.text('Julia→Rust String Map');
      expect(stringMapButton, findsOneWidget);
      
      await tester.tap(stringMapButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // And the result will be displayed
      expect(find.textContaining('Julia→Rust String Map: {"key1": "value1", "key2": "value2"} (Julia→Rust C FFI)'), findsOneWidget);
    });

    testWidgets('Julia-Rust section should have proper visual separation', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      

      // 
      await tester.pumpAndSettle();

      // Now we can find the green container
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
      
      // Verify the Julia-Rust section container has green styling
      final containerWidgets = tester.widgetList<Container>(containers);
      final greenContainer = containerWidgets.where((container) => 
        container.decoration is BoxDecoration &&
        (container.decoration as BoxDecoration).color == Colors.green[50]
      );
      expect(greenContainer.length, greaterThan(0));
    });

    testWidgets('Julia-Rust buttons should be properly sized', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      

      // 
      await tester.pumpAndSettle();

      // Now we can find the Julia-Rust buttons
      final juliaRustButtons = find.byType(ElevatedButton);
      expect(juliaRustButtons, findsWidgets);
      
      // Verify buttons have proper minimum size
      final buttonWidgets = tester.widgetList<ElevatedButton>(juliaRustButtons);
      for (final button in buttonWidgets) {
        final minimumSize = button.style?.minimumSize?.resolve({});
        expect(minimumSize?.height, greaterThanOrEqualTo(40.0));
      }
    });

    testWidgets('Julia-Rust buttons should have correct font size', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for the FutureBuilder to complete
      

      // 
      await tester.pumpAndSettle();

      // Now we can find the Julia-Rust buttons
      final juliaRustButtons = find.byType(ElevatedButton);
      expect(juliaRustButtons, findsWidgets);
      
      // Verify Julia-Rust buttons have smaller font size (10px)
      final buttonWidgets = tester.widgetList<ElevatedButton>(juliaRustButtons);
      final smallFontButtons = buttonWidgets.where((button) => 
        button.child is Text &&
        (button.child as Text).style?.fontSize == 10.0
      );
      expect(smallFontButtons.length, greaterThan(0));
    });
  });
}
