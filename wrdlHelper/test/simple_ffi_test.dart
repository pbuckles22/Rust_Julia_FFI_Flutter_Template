import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Simple FFI Tests', () {
    setUpAll(() {
      // Initialize the FFI bridge
      RustLib.init();
    });

    test('should call basic greet function', () async {
      final result = RustLib.instance.api.crateApiSimpleGreet(name: 'Test');
      expect(result, equals('Hello, Test!'));
    });

    test('should call entropy function', () async {
      final entropy = RustLib.instance.api.crateApiSimpleCalculateEntropy(
        candidateWord: 'CRANE',
        remainingWords: ['CRANE', 'SLATE'],
      );
      expect(entropy, isA<double>());
      expect(entropy, greaterThanOrEqualTo(0.0));
    });

    test('should call pattern simulation function', () async {
      final pattern = RustLib.instance.api.crateApiSimpleSimulateGuessPattern(
        guess: 'CRANE',
        target: 'CRATE',
      );
      expect(pattern, equals('GGGXG'));
    });
  });
}
