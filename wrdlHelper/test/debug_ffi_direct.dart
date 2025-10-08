import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/src/rust/api/simple.dart' as ffi;

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Debug Direct FFI Tests', () {
    setUpAll(() async {
      // Initialize FFI
      try {
        await RustLib.init();
        print('✅ FFI initialized successfully');
      } catch (e) {
        print('❌ FFI initialization failed: $e');
        rethrow;
      }
    });

    test('should call getAnswerWords function', () {
      final result = ffi.getAnswerWords();
      expect(result, isA<List<String>>());
      expect(result.length, greaterThan(0));
    });

    test('should call getIntelligentGuess with minimal data', () {
      // Test with minimal data to see if it hangs
      final result = ffi.getIntelligentGuess(
        allWords: ["CRANE", "SLATE", "CRATE"],
        remainingWords: ["CRANE", "SLATE", "CRATE"],
        guessResults: [],
      );
      
      // If we get here, it didn't hang
      expect(result, isNotNull);
      print('✅ getIntelligentGuess returned: $result');
    });

    test('should call getIntelligentGuess with one guess', () {
      // Test with one guess to see if it hangs
      final result = ffi.getIntelligentGuess(
        allWords: ["CRANE", "SLATE", "CRATE", "PLATE", "GRATE"],
        remainingWords: ["SLATE", "CRATE", "PLATE", "GRATE"],
        guessResults: [("CRANE", ["X", "X", "X", "X", "X"])],
      );
      
      // If we get here, it didn't hang
      expect(result, isNotNull);
      print('✅ getIntelligentGuess with guess returned: $result');
    });
  });
}
