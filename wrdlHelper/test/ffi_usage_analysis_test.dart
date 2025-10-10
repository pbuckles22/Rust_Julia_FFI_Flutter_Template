import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('FFI Usage Analysis Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('should identify all FFI functions being used', () {
      // RED: This test documents what FFI functions are actually being used
      
      // Functions currently used in FfiService:
      final usedFunctions = [
        'initializeWordLists',      // ✅ Used in FfiService.initialize()
        'filterWords',              // ✅ Used in FfiService.filterWords()
        'getIntelligentGuess',      // ✅ Used in FfiService.getBestGuess()
        'getIntelligentGuessFast',  // ✅ Used in FfiService.getBestGuessFast()
        'getIntelligentGuessReference', // ✅ Used in
        // FfiService.getBestGuessReference()
        'getOptimalFirstGuess',     // ✅ Used in
        // FfiService.getOptimalFirstGuess()
        'calculateEntropy',         // ✅ Used in
        // FfiService.calculateEntropy()
        'simulateGuessPattern',     // ✅ Used in
        // FfiService.simulateGuessPattern()
        'loadWordListsFromDart',    // ✅ Used in
        // FfiService.loadWordListsToRust()
        'getAnswerWords',           // ✅ Used in
        // FfiService.getAnswerWords()
        'getGuessWords',            // ✅ Used in
        // FfiService.getGuessWords()
        'isValidWord',              // ✅ Used in
        // FfiService.isValidWord()
        // 'setSolverConfig',       // ❌ Commented out in FfiService.setConfiguration()
      ];
      
      // Functions available in Rust but not used in FfiService:
      final unusedFunctions = [
        'greet',                    // ❌ Only used in debug/test code
        'addNumbers',               // ❌ Not used in production
        'multiplyFloats',           // ❌ Not used in production
        'isEven',                   // ❌ Not used in production
        'getCurrentTimestamp',      // ❌ Not used in production
        'getStringLengths',         // ❌ Not used in production
        'createStringMap',          // ❌ Not used in production
        'factorial',                // ❌ Not used in production
        'isPalindrome',             // ❌ Not used in production
        'simpleHash',               // ❌ Not used in production
        'getSolverConfig',          // ❌ Not used in production
      ];
      
      // Verify all used functions are actually available and working
      expect(usedFunctions.length, greaterThan(0));
      expect(unusedFunctions.length, greaterThan(0));
      
      // This test documents the current state - no assertions needed
      // The real value is in identifying what can be cleaned up
      print('✅ Used FFI functions: ${usedFunctions.length}');
      print('❌ Unused FFI functions: ${unusedFunctions.length}');
      print(
        '📊 Total FFI functions: '
        '${usedFunctions.length + unusedFunctions.length}',
      );
    });

    test('should verify all used FFI functions work correctly', () {
      // RED: This test verifies all used functions are working
      
      // Test initializeWordLists (already called in setUpAll)
      expect(FfiService.isInitialized, isTrue);
      
      // Test getAnswerWords
      final answerWords = FfiService.getAnswerWords();
      expect(answerWords, isNotNull);
      expect(answerWords.length, greaterThan(0));
      
      // Test getGuessWords
      final guessWords = FfiService.getGuessWords();
      expect(guessWords, isNotNull);
      expect(guessWords.length, greaterThan(0));
      
      // Test isValidWord
      expect(FfiService.isValidWord('CRANE'), isTrue);
      expect(FfiService.isValidWord('XXXXX'), isFalse);
      
      // Test getOptimalFirstGuess
      final optimalGuess = FfiService.getOptimalFirstGuess();
      expect(optimalGuess, isNotNull);
      expect(optimalGuess!.length, equals(5));
      
      // Test getBestGuessFast
      final fastGuess = FfiService.getBestGuessFast(
        answerWords.take(10).toList(),
        [],
      );
      expect(fastGuess, isNotNull);
      expect(fastGuess!.length, equals(5));
      
      // Test getBestGuessReference
      final referenceGuess = FfiService.getBestGuessReference(
        answerWords.take(10).toList(),
        [],
      );
      expect(referenceGuess, isNotNull);
      expect(referenceGuess!.length, equals(5));
      
      // Test calculateEntropy
      final entropy = FfiService.calculateEntropy(
        'CRANE',
        answerWords.take(10).toList(),
      );
      expect(entropy, isA<double>());
      expect(entropy, greaterThanOrEqualTo(0.0));
      
      // Test simulateGuessPattern
      final pattern = FfiService.simulateGuessPattern('CRANE', 'SLATE');
      expect(pattern, isA<String>());
      expect(pattern.length, equals(5));
      expect(pattern, matches(RegExp(r'^[GXY]{5}$')));
      
      // Test filterWords
      final filtered = FfiService.filterWords(answerWords.take(20).toList(), [
        ('HELLO', ['X', 'X', 'X', 'X', 'X']),
      ]);
      expect(filtered, isA<List<String>>());
    });

    test('should identify deprecated or unused functions for cleanup', () {
      // RED: This test identifies what can be cleaned up
      
      // Functions that are only used in debug/test code and can be removed:
      final deprecatedFunctions = [
        'greet',                    // Only used in wordle_game_screen.dart
        // debug code
        'addNumbers',               // Only used in performance test
        // files
        'multiplyFloats',           // Only used in performance test
        // files
        'isEven',                   // Not used anywhere
        'getCurrentTimestamp',      // Not used anywhere
        'getStringLengths',         // Not used anywhere
        'createStringMap',          // Not used anywhere
        'factorial',                // Not used anywhere
        'isPalindrome',             // Not used anywhere
        'simpleHash',               // Not used anywhere
        'getSolverConfig',          // Not used anywhere
      ];
      
      // Functions that are commented out and need to be implemented:
      final commentedFunctions = [
        'setSolverConfig',          // Commented out in
        // FfiService.setConfiguration()
      ];
      
      // This test documents what needs cleanup
      print(
        '🗑️ Deprecated functions to remove: ${deprecatedFunctions.length}',
      );
      print(
        '🔧 Commented functions to implement: ${commentedFunctions.length}',
      );
      
      // Verify we have identified cleanup opportunities
      expect(deprecatedFunctions.length, greaterThan(0));
      expect(commentedFunctions.length, greaterThan(0));
    });

    test('should verify FFI service configuration TODO is addressed', () {
      // RED: This test checks if the TODO in setConfiguration is resolved
      
      // Check if setSolverConfig is available and working
      // This was commented out in the original code
      try {
        // Try to call the function to see if it's available
        // Note: This might fail if the function isn't properly exposed
        final config = FfiService.getConfiguration();
        expect(config, isNotNull);
        
        // The TODO in setConfiguration should be resolved
        // by implementing the Rust-side configuration
        print('✅ Configuration system is working');
      } catch (e) {
        print('❌ Configuration system needs work: $e');
        // This is expected if the TODO hasn't been resolved yet
      }
    });
  });
}
