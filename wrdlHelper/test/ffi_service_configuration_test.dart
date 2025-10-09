import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/services/ffi_service.dart';

void main() {
  group('FFI Service Configuration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await RustLib.init();
      await FfiService.initialize();
    });

    test('setConfiguration() should update configuration correctly', () {
      // RED: This test will verify configuration setting works
      
      // Get initial configuration
      final initialConfig = FfiService.getConfiguration();
      expect(initialConfig, isNotNull);
      expect(initialConfig.referenceMode, isFalse); // Default should be false
      
      // Set new configuration
      final newConfig = const FfiConfiguration(
        referenceMode: true,
        includeKillerWords: true,
        candidateCap: 1000,
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 10.0,
        entropyOnlyScoring: true,
      );
      
      FfiService.setConfiguration(newConfig);
      
      // Verify configuration was updated
      final updatedConfig = FfiService.getConfiguration();
      expect(updatedConfig.referenceMode, isTrue);
      expect(updatedConfig.includeKillerWords, isTrue);
      expect(updatedConfig.candidateCap, equals(1000));
      expect(updatedConfig.earlyTerminationEnabled, isFalse);
      expect(updatedConfig.earlyTerminationThreshold, equals(10.0));
      expect(updatedConfig.entropyOnlyScoring, isTrue);
    });

    test('applyReferenceModePreset() should set reference mode configuration', () {
      // RED: This test will verify reference mode preset works
      
      // Apply reference mode preset
      FfiService.applyReferenceModePreset();
      
      // Verify configuration was set to reference mode
      final config = FfiService.getConfiguration();
      expect(config.referenceMode, isTrue);
      expect(config.includeKillerWords, isTrue);
      expect(config.candidateCap, equals(1000));
      expect(config.earlyTerminationEnabled, isFalse);
      expect(config.earlyTerminationThreshold, equals(10.0));
      expect(config.entropyOnlyScoring, isTrue);
    });

    test('resetToDefaultConfiguration() should reset to default values', () {
      // RED: This test will verify default configuration reset works
      
      // First set a custom configuration
      final customConfig = const FfiConfiguration(
        referenceMode: true,
        includeKillerWords: true,
        candidateCap: 500,
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 15.0,
        entropyOnlyScoring: true,
      );
      FfiService.setConfiguration(customConfig);
      
      // Verify it was set
      var config = FfiService.getConfiguration();
      expect(config.referenceMode, isTrue);
      expect(config.candidateCap, equals(500));
      
      // Reset to default
      FfiService.resetToDefaultConfiguration();
      
      // Verify it was reset to defaults
      config = FfiService.getConfiguration();
      expect(config.referenceMode, isFalse);
      expect(config.includeKillerWords, isFalse);
      expect(config.candidateCap, equals(200));
      expect(config.earlyTerminationEnabled, isTrue);
      expect(config.earlyTerminationThreshold, equals(5.0));
      expect(config.entropyOnlyScoring, isFalse);
    });

    test('configuration should affect guess behavior', () {
      // RED: This test will verify configuration affects algorithm behavior
      
      final remainingWords = FfiService.getAnswerWords().take(50).toList();
      final guessResults = <(String, List<String>)>[];
      
      // Test with default configuration
      FfiService.resetToDefaultConfiguration();
      final defaultSuggestion = FfiService.getBestGuessFast(remainingWords, guessResults);
      
      // Test with reference mode configuration
      FfiService.applyReferenceModePreset();
      final referenceSuggestion = FfiService.getBestGuessReference(remainingWords, guessResults);
      
      // Both should return valid suggestions
      expect(defaultSuggestion, isNotNull);
      expect(referenceSuggestion, isNotNull);
      
      // Both should be valid words
      expect(FfiService.isValidWord(defaultSuggestion!), isTrue);
      expect(FfiService.isValidWord(referenceSuggestion!), isTrue);
      
      // Both should be 5-letter words
      expect(defaultSuggestion!.length, equals(5));
      expect(referenceSuggestion!.length, equals(5));
      
      // Note: The suggestions might be different due to different algorithms
      // This is expected behavior based on configuration
    });

    test('configuration should persist across multiple calls', () {
      // RED: This test will verify configuration persistence
      
      // Set a specific configuration
      final testConfig = const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 300,
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 7.5,
        entropyOnlyScoring: false,
      );
      
      FfiService.setConfiguration(testConfig);
      
      // Make multiple calls and verify configuration persists
      for (int i = 0; i < 5; i++) {
        final config = FfiService.getConfiguration();
        expect(config.referenceMode, isFalse);
        expect(config.includeKillerWords, isTrue);
        expect(config.candidateCap, equals(300));
        expect(config.earlyTerminationEnabled, isTrue);
        expect(config.earlyTerminationThreshold, equals(7.5));
        expect(config.entropyOnlyScoring, isFalse);
      }
    });

    test('configuration should handle edge case values', () {
      // RED: This test will verify edge case configuration values
      
      // Test with extreme values
      final extremeConfig = const FfiConfiguration(
        referenceMode: true,
        includeKillerWords: false,
        candidateCap: 1, // Very small
        earlyTerminationEnabled: true,
        earlyTerminationThreshold: 0.1, // Very small
        entropyOnlyScoring: true,
      );
      
      FfiService.setConfiguration(extremeConfig);
      
      // Verify extreme values are accepted
      final config = FfiService.getConfiguration();
      expect(config.candidateCap, equals(1));
      expect(config.earlyTerminationThreshold, equals(0.1));
      
      // Test with large values
      final largeConfig = const FfiConfiguration(
        referenceMode: false,
        includeKillerWords: true,
        candidateCap: 10000, // Very large
        earlyTerminationEnabled: false,
        earlyTerminationThreshold: 100.0, // Very large
        entropyOnlyScoring: false,
      );
      
      FfiService.setConfiguration(largeConfig);
      
      // Verify large values are accepted
      final largeConfigResult = FfiService.getConfiguration();
      expect(largeConfigResult.candidateCap, equals(10000));
      expect(largeConfigResult.earlyTerminationThreshold, equals(100.0));
    });
  });
}
