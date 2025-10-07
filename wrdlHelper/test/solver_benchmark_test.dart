import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Solver Benchmark', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('baseline vs reference-mode latency', () {
      // Use a modest set to keep test stable and fast
      final remainingWords = [
        'CRANE','SLATE','TRACE','CRATE','SLANT','LEAST','STARE','TARES','RAISE','ARISE',
        'SOARE','ROATE','ADIEU','AUDIO','ALIEN','STONE','STORE','STORM','STOMP','PLATE'
      ];
      final guessResults = <(String, List<String>)>[];

      // Baseline
      FfiService.resetToDefaultConfiguration();
      final t1 = Stopwatch()..start();
      final g1 = FfiService.getBestGuessFast(remainingWords, guessResults);
      t1.stop();
      expect(g1, isNotNull);

      // Reference-mode (entropy-only, no early stop, larger cap)
      FfiService.applyReferenceModePreset();
      final t2 = Stopwatch()..start();
      final g2 = FfiService.getBestGuessFast(remainingWords, guessResults);
      t2.stop();
      expect(g2, isNotNull);

      // Print timings for observability
      // ignore: avoid_print
      print('Benchmark — baseline: ${t1.elapsedMicroseconds}µs, reference: ${t2.elapsedMicroseconds}µs');

      // Guardrails: both should be fast in unit context
      expect(t1.elapsedMilliseconds, lessThan(200));
      expect(t2.elapsedMilliseconds, lessThan(400));
    });
  });
}



