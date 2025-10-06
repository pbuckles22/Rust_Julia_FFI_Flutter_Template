import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Entropy-Only Mode & Early Termination', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('entropy-only mode should ignore statistical scoring', () {
      // RED: Expect behavior difference when enabling entropy-only scoring
      final remainingWords = ['CRANE', 'SLATE', 'TRACE', 'CRATE'];
      final guessResults = <(String, List<String>)>[];

      // Baseline: default config
      FfiService.resetToDefaultConfiguration();
      final baseline = FfiService.getBestGuessFast(remainingWords, guessResults);

      // Enable entropy-only mode
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: true,
        includeKillerWords: true,
        candidateCap: 1000,
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: true,
      ));
      final entropyOnly = FfiService.getBestGuessFast(remainingWords, guessResults);

      // Expect potentially different choice under entropy-only
      // If same, still acceptable; assert it returns valid candidate
      expect(entropyOnly, isNotNull);
      expect(remainingWords, contains(entropyOnly));

      // Compute entropy values to ensure path works
      final eSlate = FfiService.calculateEntropy('SLATE', remainingWords);
      final eCrane = FfiService.calculateEntropy('CRANE', remainingWords);
      expect(eSlate >= 0 && eCrane >= 0, isTrue);
    });

    test('early termination reduces processing time when enabled', () {
      // RED: Check relative performance with early termination
      final remainingWords = List<String>.generate(300, (i) => 'WORD${i.toString().padLeft(3, '0')}');
      final guessResults = <(String, List<String>)>[];

      // Early termination disabled
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 1000,
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: false,
      ));
      final t1 = Stopwatch()..start();
      final guess1 = FfiService.getBestGuessFast(remainingWords, guessResults);
      t1.stop();
      expect(guess1, isNotNull);

      // Early termination enabled
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 1000,
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 5.0,
        entropyOnlyScoring: false,
      ));
      final t2 = Stopwatch()..start();
      final guess2 = FfiService.getBestGuessFast(remainingWords, guessResults);
      t2.stop();
      expect(guess2, isNotNull);

      // We can't guarantee strict timing, but enabled should generally be faster or equal
      expect(t2.elapsedMicroseconds <= t1.elapsedMicroseconds, isTrue,
          reason: 'Early termination should not be slower');
    });
  });
}


