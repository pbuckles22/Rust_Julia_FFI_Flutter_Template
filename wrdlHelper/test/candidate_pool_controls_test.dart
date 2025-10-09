import 'package:flutter_test/flutter_test.dart';

import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Candidate Pool Controls Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('should respect candidate cap configuration', () {
      // RED: This test will fail until we implement configurable candidate caps
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 50, // Small cap
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 5.0,
        entropyOnlyScoring: false,
      ));

      // Use a large set of remaining words to test candidate cap
      final remainingWords = List.generate(100, (i) => 'WORD$i');
      final guessResults = <(String, List<String>)>[];
      
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      // Should still work with small candidate cap
      expect(bestGuess, isNotNull);
      
      // TODO: Add test to verify candidate pool size is limited
      // This would require exposing candidate pool size through FFI
    });

    test('should respect early termination configuration', () {
      // RED: This test will fail until we implement early termination controls
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 500,
        earlyTerminationEnabled: false, // Disable early termination
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: false,
      ));

      final remainingWords = ['MATCH', 'PATCH', 'LATCH', 'HATCH'];
      final guessResults = <(String, List<String>)>[];
      
      final stopwatch = Stopwatch()..start();
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      stopwatch.stop();
      
      expect(bestGuess, isNotNull);
      
      // With early termination disabled, should process more candidates
      // (This is hard to test without exposing internal state, but we can test it doesn't crash)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should apply reference mode preset correctly', () {
      // RED: This test will fail until we implement reference mode preset
      FfiService.applyReferenceModePreset();
      
      final config = FfiService.getConfiguration();
      
      // Reference mode should have specific settings
      expect(config.referenceMode, true);
      expect(config.includeKillerWords, true);
      expect(config.candidateCap, greaterThan(500));
      expect(config.earlyTerminationEnabled, false);
      expect(config.entropyOnlyScoring, true);
    });

    test('should maintain performance with different candidate caps', () {
      // RED: This test will fail until we implement configurable caps
      final testCases = [
        {'cap': 100, 'expectedMaxTime': 100},
        {'cap': 500, 'expectedMaxTime': 200},
        {'cap': 1000, 'expectedMaxTime': 500},
      ];

      for (final testCase in testCases) {
        FfiService.setConfiguration(FfiConfiguration(
          referenceMode: false,
          includeKillerWords: true,
          candidateCap: testCase['cap'] as int,
          earlyTerminationEnabled: true,
          earlyTerminationThreshold: 5.0,
          entropyOnlyScoring: false,
        ));

        final remainingWords = ['CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT'];
        final guessResults = <(String, List<String>)>[];
        
        final stopwatch = Stopwatch()..start();
        final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
        stopwatch.stop();
        
        expect(bestGuess, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(testCase['expectedMaxTime'] as int));
        
        DebugLogger.debug('Candidate cap ${testCase['cap']}: ${stopwatch.elapsedMilliseconds}ms');
      }
    });

    test('should handle edge cases with candidate pool controls', () {
      // RED: This test will fail until we implement proper edge case handling
      
      // Test with very small candidate cap
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 5, // Very small
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 5.0,
        entropyOnlyScoring: false,
      ));

      final remainingWords = ['CRANE', 'SLATE', 'TRACE'];
      final guessResults = <(String, List<String>)>[];
      
      final bestGuess = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      // Should still work with very small cap
      expect(bestGuess, isNotNull);
      
      // Test with very large candidate cap
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 10000, // Very large
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 5.0,
        entropyOnlyScoring: false,
      ));

      final bestGuess2 = FfiService.getBestGuessFast(remainingWords, guessResults);
      expect(bestGuess2, isNotNull);
    });

    test('should reset to default configuration correctly', () {
      // RED: This test will fail until we implement reset functionality
      FfiService.applyReferenceModePreset();
      FfiService.resetToDefaultConfiguration();
      
      final config = FfiService.getConfiguration();
      
      // Should be back to defaults
      expect(config.referenceMode, false);
      expect(config.includeKillerWords, false);
      expect(config.candidateCap, 200);
      expect(config.earlyTerminationEnabled, true);
      expect(config.earlyTerminationThreshold, 5.0);
      expect(config.entropyOnlyScoring, false);
    });
  });
}
