import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() {
  group('Filtering Parity (gray/yellow/green)', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
      FfiService.resetToDefaultConfiguration();
    });

    test('gray: eliminates letters not present anywhere', () {
      final remaining = ['CRANE', 'SLATE', 'TRACE', 'GRACE'];
      // Guess: POOFS -> all gray for letters P,O,O,F,S against remaining set
      final guessResults = <(String, List<String>)>[
        ('POOFS', ['X','X','X','X','X'])
      ];

      final filtered = FfiService.filterWords(remaining, guessResults);
      // Words containing P/O/F/S must be excluded
      expect(filtered.every((w) => !w.contains(RegExp(r"[POFS]"))), isTrue);
    });

    test('green: fixes letters in exact positions', () {
      final remaining = ['CRANE'];
      // Guess: CRANE -> C(0) green, R(1) green, A(2) green, N(3) green,
      // E(4) green
      final guessResults = <(String, List<String>)>[
        ('CRANE', ['G','G','G','G','G'])
      ];

      final filtered = FfiService.filterWords(remaining, guessResults);
      expect(filtered, equals(['CRANE']));
    });

    test('yellow: letter present but in different position', () {
      // Choose remaining words that do not include L,A,T,E to avoid
      // gray-elimination side effects
      final remaining = ['ASIDE', 'BASIS', 'MOSSY'];
      // Guess: SQQQQ with yellow at index 0 (S present elsewhere), others
      // gray (Q not present)
      final guessResults = <(String, List<String>)>[
        ('SQQQQ', ['Y','X','X','X','X'])
      ];

      final filtered = FfiService.filterWords(remaining, guessResults);
      // All results must contain 'S' but not at index 0
      expect(filtered.isNotEmpty, isTrue);
      expect(filtered.every((w) => w.contains('S') && w[0] != 'S'), isTrue);
    });

    test('duplicate letters: gray means count limit reached', () {
      final remaining = ['MUMMY', 'HUMUS', 'HUMPH'];
      // Guess: MUMMY -> suppose pattern says M green at 0, U yellow at 1,
      // M gray at 2 (no second M allowed), M gray at 3, Y gray at 4
      final guessResults = <(String, List<String>)>[
        ('MUMMY', ['G','Y','X','X','X'])
      ];

      final filtered = FfiService.filterWords(remaining, guessResults);
      // Should allow exactly one M and must contain U not at index 1
      expect(filtered.every((w) =>
        w.split('').where((c) => c=='M').length == 1 &&
        w.contains('U') && w[1] != 'U'
      ), isTrue);
    });
  });
}
