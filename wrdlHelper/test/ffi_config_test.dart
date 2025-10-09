import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('FFI Configuration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('should have default configuration values', () {
      // RED: This test will fail until we implement the config system
      final config = FfiService.getConfiguration();
      
      expect(config.referenceMode, false, reason: 'Default should be false');
      expect(config.includeKillerWords, false, reason: 'Default should be false');
      expect(config.candidateCap, 200, reason: 'Default should be 200');
      expect(config.earlyTerminationEnabled, true, reason: 'Default should be true');
      expect(config.earlyTerminationThreshold, 5.0, reason: 'Default should be 5.0');
      expect(config.entropyOnlyScoring, false, reason: 'Default should be false');
    });

    test('should allow setting configuration values', () {
      // RED: This test will fail until we implement the config system
      final newConfig = const FfiConfiguration(
        referenceMode: true,
        includeKillerWords: true,
        candidateCap: 1000,
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: true,
      );
      
      FfiService.setConfiguration(newConfig);
      
      final retrievedConfig = FfiService.getConfiguration();
      expect(retrievedConfig.referenceMode, true);
      expect(retrievedConfig.includeKillerWords, true);
      expect(retrievedConfig.candidateCap, 1000);
      expect(retrievedConfig.earlyTerminationEnabled, false);
      expect(retrievedConfig.earlyTerminationThreshold, 10.0);
      expect(retrievedConfig.entropyOnlyScoring, true);
    });

    test('should apply reference mode preset', () {
      // RED: This test will fail until we implement the preset system
      FfiService.applyReferenceModePreset();
      
      final config = FfiService.getConfiguration();
      expect(config.referenceMode, true);
      expect(config.includeKillerWords, true);
      expect(config.candidateCap, greaterThan(500));
      expect(config.earlyTerminationEnabled, false);
      expect(config.entropyOnlyScoring, true);
    });

    test('should reset to default configuration', () {
      // RED: This test will fail until we implement the reset system
      FfiService.applyReferenceModePreset();
      FfiService.resetToDefaultConfiguration();
      
      final config = FfiService.getConfiguration();
      expect(config.referenceMode, false);
      expect(config.includeKillerWords, false);
      expect(config.candidateCap, 200);
      expect(config.earlyTerminationEnabled, true);
      expect(config.earlyTerminationThreshold, 5.0);
      expect(config.entropyOnlyScoring, false);
    });

    test('should maintain configuration across FFI calls', () {
      // RED: This test will fail until we implement persistent config
      FfiService.setConfiguration(const FfiConfiguration(
        referenceMode: true,
        includeKillerWords: true,
        candidateCap: 500,
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 8.0,
        entropyOnlyScoring: true,
      ));
      
      // Make a dummy FFI call to ensure config persists
      
      final config = FfiService.getConfiguration();
      expect(config.referenceMode, true);
      expect(config.includeKillerWords, true);
      expect(config.candidateCap, 500);
      expect(config.earlyTerminationEnabled, false);
      expect(config.earlyTerminationThreshold, 8.0);
      expect(config.entropyOnlyScoring, true);
    });
  });
}


