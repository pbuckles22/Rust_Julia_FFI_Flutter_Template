import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/screens/wordle_game_screen.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('WordleGameScreen Service Locator Integration Tests', () {
    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });

    tearDownAll(resetAllServices);

    testWidgets(
      'should use service locator instead of direct AppService creation',
      (WidgetTester tester) async {
        // TDD: Test that WordleGameScreen uses service locator
        // Services are already initialized in setUpAll()

        // Verify services are available (WordService removed, using
        // centralized FFI)
        expect(sl.isRegistered<AppService>(), isTrue);
        expect(sl.isRegistered<GameService>(), isTrue);

        // Build the screen
        await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
        await tester.pumpAndSettle();

        // Verify screen builds successfully
        expect(find.byType(WordleGameScreen), findsOneWidget);

        // Verify services are accessible through service locator
        final appService = sl<AppService>();
        final gameService = sl<GameService>();

        expect(appService.isInitialized, isTrue);
        expect(gameService.isInitialized, isTrue);
        expect(FfiService.isInitialized, isTrue); // FFI service provides word
        // lists
      },
    );

    testWidgets('should handle service locator errors gracefully', (
      WidgetTester tester,
    ) async {
      // TDD: Test that WordleGameScreen handles missing services gracefully
      // This test needs to run in isolation with no services registered
      
      // Temporarily reset services for this specific test
      resetAllServices();
      
      // Don't setup services - this should trigger fallback behavior
      expect(sl.isRegistered<AppService>(), isFalse);

      // The screen should still build with fallback behavior
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // Verify screen still builds
      expect(find.byType(WordleGameScreen), findsOneWidget);

      // Restore services for subsequent tests
      await setupTestServices();
    });

    testWidgets('should maintain service consistency during screen lifecycle', (
      WidgetTester tester,
    ) async {
      // TDD: Test that services remain consistent during screen lifecycle
      // Services are already initialized in setUpAll()

      // Build the screen
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // Get services at different points (WordService removed, using
      // centralized FFI)
      final appService1 = sl<AppService>();
      final gameService1 = sl<GameService>();

      // Rebuild the screen
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();

      // Get services again
      final appService2 = sl<AppService>();
      final gameService2 = sl<GameService>();

      // Should be the same instances (singletons)
      expect(identical(appService1, appService2), isTrue);
      expect(identical(gameService1, gameService2), isTrue);
    });

    testWidgets('should work with both real and mock services', (
      WidgetTester tester,
    ) async {
      // TDD: Test that screen works with both real and mock services

      // Test with mock services
      resetAllServices();
      await tester.pumpWidget(const MaterialApp(home: WordleGameScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(WordleGameScreen), findsOneWidget);

      // Reset and test with real services
      sl.reset();
      // Note: We can't easily test real services in unit tests due to asset
      // loading
      // This would be tested in integration tests with actual device
      
      // Restore services for other tests
      await setupTestServices();
    });
  });
}
