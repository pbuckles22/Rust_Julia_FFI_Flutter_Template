import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('FFI Service Reference Mode Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('getBestGuessReference() should return valid suggestions', () {
      // RED: This test will verify the reference mode guess function works
      
      // Test with no previous guesses (first guess)
      final remainingWords = FfiService.getAnswerWords().take(100).toList();
      final guessResults = <(String, List<String>)>[];
      
      final suggestion = FfiService.getBestGuessReference(
        remainingWords,
        guessResults,
      );
      
      // Should return a valid suggestion
      expect(suggestion, isNotNull);
      expect(suggestion, isA<String>());
      expect(suggestion!.length, equals(5));
      expect(suggestion, matches(RegExp(r'^[A-Z]{5}$')));
      
      // Should be a valid word
      expect(FfiService.isValidWord(suggestion), isTrue);
    });

    test('getBestGuessReference() should handle complex game states', () {
      // RED: This test will verify the function works with complex game progression
      
      // Simulate a complex game state with multiple guesses and patterns
      final remainingWords = [
        'CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE', 'TRACE', 'CHASE'
      ];
      final guessResults = <(String, List<String>)>[
        ('HELLO', ['X', 'X', 'X', 'X', 'X']), // All gray
        ('WORLD', ['X', 'X', 'X', 'X', 'X']), // All gray
        ('STARE', ['Y', 'X', 'X', 'X', 'X']), // S yellow, rest gray
      ];
      
      final suggestion = FfiService.getBestGuessReference(
        remainingWords,
        guessResults,
      );
      
      // Should return a valid suggestion
      expect(suggestion, isNotNull);
      expect(suggestion, isA<String>());
      expect(suggestion!.length, equals(5));
      expect(suggestion, matches(RegExp(r'^[A-Z]{5}$')));
      
      // Should be a valid word
      expect(FfiService.isValidWord(suggestion), isTrue);
      
      // Should be different from our previous guesses
      expect(suggestion, isNot(equals('HELLO')));
      expect(suggestion, isNot(equals('WORLD')));
      expect(suggestion, isNot(equals('STARE')));
    });

    test('getBestGuessReference() should handle endgame scenarios', () {
      // RED: This test will verify endgame handling
      
      // Test with very few remaining words (endgame)
      final endgameWords = ['CRANE', 'SLATE'];
      final guessResults = <(String, List<String>)>[
        ('HELLO', ['X', 'X', 'X', 'X', 'X']),
        ('WORLD', ['X', 'X', 'X', 'X', 'X']),
        ('STARE', ['Y', 'X', 'X', 'X', 'X']),
        ('CRATE', ['G', 'X', 'X', 'X', 'X']), // C green
      ];
      
      final suggestion = FfiService.getBestGuessReference(
        endgameWords,
        guessResults,
      );
      
      // Should return a valid suggestion
      expect(suggestion, isNotNull);
      expect(suggestion, isA<String>());
      expect(suggestion!.length, equals(5));
      expect(FfiService.isValidWord(suggestion), isTrue);
      
      // In endgame, should prefer words that could be the answer
      expect(endgameWords.contains(suggestion), isTrue,
             reason: 'In endgame, should prefer remaining answer words');
    });

    test('getBestGuessReference() should be consistent with fast mode', () {
      // RED: This test will verify consistency between reference and fast modes
      
      final remainingWords = FfiService.getAnswerWords().take(50).toList();
      final guessResults = <(String, List<String>)>[
        ('HELLO', ['X', 'X', 'X', 'X', 'X']),
        ('WORLD', ['X', 'X', 'X', 'X', 'X']),
      ];
      
      final referenceSuggestion = FfiService.getBestGuessReference(
        remainingWords,
        guessResults,
      );
      final fastSuggestion = FfiService.getBestGuessFast(
        remainingWords,
        guessResults,
      );
      
      // Both should return valid suggestions
      expect(referenceSuggestion, isNotNull);
      expect(fastSuggestion, isNotNull);
      
      // Both should be valid words
      expect(FfiService.isValidWord(referenceSuggestion!), isTrue);
      expect(FfiService.isValidWord(fastSuggestion!), isTrue);
      
      // Both should be 5-letter words
      expect(referenceSuggestion!.length, equals(5));
      expect(fastSuggestion!.length, equals(5));
      
      // Note: They might be different suggestions, which is expected
      // The reference mode uses the 99.8% success rate algorithm
      // The fast mode uses optimized algorithms for speed
    });

    test(
      'getBestGuessReference() should handle empty remaining words gracefully',
      () {
      // RED: This test will verify edge case handling
      
      final emptyWords = <String>[];
      final guessResults = <(String, List<String>)>[];
      
      final suggestion = FfiService.getBestGuessReference(
        emptyWords,
        guessResults,
      );
      
      // Should handle gracefully - might return null or a default suggestion
      if (suggestion != null) {
        expect(suggestion, isA<String>());
        expect(suggestion.length, equals(5));
        expect(FfiService.isValidWord(suggestion), isTrue);
      }
      // If null, that's also acceptable for empty word lists
    });
  });
}
