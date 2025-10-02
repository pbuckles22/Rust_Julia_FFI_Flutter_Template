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
    // Check if services are already registered
    if (sl.isRegistered<AppService>()) {
      DebugLogger.info('🔧 Services already registered, skipping setup', tag: 'ServiceLocator');
      return;
    }

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

// Mock services have been removed - all tests now use real services
// This provides better integration testing and validates actual system performance
