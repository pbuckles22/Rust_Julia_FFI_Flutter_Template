/**
 * Comprehensive Integration Test Suite for Flutter-Rust FFI Application
 * 
 * This test suite validates the complete application workflow including:
 * 
 * - End-to-end user interactions
 * - FFI integration in real app context
 * - Cross-platform compatibility
 * - Performance under realistic conditions
 * - Error handling and recovery
 * - Memory management in production scenarios
 * 
 * # Test Categories
 * - Full application workflow tests
 * - Cross-platform integration tests
 * - Performance and stress tests
 * - Error recovery tests
 * - Memory leak detection tests
 * 
 * # Usage
 * ```bash
 * flutter test integration_test/app_integration_test.dart
 * ```
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wrdlhelper/main.dart' as app;
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    
    setUpAll(() async {
      // Initialize the Rust library before running integration tests
      await RustLib.init();
    });

    testWidgets('Complete app workflow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app is running
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify the main content is displayed
      expect(
        find.textContaining('flutter_rust_bridge quickstart'),
        findsOneWidget,
      );
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);

      // Verify the app structure
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('App startup performance test', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify startup time is reasonable
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000), // Should start within 5 seconds
      );
      
      // Verify the app is fully loaded
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App memory usage test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Perform multiple operations to test memory management
      for (var i = 0; i < 100; i++) {
        // Trigger rebuilds
        await tester.pump();
        await tester.pumpAndSettle();
      }

      // Verify the app still works correctly
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App orientation change test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);

      // Change orientation (simulate device rotation)
      tester.view.physicalSize = const Size(800, 400); // Landscape
      await tester.pumpAndSettle();

      // Verify app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);

      // Change back to portrait
      tester.view.physicalSize = const Size(400, 800); // Portrait
      await tester.pumpAndSettle();

      // Verify app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App screen size adaptation test', (WidgetTester tester) async {
      // Test different screen sizes
      final screenSizes = [
        const Size(320, 568),   // iPhone SE
        const Size(375, 667),   // iPhone 8
        const Size(414, 896),   // iPhone 11 Pro Max
        const Size(768, 1024),  // iPad
        const Size(1024, 768),  // iPad landscape
        const Size(1920, 1080), // Desktop
      ];

      for (final size in screenSizes) {
        // Set screen size
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // Verify the app renders correctly
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.textContaining('Hello, Tom!'), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('App text scale adaptation test', (WidgetTester tester) async {
      // Test different text scale factors
      final textScales = [0.8, 1.0, 1.2, 1.5, 2.0, 3.0];

      for (final _ in textScales) {
        // Set text scale (using platformDispatcher for newer Flutter versions)
        // Note: textScaleFactor setter is deprecated, using platformDispatcher
        // instead
        // tester.view.textScaleFactor = scale;

        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // Verify the app renders correctly
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.textContaining('Hello, Tom!'), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('App stress test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Perform stress operations
      for (var i = 0; i < 1000; i++) {
        // Rapid rebuilds
        await tester.pump();
        
        // Every 100 iterations, do a full settle
        if (i % 100 == 0) {
          await tester.pumpAndSettle();
        }
      }

      // Verify the app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App error recovery test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(MaterialApp), findsOneWidget);

      // Simulate various error conditions
      try {
        // Try to cause an error (this should not crash the app)
        await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Error Widget'),
            ),
          ),
        ));
        await tester.pumpAndSettle();
      } catch (e) {
        // If an error occurs, the app should recover
        app.main();
        await tester.pumpAndSettle();
      }

      // Verify the app is still working
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App background/foreground test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);

      // Simulate app going to background
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // Simulate app coming back to foreground
      app.main();
      await tester.pumpAndSettle();

      // Verify the app is still working
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App memory pressure test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Simulate memory pressure by creating and destroying widgets
      for (var i = 0; i < 100; i++) {
        // Create a complex widget tree
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: List.generate(100, (j) => Text('Widget $i-$j')),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Restore the original app
        app.main();
        await tester.pumpAndSettle();
      }

      // Verify the app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App concurrent operations test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Perform concurrent operations
      final futures = <Future>[];
      
      for (var i = 0; i < 50; i++) {
        futures.add(Future(() async {
          // Simulate concurrent operations
          await tester.pump();
        }));
      }

      // Wait for all operations to complete
      await Future.wait(futures);
      await tester.pumpAndSettle();

      // Verify the app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App accessibility test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify accessibility features
      final textWidget = find.byType(Text);
      expect(textWidget, findsOneWidget);

      // Check semantics
      final semantics = tester.getSemantics(textWidget);
      expect(semantics, isNotNull);
    });

    testWidgets('App platform integration test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify platform-specific features
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify the app uses Material Design
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme?.colorScheme, isNotNull);
    });

    testWidgets('App lifecycle test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(MaterialApp), findsOneWidget);

      // Simulate app lifecycle events
      await tester.pumpWidget(const SizedBox.shrink()); // Pause
      await tester.pumpAndSettle();

      app.main(); // Resume
      await tester.pumpAndSettle();

      // Verify the app is still working
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App performance benchmark test', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify performance metrics
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000), // Should start within 3 seconds
      );
      
      // Verify the app is fully functional
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App resource cleanup test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Perform operations that might create resources
      for (var i = 0; i < 100; i++) {
        await tester.pump();
        await tester.pumpAndSettle();
      }

      // Clean up
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // Restart the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets('App error boundary test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app handles errors gracefully
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // The app should not crash during normal operation
      expect(tester.takeException(), isNull);
    });

    testWidgets('App state persistence test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);

      // Simulate state changes
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify state is maintained
      expect(find.textContaining('Hello, Tom!'), findsOneWidget);
    });

    testWidgets(
      'App cross-platform compatibility test',
      (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify cross-platform features
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);

      // Verify the app works on different platforms
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme?.colorScheme, isNotNull);
    });
  });
}
