import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';

import 'mock_app_service.mocks.dart';

// Generate mocks using Mockito
@GenerateMocks([AppService])
void main() {}

/// Mock AppService for unit tests
/// 
/// This provides a lightweight, fast mock implementation that doesn't
/// perform expensive initialization or FFI calls.
class MockAppService extends Mock implements AppService {
  late final WordService _wordService;
  late final GameService _gameService;

  MockAppService() {
    // Create mock services
    _wordService = MockWordService();
    _gameService = MockGameService();
  }

  @override
  WordService get wordService => _wordService;

  @override
  GameService get gameService => _gameService;

  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize({bool fastTestMode = false}) async {
    // Mock initialization - do nothing
  }
}

// Import the mock classes
import 'mock_word_service.dart';
import 'mock_game_service.dart';
