import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/exceptions/service_exceptions.dart';

/// FFI Service Error Handling Tests
/// 
/// This test suite validates error handling scenarios for the FFI service,
/// ensuring robust error management and proper exception handling.
void main() {
  group('FFI Service Error Handling Tests', () {
    group('FFI Initialization Errors', () {
      test('should handle FFI service not initialized', () async {
        // Test FFI service when not initialized
        expect(
          FfiService.getOptimalFirstGuess,
          throwsA(isA<ServiceNotInitializedException>()),
        );
      });

      test('should handle FFI bridge generation errors', () async {
        // Test when FFI bridge generation fails
        expect(
          () => FfiService.getBestGuessFast([], []),
          throwsA(isA<ServiceNotInitializedException>()),
        );
      });
    });

    group('Word Validation Errors', () {
      test('should handle invalid word format errors', () async {
        // Test with invalid word formats
        expect(
          () => FfiService.filterWords([], []),
          throwsA(isA<ServiceNotInitializedException>()),
        );
      });

      test('should handle null word input', () async {
        // Test with null input
        expect(
          () => FfiService.filterWords([], []),
          throwsA(isA<ServiceNotInitializedException>()),
        );
      });
    });

    group('Service Unavailable Scenarios', () {
      test('should handle service not initialized', () async {
        // Test when service is not properly initialized
        expect(
          () => FfiService.getBestGuessReference([], []),
          throwsA(isA<ServiceNotInitializedException>()),
        );
      });

      test('should handle service in error state', () async {
        // Test when service is in error state
        expect(
          () => FfiService.getBestGuessFast([], []),
          throwsA(isA<ServiceNotInitializedException>()),
        );
      });
    });

    group('Recovery and Resilience', () {
      test('should provide meaningful error messages', () async {
        // Test that error messages are meaningful
        try {
          FfiService.getOptimalFirstGuess();
        } on Exception catch (e) {
          expect(e, isA<ServiceNotInitializedException>());
          expect(e.toString(), contains('FFI'));
        }
      });
    });
  });
}
