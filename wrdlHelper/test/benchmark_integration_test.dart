import 'package:flutter_test/flutter_test.dart';

import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

void main() {
  group('Benchmark Integration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('default mode performance meets baseline targets', () {
      // Test with a representative sample of words
      final testWords = [
        'CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT', 'LEAST', 'STARE', 'TARES',
        'RAISE', 'ARISE', 'SOARE', 'ROATE', 'ADIEU', 'AUDIO', 'ALIEN', 'STONE',
        'STORE', 'STORM', 'STOMP', 'PLATE', 'GRATE', 'CHASE', 'CLOTH', 'CLOUD'
      ];

      FfiService.resetToDefaultConfiguration();
      
      final stopwatch = Stopwatch()..start();
      final bestGuess = FfiService.getBestGuessFast(testWords, []);
      stopwatch.stop();
      
      expect(bestGuess, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(100), 
          reason: 'Default mode should be fast (<100ms)');
      
      DebugLogger.debug('Default mode: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('reference mode performance meets targets', () {
      final testWords = [
        'CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT', 'LEAST', 'STARE', 'TARES',
        'RAISE', 'ARISE', 'SOARE', 'ROATE', 'ADIEU', 'AUDIO', 'ALIEN', 'STONE',
        'STORE', 'STORM', 'STOMP', 'PLATE', 'GRATE', 'CHASE', 'CLOTH', 'CLOUD'
      ];

      FfiService.applyReferenceModePreset();
      
      final stopwatch = Stopwatch()..start();
      final bestGuess = FfiService.getBestGuessFast(testWords, []);
      stopwatch.stop();
      
      expect(bestGuess, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(500), 
          reason: 'Reference mode should be reasonable (<500ms)');
      
      DebugLogger.debug('Reference mode: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('entropy calculation performance', () {
      final remainingWords = [
        'CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT', 'LEAST', 'STARE', 'TARES'
      ];
      
      final stopwatch = Stopwatch()..start();
      final entropy = FfiService.calculateEntropy('SLATE', remainingWords);
      stopwatch.stop();
      
      expect(entropy, greaterThan(0.0));
      expect(stopwatch.elapsedMilliseconds, lessThan(50), 
          reason: 'Entropy calculation should be fast (<50ms)');
      
      DebugLogger.debug('Entropy calculation: ${stopwatch.elapsedMilliseconds}ms, value: $entropy');
    });

    test('filtering performance with multiple patterns', () {
      final allWords = [
        'CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT', 'LEAST', 'STARE', 'TARES',
        'RAISE', 'ARISE', 'SOARE', 'ROATE', 'ADIEU', 'AUDIO', 'ALIEN', 'STONE',
        'STORE', 'STORM', 'STOMP', 'PLATE', 'GRATE', 'CHASE', 'CLOTH', 'CLOUD'
      ];
      
      final guessResults = [
        ('CRANE', ['G', 'X', 'X', 'X', 'X']), // C green, others gray
      ];
      
      final stopwatch = Stopwatch()..start();
      final filtered = FfiService.filterWords(allWords, guessResults);
      stopwatch.stop();
      
      expect(filtered, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(50), 
          reason: 'Filtering should be fast (<50ms)');
      
      DebugLogger.debug('Filtering: ${stopwatch.elapsedMilliseconds}ms, filtered: ${filtered.length} words');
    });

    test('configuration switching performance', () {
      final testWords = ['CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT'];
      
      // Test switching between configurations
      final configs = [
        () => FfiService.resetToDefaultConfiguration(),
        () => FfiService.applyReferenceModePreset(),
        () => FfiService.setConfiguration(FfiConfiguration(
          referenceMode: false,
          includeKillerWords: true,
          candidateCap: 500,
          earlyTerminationEnabled: false,
          earlyTerminationThreshold: 10.0,
          entropyOnlyScoring: true,
        )),
      ];
      
      for (int i = 0; i < configs.length; i++) {
        configs[i]();
        
        final stopwatch = Stopwatch()..start();
        final bestGuess = FfiService.getBestGuessFast(testWords, []);
        stopwatch.stop();
        
        expect(bestGuess, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(200), 
            reason: 'Config $i should be fast (<200ms)');
        
        DebugLogger.debug('Config $i: ${stopwatch.elapsedMilliseconds}ms');
      }
    });

    test('memory usage and stability over multiple calls', () {
      final testWords = ['CRANE', 'SLATE', 'TRACE', 'CRATE', 'SLANT'];
      
      // Make many calls to test for memory leaks or performance degradation
      for (int i = 0; i < 100; i++) {
        final bestGuess = FfiService.getBestGuessFast(testWords, []);
        expect(bestGuess, isNotNull);
        
        if (i % 20 == 0) {
          DebugLogger.debug('Iteration $i: $bestGuess');
        }
      }
      
      // Final performance check
      final stopwatch = Stopwatch()..start();
      final finalGuess = FfiService.getBestGuessFast(testWords, []);
      stopwatch.stop();
      
      expect(finalGuess, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(100), 
          reason: 'Performance should not degrade after many calls');
      
      DebugLogger.debug('Final call after 100 iterations: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
