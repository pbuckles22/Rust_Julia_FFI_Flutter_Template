import 'package:flutter_test/flutter_test.dart';
import 'package:my_working_ffi_app/src/rust/frb_generated.dart';

void main() {
  group('Ultra Simple Tests', () {
    setUpAll(() {
      RustLib.init();
    });

    test('test word filtering with all green', () async {
      final words = ['CRANE', 'SLATE'];
      final guessResults = [
        ('CRANE', ['G', 'G', 'G', 'G', 'G']), // All green
      ];
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: guessResults,
      );
      
      print('Words: $words');
      print('Pattern: GGGGG');
      print('Filtered: $filtered');
      
      expect(filtered, equals(['CRANE']));
    });

    test('test word filtering with one green', () async {
      final words = ['CRANE', 'SLATE'];
      final guessResults = [
        ('CRANE', ['G', 'X', 'X', 'X', 'X']), // Only first letter green
      ];
      
      final filtered = RustLib.instance.api.crateApiSimpleFilterWords(
        words: words,
        guessResults: guessResults,
      );
      
      print('Words: $words');
      print('Pattern: GXXXX');
      print('Filtered: $filtered');
      
      // This should return empty because SLATE doesn't have C in position 1
      // and CRANE has R, A, N, E which are gray
      expect(filtered, isEmpty);
    });
  });
}
