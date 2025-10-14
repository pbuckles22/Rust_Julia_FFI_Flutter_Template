import 'package:flutter/material.dart';
import 'package:wrdlhelper/screens/wordle_game_screen.dart';
import 'package:wrdlhelper/service_locator.dart';
import 'package:wrdlhelper/utils/debug_logger.dart';

// REMOVED: No async, no try-catch. Just run the app.
void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatefulWidget {
  /// Creates the main application widget
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Use a Future to track the initialization state
  late final Future<void> _servicesInitFuture;
  
  String _status = '🚀 App starting... Initializing services...';

  @override
  void initState() {
    super.initState();
    // Start the initialization process here
    _servicesInitFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _status = '🔧 Initializing FFI and services...';
      });
      
      await setupServices();
      
      setState(() {
        _status = '✅ All services initialized successfully!';
      });
    } on Exception catch (e, stackTrace) {
      DebugLogger.error(
        '❌ CRITICAL: Failed to initialize app services: $e',
        tag: 'Main',
      );
      DebugLogger.error('Stack trace: $stackTrace', tag: 'Main');

      // No fallback - app should fail hard if services can't initialize
      setState(() {
        _status = '❌ Failed to initialize services - app cannot start';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<void>(
        future: _servicesInitFuture,
        builder: (context, snapshot) {
          // If the future is still running, show a loading indicator
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Wordle Helper'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_status),
                  ],
                ),
              ),
            );
          }

          // If the future completed with an error, show the error
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Wordle Helper'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              body: Center(
                child: Text('❌ Initialization Failed: ${snapshot.error}'),
              ),
            );
          }

          // If the future completed successfully, show the main UI
          return const WordleGameScreen();
        },
      ),
    );
  }
}
