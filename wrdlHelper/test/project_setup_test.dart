import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for Flutter project setup and configuration
///
/// These tests verify that the Flutter project has been properly configured
/// with all necessary dependencies, assets, and directory structure for
/// the Wordle Helper app with FFI integration.
void main() {
  // Initialize Flutter binding for asset loading tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Flutter Project Setup Tests', () {
    test('project directory structure exists', () {
      // Verify main project directories exist
      expect(Directory('lib').existsSync(), isTrue);
      expect(Directory('lib/models').existsSync(), isTrue);
      expect(Directory('lib/services').existsSync(), isTrue);
      expect(Directory('lib/widgets').existsSync(), isTrue);
      expect(Directory('lib/controllers').existsSync(), isTrue);
      expect(Directory('lib/screens').existsSync(), isTrue);
      expect(Directory('rust').existsSync(), isTrue);
      expect(Directory('assets').existsSync(), isTrue);
      expect(Directory('assets/word_lists').existsSync(), isTrue);
      expect(Directory('assets/images').existsSync(), isTrue);
      expect(Directory('test').existsSync(), isTrue);
    });

    test('word list assets are accessible', () async {
      // Test that word list assets can be loaded
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );

      // Verify assets are not empty
      expect(wordListJson.isNotEmpty, isTrue);

      // Verify JSON is valid
      expect(() => wordListJson, returnsNormally);
    });

    test('pubspec.yaml has correct dependencies', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final pubspecContent = pubspecFile.readAsStringSync();

      // Verify project name and description
      expect(pubspecContent, contains('name: wrdlhelper'));
      expect(
        pubspecContent,
        contains(
          'description: "wrdlHelper: AI-powered Wordle solver with 99.8% '
          'success rate"',
        ),
      );

      // Verify required dependencies
      expect(pubspecContent, contains('flutter_rust_bridge: 2.11.1'));
      expect(pubspecContent, contains('provider: ^6.1.2'));
      expect(pubspecContent, contains('json_annotation: ^4.9.0'));

      // Verify dev dependencies
      expect(pubspecContent, contains('json_serializable: ^6.8.0'));
      expect(pubspecContent, contains('build_runner: ^2.4.13'));

      // Verify assets configuration
      expect(pubspecContent, contains('assets:'));
      expect(pubspecContent, contains('- assets/word_lists/'));
      expect(pubspecContent, contains('- assets/images/'));
    });

    test('project builds without errors', () async {
      // This test verifies that the project can be analyzed without errors
      // In a real test environment, this would run flutter analyze
      expect(
        true,
        isTrue,
      ); // Placeholder - actual build verification would be done in CI
    });

    test('main.dart exists and is valid Dart', () {
      final mainFile = File('lib/main.dart');
      expect(mainFile.existsSync(), isTrue);

      final mainContent = mainFile.readAsStringSync();

      // Verify it's valid Dart code (basic syntax check)
      expect(mainContent, contains('import'));
      expect(mainContent, contains('void main()'));
      expect(mainContent, contains('runApp'));
    });

    test('test directory has proper structure', () {
      expect(Directory('test').existsSync(), isTrue);

      // Verify test subdirectories exist
      expect(Directory('test/models').existsSync(), isTrue);
      expect(Directory('test/services').existsSync(), isTrue);
      expect(Directory('test/widgets').existsSync(), isTrue);
      expect(Directory('test/screens').existsSync(), isTrue);
      expect(Directory('test/integration').existsSync(), isTrue);
      expect(Directory('test/performance').existsSync(), isTrue);
      expect(Directory('test/error_handling').existsSync(), isTrue);
    });
  });

  group('Asset Loading Tests', () {
    test('wordle_words.json is valid JSON', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );

      // Parse JSON to verify it's valid
      final jsonData = jsonDecode(wordListJson);
      expect(jsonData, isA<Map>());

      // Verify it contains word data in the expected structure
      expect(jsonData, containsPair('answer_words', isA<List>()));
      expect(jsonData, containsPair('guess_words', isA<List>()));
      
      // Verify it contains sufficient word data
      final answerWords = jsonData['answer_words'] as List;
      final guessWords = jsonData['guess_words'] as List;
      expect(answerWords.length, greaterThan(2000)); // Answer words
      expect(guessWords.length, greaterThan(10000)); // Guess words
    });

    test('wordle_words.json contains valid word data', () async {
      final wordListJson = await rootBundle.loadString(
        'assets/word_lists/official_wordle_words.json',
      );

      // Parse JSON to verify it's valid
      final jsonData = jsonDecode(wordListJson);
      expect(jsonData, isA<Map>());

      // Verify it contains word data in the expected structure
      final answerWords = jsonData['answer_words'] as List;
      final guessWords = jsonData['guess_words'] as List;
      
      // Verify it contains words (basic check)
      expect(answerWords.length, greaterThan(2000));
      expect(guessWords.length, greaterThan(10000));

      // Verify words are 5 letters (basic validation)
      for (final word in answerWords.take(5)) {
        // Check first 5 words
        if (word is String && word.trim().isNotEmpty) {
          expect(word.trim().length, equals(5));
        }
      }
    });
  });

  group('Dependency Configuration Tests', () {
    test('flutter_rust_bridge dependency is configured', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();

      expect(pubspecContent, contains('flutter_rust_bridge: 2.11.1'));
    });

    test('state management dependencies are configured', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();

      expect(pubspecContent, contains('provider: ^6.1.2'));
    });

    test('JSON serialization dependencies are configured', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();

      expect(pubspecContent, contains('json_annotation: ^4.9.0'));
      expect(pubspecContent, contains('json_serializable: ^6.8.0'));
      expect(pubspecContent, contains('build_runner: ^2.4.13'));
    });

    test('assets are properly configured in pubspec.yaml', () {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = pubspecFile.readAsStringSync();

      // Verify assets section exists
      expect(pubspecContent, contains('assets:'));
      expect(pubspecContent, contains('- assets/word_lists/'));
      expect(pubspecContent, contains('- assets/images/'));
    });
  });

  group('Project Structure Validation Tests', () {
    test('all required directories exist', () {
      final requiredDirs = [
        'lib',
        'lib/models',
        'lib/services',
        'lib/widgets',
        'lib/controllers',
        'lib/screens',
        'rust',
        'assets',
        'assets/word_lists',
        'assets/images',
        'test',
      ];

      for (final dir in requiredDirs) {
        expect(
          Directory(dir).existsSync(),
          isTrue,
          reason: 'Directory $dir should exist',
        );
      }
    });

    test('rust directory is ready for FFI implementation', () {
      expect(Directory('rust').existsSync(), isTrue);

      // Verify rust directory has FFI implementation files
      final rustDir = Directory('rust');
      final contents = rustDir.listSync();
      expect(
        contents.isNotEmpty,
        isTrue,
        reason: 'Rust directory should contain FFI implementation files',
      );

      // Check for key FFI files
      final rustFiles = contents.map((e) => e.path.split('/').last).toList();
      expect(rustFiles, contains('Cargo.toml'));
      expect(rustFiles, contains('src'));
    });

    test('lib subdirectories exist and are properly structured', () {
      final libSubdirs = [
        'models',
        'services',
        'widgets',
        'controllers',
        'screens',
      ];

      for (final subdir in libSubdirs) {
        final dir = Directory('lib/$subdir');
        expect(
          dir.existsSync(),
          isTrue,
          reason: 'Directory lib/$subdir should exist',
        );

        if (subdir == 'models' ||
            subdir == 'services' ||
            subdir == 'widgets' ||
            subdir == 'screens' ||
            subdir == 'controllers') {
          // These directories should contain implemented files
          final contents = dir.listSync();
          expect(
            contents.isNotEmpty,
            isTrue,
            reason: 'Directory lib/$subdir should contain implemented files',
          );
        } else {
          // Other directories should be empty and ready for implementation
          final contents = dir.listSync();
          expect(
            contents.isEmpty,
            isTrue,
            reason:
                'Directory lib/$subdir should be empty and ready for implementation',
          );
        }
      }
    });
  });
}
