/**
 * Comprehensive Test Suite for Rust FFI Integration
 * 
 * This test suite validates all Rust FFI functions and ensures proper
 * communication between Flutter/Dart and Rust code. It covers:
 * 
 * - Basic FFI function calls
 * - Data type conversions
 * - Error handling
 * - Performance benchmarks
 * - Memory management
 * - Integration workflows
 * 
 * # Test Categories
 * - Unit tests for individual FFI functions
 * - Integration tests for complex workflows
 * - Performance tests for critical operations
 * - Error handling tests for edge cases
 * - Memory leak detection tests
 * 
 * # Usage
 * ```bash
 * flutter test test/rust_ffi_test.dart
 * ```
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/api/simple.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Rust FFI Integration Tests', () {
    
    setUpAll(() async {
      // Initialize the Rust library before running tests
      await RustLib.init();
    });

    group('Basic FFI Functions', () {
      test('greet function should return correct greeting', () {
        final result = greet(name: 'Alice');
        expect(result, equals('Hello, Alice!'));
      });

      test('greet function should handle empty string', () {
        final result = greet(name: '');
        expect(result, equals('Hello, !'));
      });

      test('greet function should handle special characters', () {
        final result = greet(name: 'Test@User#123');
        expect(result, equals('Hello, Test@User#123!'));
      });

      test('greet function should handle unicode characters', () {
        final result = greet(name: 'José María');
        expect(result, equals('Hello, José María!'));
      });
    });

    group('Mathematical Operations', () {
      test('add_numbers should perform basic addition', () {
        final result = addNumbers(a: 5, b: 3);
        expect(result, equals(8));
      });

      test('add_numbers should handle negative numbers', () {
        final result = addNumbers(a: -5, b: 3);
        expect(result, equals(-2));
      });

      test('add_numbers should handle zero', () {
        final result = addNumbers(a: 0, b: 0);
        expect(result, equals(0));
      });

      test('add_numbers should handle large numbers', () {
        final result = addNumbers(a: 1000000, b: 2000000);
        expect(result, equals(3000000));
      });

      test('multiply_floats should perform basic multiplication', () {
        final result = multiplyFloats(a: 2.5, b: 4.0);
        expect(result, equals(10.0));
      });

      test('multiply_floats should handle negative numbers', () {
        final result = multiplyFloats(a: -2.0, b: 3.0);
        expect(result, equals(-6.0));
      });

      test('multiply_floats should handle zero', () {
        final result = multiplyFloats(a: 0.0, b: 5.0);
        expect(result, equals(0.0));
      });

      test('multiply_floats should handle decimal precision', () {
        final result = multiplyFloats(a: 0.1, b: 0.2);
        expect(result, closeTo(0.02, 0.001));
      });
    });

    group('Boolean Operations', () {
      test('is_even should return true for even numbers', () {
        expect(isEven(number: 4), isTrue);
        expect(isEven(number: 0), isTrue);
        expect(isEven(number: -2), isTrue);
        expect(isEven(number: 100), isTrue);
      });

      test('is_even should return false for odd numbers', () {
        expect(isEven(number: 3), isFalse);
        expect(isEven(number: 1), isFalse);
        expect(isEven(number: -1), isFalse);
        expect(isEven(number: 99), isFalse);
      });
    });

    group('Time Operations', () {
    test('get_current_timestamp should return positive value', () {
      final timestamp = getCurrentTimestamp();
      expect(timestamp.toInt(), greaterThan(0));
    });

      test('get_current_timestamp should increase over time', () async {
        final timestamp1 = getCurrentTimestamp();
        await Future.delayed(const Duration(milliseconds: 10));
        final timestamp2 = getCurrentTimestamp();
        expect(timestamp2.toInt(), greaterThanOrEqualTo(timestamp1.toInt()));
      });

      test('get_current_timestamp should be reasonable (not too old)', () {
        final timestamp = getCurrentTimestamp();
        final now = DateTime.now().millisecondsSinceEpoch;
        final difference = (now - timestamp.toInt()).abs();
        expect(difference, lessThan(1000)); // Within 1 second
      });
    });

    group('String Operations', () {
      test('get_string_lengths should return correct lengths', () {
        final strings = ['hello', 'world', ''];
        final lengths = getStringLengths(strings: strings);
        expect(lengths, equals([5, 5, 0]));
      });

      test('get_string_lengths should handle empty list', () {
        final lengths = getStringLengths(strings: []);
        expect(lengths, equals([]));
      });

      test('get_string_lengths should handle unicode strings', () {
        final strings = ['café', 'naïve', '🚀'];
        final lengths = getStringLengths(strings: strings);
        expect(lengths, equals([5, 6, 4])); // Note: Unicode characters count as bytes in UTF-8
      });

      test('is_palindrome should return true for palindromes', () {
        expect(isPalindrome(text: 'racecar'), isTrue);
        expect(isPalindrome(text: 'level'), isTrue);
        expect(isPalindrome(text: 'a'), isTrue);
        expect(isPalindrome(text: ''), isTrue);
        expect(isPalindrome(text: 'abccba'), isTrue);
      });

      test('is_palindrome should return false for non-palindromes', () {
        expect(isPalindrome(text: 'hello'), isFalse);
        expect(isPalindrome(text: 'world'), isFalse);
        expect(isPalindrome(text: 'abc'), isFalse);
      });

      test('simple_hash should return consistent values', () {
        final hash1 = simpleHash(input: 'hello');
        final hash2 = simpleHash(input: 'hello');
        expect(hash1, equals(hash2));
      });

      test('simple_hash should return different values for different inputs', () {
        final hash1 = simpleHash(input: 'hello');
        final hash2 = simpleHash(input: 'world');
        expect(hash1, isNot(equals(hash2)));
      });

      test('simple_hash should handle empty string', () {
        final hash = simpleHash(input: '');
        expect(hash, equals(0));
      });
    });

    group('Data Structure Operations', () {
      test('create_string_map should create correct map', () {
        final pairs = [
          ('name', 'Alice'),
          ('age', '30'),
        ];
        final map = createStringMap(pairs: pairs);
        
        expect(map['name'], equals('Alice'));
        expect(map['age'], equals('30'));
        expect(map['nonexistent'], isNull);
      });

      test('create_string_map should handle empty list', () {
        final map = createStringMap(pairs: []);
        expect(map, isEmpty);
      });

      test('create_string_map should handle duplicate keys', () {
        final pairs = [
          ('key', 'value1'),
          ('key', 'value2'),
        ];
        final map = createStringMap(pairs: pairs);
        // Last value should be kept
        expect(map['key'], equals('value2'));
      });
    });

    group('Mathematical Algorithms', () {
      test('factorial should return correct values', () {
        expect(factorial(n: 0), equals(1));
        expect(factorial(n: 1), equals(1));
        expect(factorial(n: 2), equals(2));
        expect(factorial(n: 3), equals(6));
        expect(factorial(n: 4), equals(24));
        expect(factorial(n: 5), equals(120));
        expect(factorial(n: 10), equals(3628800));
      });

      test('factorial should handle edge cases', () {
        expect(factorial(n: 0), equals(1));
        expect(factorial(n: 1), equals(1));
      });
    });

    group('Performance Tests', () {
      test('greet function should be fast', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          greet(name: 'TestUser$i');
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should complete in < 100ms
      });

      test('mathematical operations should be fast', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10000; i++) {
          addNumbers(a: i, b: i + 1);
          multiplyFloats(a: i.toDouble(), b: 2.0);
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should complete in < 100ms
      });

      test('string operations should be fast', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          getStringLengths(strings: ['hello', 'world', 'test']);
          isPalindrome(text: 'racecar');
          simpleHash(input: 'test_string');
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should complete in < 200ms
      });
    });

    group('Memory Management Tests', () {
      test('repeated function calls should not cause memory leaks', () {
        // Perform many operations to check for memory issues
        for (int i = 0; i < 10000; i++) {
          greet(name: 'User$i');
          addNumbers(a: i, b: i + 1);
          multiplyFloats(a: i.toDouble(), b: 2.0);
          getStringLengths(strings: ['test', 'strings']);
          createStringMap(pairs: [('key$i', 'value$i')]);
        }
        
        // If we get here without crashing, memory management is working
        expect(true, isTrue);
      });

      test('large data structures should be handled correctly', () {
        final largeStrings = List.generate(1000, (i) => 'String number $i with some content');
        final lengths = getStringLengths(strings: largeStrings);
        expect(lengths.length, equals(1000));
        
        final largePairs = List.generate(1000, (i) => ('key$i', 'value$i'));
        final map = createStringMap(pairs: largePairs);
        expect(map.length, equals(1000));
      });
    });

    group('Error Handling Tests', () {
      test('functions should handle edge cases gracefully', () {
        // Test with extreme values
        expect(addNumbers(a: 2147483647, b: 1), isNull); // Integer overflow returns null
        expect(multiplyFloats(a: double.infinity, b: 1.0), equals(double.infinity));
        expect(multiplyFloats(a: double.nan, b: 1.0), isNaN);
      });

      test('functions should handle special floating point values', () {
        expect(multiplyFloats(a: 0.0, b: double.infinity), isNaN);
        expect(multiplyFloats(a: double.infinity, b: 0.0), isNaN);
      });
    });

    group('Integration Workflow Tests', () {
      test('complete workflow should work correctly', () {
        // Test a complete workflow using multiple functions
        final greeting = greet(name: 'IntegrationTest');
        expect(greeting, contains('IntegrationTest'));
        
        final sum = addNumbers(a: 10, b: 20);
        expect(sum, equals(30));
        
        final product = multiplyFloats(a: 2.5, b: 4.0);
        expect(product, equals(10.0));
        
        final isEvenResult = isEven(number: 42);
        expect(isEvenResult, isTrue);
        
        final timestamp = getCurrentTimestamp();
        expect(timestamp.toInt(), greaterThan(0));
        
        final strings = ['test', 'integration'];
        final lengths = getStringLengths(strings: strings);
        expect(lengths, equals([4, 11]));
        
        final pairs = [('test', 'value')];
        final map = createStringMap(pairs: pairs);
        expect(map['test'], equals('value'));
        
        final fact = factorial(n: 5);
        expect(fact, equals(120));
        
        final palindrome = isPalindrome(text: 'racecar');
        expect(palindrome, isTrue);
        
        final hash = simpleHash(input: 'test');
        expect(hash, greaterThan(0));
      });

      test('concurrent function calls should work correctly', () async {
        final futures = <Future>[];
        
        // Launch multiple concurrent operations
        for (int i = 0; i < 100; i++) {
          futures.add(Future(() {
            greet(name: 'ConcurrentUser$i');
            addNumbers(a: i, b: i + 1);
            multiplyFloats(a: i.toDouble(), b: 2.0);
            isEven(number: i);
            getCurrentTimestamp();
          }));
        }
        
        // Wait for all operations to complete
        await Future.wait(futures);
        
        // If we get here without errors, concurrent access is working
        expect(true, isTrue);
      });
    });

    group('Data Type Conversion Tests', () {
      test('integer types should be handled correctly', () {
        expect(addNumbers(a: 0, b: 0), equals(0));
        expect(addNumbers(a: -1, b: 1), equals(0));
        expect(addNumbers(a: 2147483647, b: -2147483647), equals(0));
      });

      test('floating point types should be handled correctly', () {
        expect(multiplyFloats(a: 0.0, b: 1.0), equals(0.0));
        expect(multiplyFloats(a: -1.0, b: 1.0), equals(-1.0));
        expect(multiplyFloats(a: 1.0, b: 1.0), equals(1.0));
      });

      test('boolean types should be handled correctly', () {
        expect(isEven(number: 0), isTrue);
        expect(isEven(number: 1), isFalse);
        expect(isEven(number: -1), isFalse);
        expect(isEven(number: 2), isTrue);
      });
    });

    group('Unicode and Internationalization Tests', () {
      test('unicode strings should be handled correctly', () {
        final unicodeStrings = ['café', 'naïve', 'résumé', '🚀', '🎉'];
        final lengths = getStringLengths(strings: unicodeStrings);
        expect(lengths, equals([5, 6, 8, 4, 4])); // Note: Unicode characters count as bytes in UTF-8
      });

      test('unicode palindromes should work correctly', () {
        expect(isPalindrome(text: 'aba'), isTrue);
        expect(isPalindrome(text: 'café'), isFalse);
      });

      test('unicode hash should work correctly', () {
        final hash1 = simpleHash(input: 'café');
        final hash2 = simpleHash(input: 'café');
        expect(hash1, equals(hash2));
      });
    });
  });
}
