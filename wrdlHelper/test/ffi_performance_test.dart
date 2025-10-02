import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('FFI Performance Tests', () {
    setUpAll(() async {
      // Initialize FFI once
      await RustLib.init();
      await FfiService.initialize();
    });

    test('optimal first guess performance', () {
      final stopwatch = Stopwatch()..start();
      
      // Test the optimal first guess call
      final result = FfiService.getOptimalFirstGuess();
      
      stopwatch.stop();
      
      print('🎯 Optimal first guess: $result');
      print('⏱️  FFI call time: ${stopwatch.elapsedMicroseconds}μs (${stopwatch.elapsedMilliseconds}ms)');
      
      expect(result, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(10)); // Should be < 10ms
    });

    test('full algorithm performance (second guess)', () {
      final stopwatch = Stopwatch()..start();
      
      // Test the full algorithm with filtered words (simulating second guess)
      final result = FfiService.getBestGuessFast(
        ['SLATE', 'CRANE', 'CRATE'], // Filtered words
        [('CRANE', ['X', 'X', 'X', 'X', 'X'])], // Previous guess result
      );
      
      stopwatch.stop();
      
      print('🧠 Full algorithm result: $result');
      print('⏱️  FFI call time: ${stopwatch.elapsedMicroseconds}μs (${stopwatch.elapsedMilliseconds}ms)');
      
      expect(result, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be < 200ms
    });

    test('performance comparison: first vs subsequent guesses', () {
      // First guess (optimized)
      final firstGuessStopwatch = Stopwatch()..start();
      final firstGuess = FfiService.getOptimalFirstGuess();
      firstGuessStopwatch.stop();
      
      // Second guess (full algorithm)
      final secondGuessStopwatch = Stopwatch()..start();
      final secondGuess = FfiService.getBestGuessFast(
        ['SLATE', 'CRANE', 'CRATE'],
        [('CRANE', ['X', 'X', 'X', 'X', 'X'])],
      );
      secondGuessStopwatch.stop();
      
      print('🎯 First guess (optimized): $firstGuess - ${firstGuessStopwatch.elapsedMicroseconds}μs');
      print('🧠 Second guess (full algo): $secondGuess - ${secondGuessStopwatch.elapsedMicroseconds}μs');
      print('📊 Performance ratio: ${secondGuessStopwatch.elapsedMicroseconds / firstGuessStopwatch.elapsedMicroseconds}x slower');
      
      expect(firstGuess, isNotNull);
      expect(secondGuess, isNotNull);
      expect(firstGuessStopwatch.elapsedMilliseconds, lessThan(10));
      expect(secondGuessStopwatch.elapsedMilliseconds, lessThan(200));
    });
  });
}
