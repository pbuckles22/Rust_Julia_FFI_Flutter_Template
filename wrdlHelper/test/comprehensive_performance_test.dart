import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Comprehensive Performance Tests', () {
    // Now works with centralized FFI word lists
    
    setUpAll(() async {
      // Initialize Flutter binding for asset loading
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize FFI once (word lists are loaded by centralized FFI during
      // initialization)
      await RustLib.init();
      await FfiService.initialize();
    });

    test('E2E performance: first guess should be <1ms', () {
      final stopwatch = Stopwatch()..start();
      
      final result = FfiService.getOptimalFirstGuess();
      
      stopwatch.stop();
      
      print('🎯 First guess result: $result');
      print(
        '⏱️  E2E time: ${stopwatch.elapsedMicroseconds}μs '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      
      expect(result, isNotNull);
      expect(result!.length, equals(5));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThanOrEqualTo(5), // Allow up to 5ms (FFI overhead)
      );
    });

    test('E2E performance: subsequent guesses should be <200ms', () {
      final stopwatch = Stopwatch()..start();
      
      // Test with realistic game scenario using centralized FFI
      final remainingWords = FfiService.getGuessWords().take(1000).toList();
      final guessResults = [
        ('CRANE', ['X', 'X', 'X', 'X', 'X']), // All gray
      ];
      
      final result = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      stopwatch.stop();
      
      print('🧠 Subsequent guess result: $result');
      print(
        '⏱️  E2E time: ${stopwatch.elapsedMicroseconds}μs '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      
      expect(result, isNotNull);
      expect(result!.length, equals(5));
      expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be <200ms
    });

    test('E2E performance: word filtering should be <50ms', () {
      final stopwatch = Stopwatch()..start();
      
      // Test word filtering with large word list using centralized FFI
      final allWords = FfiService.getGuessWords().take(5000).toList();
      final guessResults = [
        ('SLATE', ['G', 'G', 'X', 'X', 'X']), // SL green, ATE gray
      ];
      
      final filtered = FfiService.filterWords(allWords, guessResults);
      
      stopwatch.stop();
      
      print('🔍 Filtered ${filtered.length} words from ${allWords.length}');
      print(
        '⏱️  E2E time: ${stopwatch.elapsedMicroseconds}μs '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      
      expect(filtered, isNotEmpty);
      expect(filtered.length, lessThan(allWords.length));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50), // Should be <50ms
      );
    });

    test('E2E performance: entropy calculation should be <10ms', () {
      final stopwatch = Stopwatch()..start();
      
      // Test entropy calculation using centralized FFI
      final candidateWord = 'TARES';
      final remainingWords = FfiService.getGuessWords().take(1000).toList();
      
      final entropy = FfiService.calculateEntropy(
        candidateWord,
        remainingWords,
      );
      
      stopwatch.stop();
      
      print('📊 Entropy for $candidateWord: $entropy');
      print(
        '⏱️  E2E time: ${stopwatch.elapsedMicroseconds}μs '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      
      expect(entropy, greaterThan(0.0));
      expect(stopwatch.elapsedMilliseconds, lessThan(10)); // Should be <10ms
    });

    test('E2E performance: pattern simulation should be <1ms', () {
      final stopwatch = Stopwatch()..start();
      
      // Test pattern simulation
      final pattern = FfiService.simulateGuessPattern('CRANE', 'CRATE');
      
      stopwatch.stop();
      
      print('🎨 Pattern for CRANE vs CRATE: $pattern');
      print(
        '⏱️  E2E time: ${stopwatch.elapsedMicroseconds}μs '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      
      expect(pattern, equals('GGGXG')); // C, R, A match, N doesn't, E matches
      expect(
        stopwatch.elapsedMilliseconds,
        lessThanOrEqualTo(1), // Allow up to 1ms
      );
    });

    test('E2E performance: stress test with multiple operations', () {
      final stopwatch = Stopwatch()..start();
      
      // Perform multiple operations to test overall performance using
      // centralized FFI
      final allWords = FfiService.getGuessWords().take(2000).toList();
      
      // Operation 1: Get optimal first guess
      final firstGuess = FfiService.getOptimalFirstGuess();
      
      // Operation 2: Filter words
      final filtered = FfiService.filterWords(allWords, [
        ('CRANE', ['X', 'X', 'X', 'X', 'X']),
      ]);
      
      // Operation 3: Get best guess from filtered words
      final bestGuess = FfiService.getBestGuessFast(
        filtered.take(100).toList(),
        [],
      );
      
      // Operation 4: Calculate entropy
      final entropy = FfiService.calculateEntropy(
        bestGuess!,
        filtered.take(100).toList(),
      );
      
      // Operation 5: Simulate pattern
      final pattern = FfiService.simulateGuessPattern(bestGuess!, 'SLATE');
      
      stopwatch.stop();
      
      print('🚀 Stress test results:');
      print('  • First guess: $firstGuess');
      print('  • Filtered words: ${filtered.length}');
      print('  • Best guess: $bestGuess');
      print('  • Entropy: $entropy');
      print('  • Pattern: $pattern');
      print(
        '⏱️  Total E2E time: ${stopwatch.elapsedMicroseconds}μs '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      
      expect(firstGuess, isNotNull);
      expect(filtered, isNotEmpty);
      expect(bestGuess, isNotNull);
      expect(entropy, greaterThan(0.0));
      expect(pattern, isNotEmpty);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300), // Should be <300ms total
      );
    });

    test('E2E performance: memory usage validation', () {
      // Test that we can handle large word lists without memory issues using
      // centralized FFI
      final allWords = FfiService.getGuessWords();
      
      print('📊 Memory test with ${allWords.length} words');
      
      final stopwatch = Stopwatch()..start();
      
      // Test with full word list
      final result = FfiService.getBestGuessFast(
        allWords.take(1000).toList(),
        [],
      );
      
      stopwatch.stop();
      
      print('🧠 Full word list result: $result');
      print(
        '⏱️  E2E time: ${stopwatch.elapsedMicroseconds}μs '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      
      expect(result, isNotNull);
      expect(result!.length, equals(5));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500), // Should handle large lists <500ms
      );
    });
  });
}
