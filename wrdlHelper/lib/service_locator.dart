import 'package:get_it/get_it.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/game_service.dart';
import 'package:wrdlhelper/services/word_service.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

// This is our global service locator
final sl = GetIt.instance;

// Function to reset all services (for testing)
void resetAllServices() {
  if (sl.isRegistered<AppService>()) {
    sl.unregister<AppService>();
  }
  if (sl.isRegistered<WordService>()) {
    sl.unregister<WordService>();
  }
  if (sl.isRegistered<GameService>()) {
    sl.unregister<GameService>();
  }
  DebugLogger.info('🔄 All services reset for testing', tag: 'ServiceLocator');
}

// This function will register your REAL services
Future<void> setupServices() async {
  try {
    DebugLogger.info('🔧 Creating AppService...', tag: 'ServiceLocator');

    // Create and initialize the service
    final appService = AppService();

    DebugLogger.info('🔧 Initializing AppService...', tag: 'ServiceLocator');
    await appService.initialize();

    DebugLogger.info(
      '🔧 Registering services in GetIt...',
      tag: 'ServiceLocator',
    );

    // Register it as a singleton in the service locator
    sl.registerSingleton<AppService>(appService);

    // Register individual services for easier access
    sl.registerSingleton<WordService>(appService.wordService);
    sl.registerSingleton<GameService>(appService.gameService);

    DebugLogger.success(
      '✅ All services registered successfully!',
      tag: 'ServiceLocator',
    );
    DebugLogger.info('📊 Registered services:', tag: 'ServiceLocator');
    DebugLogger.info(
      '  • AppService: ${sl.isRegistered<AppService>()}',
      tag: 'ServiceLocator',
    );
    DebugLogger.info(
      '  • WordService: ${sl.isRegistered<WordService>()}',
      tag: 'ServiceLocator',
    );
    DebugLogger.info(
      '  • GameService: ${sl.isRegistered<GameService>()}',
      tag: 'ServiceLocator',
    );
  } catch (e, stackTrace) {
    DebugLogger.error(
      '❌ CRITICAL: Service initialization failed: $e',
      tag: 'ServiceLocator',
    );
    DebugLogger.error('Stack trace: $stackTrace', tag: 'ServiceLocator');
    rethrow;
  }
}

// Fallback mock services for when real services fail to initialize
void setupMockServices() {
  DebugLogger.info('🔧 Setting up mock services...', tag: 'ServiceLocator');

  // Register mock services
  sl.registerSingleton<AppService>(MockAppService() as AppService);
  sl.registerSingleton<WordService>(MockWordService() as WordService);
  sl.registerSingleton<GameService>(
    MockGameService(wordService: MockWordService() as WordService)
        as GameService,
  );

  DebugLogger.success(
    '✅ Mock services registered successfully!',
    tag: 'ServiceLocator',
  );
}

// Mock AppService
class MockAppService {
  Future<void> initialize() async {
    DebugLogger.info(
      '🔧 Mock AppService initializing...',
      tag: 'MockAppService',
    );
    // Mock initialization - do nothing
  }

  WordService get wordService => MockWordService() as WordService;

  GameService get gameService =>
      MockGameService(wordService: MockWordService() as WordService)
          as GameService;
}

// Mock WordService
class MockWordService {
  Future<void> loadWordList(String assetPath) async {
    DebugLogger.info(
      '🔧 Mock WordService loading word list: $assetPath',
      tag: 'MockWordService',
    );
    // Mock loading - do nothing
  }

  Future<void> loadGuessWords(String assetPath) async {
    DebugLogger.info(
      '🔧 Mock WordService loading guess words: $assetPath',
      tag: 'MockWordService',
    );
    // Mock loading - do nothing
  }

  Future<void> loadAnswerWords(String assetPath) async {
    DebugLogger.info(
      '🔧 Mock WordService loading answer words: $assetPath',
      tag: 'MockWordService',
    );
    // Mock loading - do nothing
  }
}

// Mock GameService
class MockGameService {
  MockGameService({required WordService wordService}) {
    // Constructor body
  }

  Future<void> initialize() async {
    DebugLogger.info(
      '🔧 Mock GameService initializing...',
      tag: 'MockGameService',
    );
    // Mock initialization - do nothing
  }

  Word? suggestNextGuess(GameState state) {
    DebugLogger.info(
      '🔧 Mock GameService suggesting next guess',
      tag: 'MockGameService',
    );
    // Always return CRANE as the mock suggestion
    return Word.fromString('CRANE');
  }

  GameState createNewGame() {
    return GameState.newGame(targetWord: Word.fromString('CRATE'));
  }
}
