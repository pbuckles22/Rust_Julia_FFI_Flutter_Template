import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('Ultra Simple Tests', () {
    setUpAll(() async {
      await FfiService.initialize();
    });

    test('test word filtering with all green', () async {
      final words = ['CRANE', 'SLATE'];
      final guessResults = [
        ('CRANE', ['G', 'G', 'G', 'G', 'G']), // All green
      ];
      
      final filtered = FfiService.filterWords(
        words,
        guessResults,
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
      
      final filtered = FfiService.filterWords(
        words,
        guessResults,
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
