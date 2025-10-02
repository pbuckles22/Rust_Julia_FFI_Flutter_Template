import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/main.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/services/app_service.dart';

void main() {
  group('Main Service Locator Integration Tests', () {
    setUp(() {
      // Reset service locator before each test
      sl.reset();
    });

    tearDown(() {
      // Clean up after each test
      sl.reset();
    });

    testWidgets('should initialize services through service locator', (
      WidgetTester tester,
    ) async {
      // TDD: Test that main.dart uses service locator instead of direct AppService creation

      // This test will fail initially because main.dart doesn't use service locator yet
      // We'll implement the service locator integration to make this pass

      // Setup real services for testing
      await setupServices();

      // Verify services are available before app starts
      expect(sl.isRegistered<AppService>(), isTrue);
      final appService = sl<AppService>();
      expect(appService.isInitialized, isTrue);

      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify app builds successfully with service locator
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('should handle service initialization errors gracefully', () async {
      // TDD: Test that main.dart handles service initialization errors

      // This test verifies that if service locator setup fails,
      // the app still starts with fallback behavior

      // Don't setup services - this should trigger fallback behavior
      expect(sl.isRegistered<AppService>(), isFalse);

      // The app should still be able to start
      // (This will be implemented in the service locator integration)
    });

    test(
      'should provide consistent service access across app lifecycle',
      () async {
        // TDD: Test that services remain consistent throughout app lifecycle

        await setupServices();

        // Get services at different points
        final appService1 = sl<AppService>();
        final appService2 = sl<AppService>();

        // Should be the same instance
        expect(identical(appService1, appService2), isTrue);
        expect(appService1.isInitialized, isTrue);
        expect(appService2.isInitialized, isTrue);
      },
    );
  });
}
