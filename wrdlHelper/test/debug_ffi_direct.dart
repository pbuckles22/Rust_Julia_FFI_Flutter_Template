import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/src/rust/api/simple.dart' as ffi;
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Debug Direct FFI Tests', () {
    setUpAll(() async {
      // Initialize FFI
      try {
        await RustLib.init();
        DebugLogger.info('✅ FFI initialized successfully', tag: 'Debug');
      } catch (e) {
        DebugLogger.error('❌ FFI initialization failed: $e', tag: 'Debug');
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
      DebugLogger.info('✅ getIntelligentGuess returned: $result', tag: 'Debug');
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
      DebugLogger.info('✅ getIntelligentGuess with guess returned: $result', tag: 'Debug');
    });
  });
}
