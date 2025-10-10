import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('FFI Service Guess Functions Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('getIntelligentGuessFast() should return valid suggestions', () {
      // RED: This test will verify the fast guess function works
      
      // Test with no previous guesses (first guess)
      final remainingWords = FfiService.getAnswerWords().take(100).toList();
      final guessResults = <(String, List<String>)>[];
      
      final suggestion = FfiService.getBestGuessFast(
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

    test('getIntelligentGuessFast() should handle game progression', () {
      // RED: This test will verify the function works with game state
      
      // Simulate a game where we've made some guesses
      final remainingWords = ['CRANE', 'SLATE', 'CRATE', 'PLATE', 'GRATE'];
      final guessResults = <(String, List<String>)>[
        ('HELLO', ['X', 'X', 'X', 'X', 'X']), // All gray
        ('WORLD', ['X', 'X', 'X', 'X', 'X']), // All gray
      ];
      
      final suggestion = FfiService.getBestGuessFast(
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
    });

    test('getIntelligentGuessFast() should handle edge cases', () {
      // RED: This test will verify edge case handling
      
      // Test with very few remaining words
      final fewWords = ['CRANE', 'SLATE'];
      final guessResults = <(String, List<String>)>[];
      
      final suggestion = FfiService.getBestGuessFast(fewWords, guessResults);
      
      // Should still return a valid suggestion
      expect(suggestion, isNotNull);
      expect(suggestion, isA<String>());
      expect(suggestion!.length, equals(5));
      expect(FfiService.isValidWord(suggestion), isTrue);
      
      // Test with many guess results
      final manyResults = List.generate(
        5,
        (i) => ('GUESS${i}', ['X', 'X', 'X', 'X', 'X']),
      );
      final suggestion2 = FfiService.getBestGuessFast(
        fewWords,
        manyResults,
      );
      
      expect(suggestion2, isNotNull);
      expect(suggestion2!.length, equals(5));
      expect(FfiService.isValidWord(suggestion2), isTrue);
    });

    test('getOptimalFirstGuess() should return optimal first guess', () {
      // RED: This test will verify the optimal first guess function
      
      final optimalGuess = FfiService.getOptimalFirstGuess();
      
      // Should return a valid suggestion
      expect(optimalGuess, isNotNull);
      expect(optimalGuess, isA<String>());
      expect(optimalGuess!.length, equals(5));
      expect(optimalGuess, matches(RegExp(r'^[A-Z]{5}$')));
      
      // Should be a valid word
      expect(FfiService.isValidWord(optimalGuess), isTrue);
      
      // Should be one of the known optimal first guesses
      final knownOptimalGuesses = ['TARES', 'SLATE', 'CRANE', 'CRATE', 'SLANT'];
      expect(
        knownOptimalGuesses.contains(optimalGuess),
        isTrue,
        reason: 'Should be one of the known optimal first guesses: '
            '$knownOptimalGuesses',
      );
    });
  });
}
