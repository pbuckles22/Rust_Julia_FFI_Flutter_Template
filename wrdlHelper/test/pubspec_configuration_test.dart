import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// Tests for pubspec.yaml configuration
///
/// These tests verify that the pubspec.yaml file has been properly configured
/// with all necessary dependencies and settings for the Wordle Helper app.
void main() {
  group('Pubspec Configuration Tests', () {
    late Map<dynamic, dynamic> pubspecYaml;

    setUpAll(() {
      final pubspecFile = File('pubspec.yaml');
      expect(
        pubspecFile.existsSync(),
        isTrue,
        reason: 'pubspec.yaml file should exist',
      );

      final pubspecContent = pubspecFile.readAsStringSync();
      pubspecYaml = loadYaml(pubspecContent) as Map<dynamic, dynamic>;
    });

    test('project metadata is correctly configured', () {
      expect(pubspecYaml['name'], equals('wrdlhelper'));
      expect(
        pubspecYaml['description'],
        equals('wrdlHelper: AI-powered Wordle solver with 99.8% success rate'),
      );
      expect(pubspecYaml['version'], equals('1.0.0+1'));
      expect(pubspecYaml['publish_to'], equals('none'));
    });

    test('Flutter SDK version is specified', () {
      final environment = pubspecYaml['environment'] as Map<dynamic, dynamic>;
      expect(environment['sdk'], equals('^3.9.2'));
    });

    test('required dependencies are present', () {
      final dependencies = pubspecYaml['dependencies'] as Map<dynamic, dynamic>;

      // Core Flutter dependencies
      expect(dependencies['flutter'], isNotNull);
      expect(dependencies['cupertino_icons'], equals('^1.0.8'));

      // FFI and state management dependencies
      expect(dependencies['flutter_rust_bridge'], equals('2.11.1'));
      expect(dependencies['provider'], equals('^6.1.2'));
      expect(dependencies['json_annotation'], equals('^4.9.0'));
    });

    test('dev dependencies are present', () {
      final devDependencies =
          pubspecYaml['dev_dependencies'] as Map<dynamic, dynamic>;

      // Core testing dependencies
      expect(devDependencies['flutter_test'], isNotNull);
      expect(devDependencies['flutter_lints'], equals('^5.0.0'));

      // Code generation dependencies
      expect(devDependencies['json_serializable'], equals('^6.8.0'));
      expect(devDependencies['build_runner'], equals('^2.4.13'));
    });

    test('assets are properly configured', () {
      final flutter = pubspecYaml['flutter'] as Map<dynamic, dynamic>;
      expect(flutter['uses-material-design'], isTrue);

      final assets = flutter['assets'] as List<dynamic>;
      expect(assets, isNotNull);
      expect(assets.length, equals(2));
      expect(assets, contains('assets/word_lists/'));
      expect(assets, contains('assets/images/'));
    });

    test('dependency versions are reasonable', () {
      final dependencies = pubspecYaml['dependencies'] as Map<dynamic, dynamic>;

      // Check that version constraints are not too restrictive
      expect(dependencies['flutter_rust_bridge'], isA<String>());
      expect(dependencies['provider'], startsWith('^'));
      expect(dependencies['json_annotation'], startsWith('^'));

      // Check that version constraints are not too permissive
      expect(dependencies['flutter_rust_bridge'], isNot(startsWith('any')));
      expect(dependencies['provider'], isNot(startsWith('any')));
      expect(dependencies['json_annotation'], isNot(startsWith('any')));
    });

    test('no unnecessary dependencies are present', () {
      final dependencies = pubspecYaml['dependencies'] as Map<dynamic, dynamic>;

      // Verify only expected dependencies are present
      final expectedDeps = {
        'flutter',
        'cupertino_icons',
        'get_it', // Used for dependency injection in service_locator.dart
        'flutter_rust_bridge',
        'provider',
        'json_annotation',
        'rust_lib_wrdlhelper',
        'collection',
      };

      final actualDeps = dependencies.keys.toSet();
      expect(actualDeps, equals(expectedDeps));
    });

    test('dev dependencies are minimal and necessary', () {
      final devDependencies =
          pubspecYaml['dev_dependencies'] as Map<dynamic, dynamic>;

      // Verify only expected dev dependencies are present
      final expectedDevDeps = {
        'flutter_test',
        'flutter_lints',
        'json_serializable',
        'mockito',
        'build_runner',
        'flutter_driver',
        'integration_test', // Used for integration tests
        'yaml',
      };

      final actualDevDeps = devDependencies.keys.toSet();
      expect(actualDevDeps, equals(expectedDevDeps));
    });

    test('pubspec.yaml is valid YAML', () {
      // This test passes if we can load the YAML without errors
      expect(pubspecYaml, isNotNull);
      expect(pubspecYaml, isA<Map>());
    });

    test('project is configured for private package', () {
      expect(pubspecYaml['publish_to'], equals('none'));
    });
  });
}
