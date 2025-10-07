import 'package:get_it/get_it.dart';
import 'package:wrdlhelper/models/game_state.dart';
import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/services/app_service.dart';
import 'package:wrdlhelper/services/ffi_service.dart';
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


// Global cache for test performance optimization
AppService? _cachedAppService;
bool _isTestCacheInitialized = false;

// This function will register your services with full production word lists
Future<void> setupServices({bool useMocks = false}) async {
  try {
    // Check if services are already registered
    if (sl.isRegistered<AppService>()) {
      DebugLogger.info('🔧 Services already registered, skipping setup', tag: 'ServiceLocator');
      return;
    }

    // For tests, try to reuse cached service for performance
    if (_isTestCacheInitialized && _cachedAppService != null) {
      DebugLogger.info('🚀 Using cached AppService for fast testing...', tag: 'ServiceLocator');
      
      // Register the cached service
      sl.registerSingleton<AppService>(_cachedAppService!);
      sl.registerSingleton<WordService>(_cachedAppService!.wordService);
      sl.registerSingleton<GameService>(_cachedAppService!.gameService);
      
      DebugLogger.success('✅ Cached services registered successfully!', tag: 'ServiceLocator');
      return;
    }

    DebugLogger.info('🔧 Creating REAL AppService...', tag: 'ServiceLocator');

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

    // Cache for future tests
    if (!_isTestCacheInitialized) {
      _cachedAppService = appService;
      _isTestCacheInitialized = true;
      DebugLogger.info('💾 Cached AppService for future tests', tag: 'ServiceLocator');
    }

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

// This function will register your services with algorithm-testing word list for tests
Future<void> setupTestServices({bool useMocks = false}) async {
  try {
    // Check if services are already registered
    if (sl.isRegistered<AppService>()) {
      DebugLogger.info('🔧 Test services already registered, skipping setup', tag: 'ServiceLocator');
      return;
    }

    // For tests, try to reuse cached service for performance
    if (_isTestCacheInitialized && _cachedAppService != null) {
      DebugLogger.info('🚀 Using cached test AppService for fast testing...', tag: 'ServiceLocator');
      
      // Register the cached service
      sl.registerSingleton<AppService>(_cachedAppService!);
      sl.registerSingleton<WordService>(_cachedAppService!.wordService);
      sl.registerSingleton<GameService>(_cachedAppService!.gameService);
      
      DebugLogger.success('✅ Cached test services registered successfully!', tag: 'ServiceLocator');
      return;
    }

    DebugLogger.info('🔧 Creating TEST AppService with algorithm-testing word list...', tag: 'ServiceLocator');

    // Initialize FFI service first
    await FfiService.initialize();
    
    // Create WordService and load algorithm-testing word list
    final wordService = WordService();
    await wordService.loadAlgorithmTestingWordList();
    
    // Load word lists to Rust
    FfiService.loadWordListsToRust(
      wordService.answerWords.map((w) => w.value).toList(),
      wordService.guessWords.map((w) => w.value).toList(),
    );
    
    // Create GameService
    final gameService = GameService();
    await gameService.initialize();
    
    // Create AppService and initialize it manually
    final appService = AppService();
    await appService.initializeForTesting(wordService, gameService);

    DebugLogger.info('🔧 Registering test services in GetIt...', tag: 'ServiceLocator');

    // Register it as a singleton in the service locator
    sl.registerSingleton<AppService>(appService);

    // Register individual services for easier access
    sl.registerSingleton<WordService>(wordService);
    sl.registerSingleton<GameService>(gameService);

    // Cache for future tests
    if (!_isTestCacheInitialized) {
      _cachedAppService = appService;
      _isTestCacheInitialized = true;
      DebugLogger.info('💾 Cached test AppService for future tests', tag: 'ServiceLocator');
    }

    DebugLogger.success('✅ All test services registered successfully!', tag: 'ServiceLocator');
    DebugLogger.info('📊 Registered test services:', tag: 'ServiceLocator');
    DebugLogger.info('  • AppService: ${sl.isRegistered<AppService>()}', tag: 'ServiceLocator');
    DebugLogger.info('  • WordService: ${sl.isRegistered<WordService>()}', tag: 'ServiceLocator');
    DebugLogger.info('  • GameService: ${sl.isRegistered<GameService>()}', tag: 'ServiceLocator');
  } catch (e, stackTrace) {
    DebugLogger.error('❌ CRITICAL: Test service initialization failed: $e', tag: 'ServiceLocator');
    DebugLogger.error('Stack trace: $stackTrace', tag: 'ServiceLocator');
    rethrow;
  }
}

// Mock services have been removed - all tests now use real services
// This provides better integration testing and validates actual system performance
