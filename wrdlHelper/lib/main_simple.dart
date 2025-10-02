import 'package:flutter/material.dart';
import 'package:wrdlhelper/bridge_generated/frb_generated.dart';
import 'package:wrdlhelper/bridge_generated/wordle_ffi.dart' as ffi;

void main() async {
  print('🚀 SIMPLE APP STARTING...');

  // Initialize FFI bridge
  print('🔧 Initializing FFI bridge...');
  try {
    await RustLib.init();
    print('✅ FFI bridge initialized successfully!');
  } catch (e, stackTrace) {
    print('❌ FFI bridge initialization failed: $e');
    print('Stack trace: $stackTrace');
  }

  runApp(const SimpleApp());
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎯 SimpleApp build() called');
    return MaterialApp(
      title: 'Simple Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Simple Test App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hello World!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testFfiConnection,
                child: const Text('🔧 Test FFI'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Test FFI connection with simple hello_rust function
  void _testFfiConnection() {
    print('🔍 FLUTTER DEBUG: Calling hello_rust...');
    try {
      final response = ffi.helloRust(message: "World");
      print('✅ FFI SUCCESS: Rust responded with: "$response"');
    } catch (e, stackTrace) {
      print('❌ FFI FAILED: Could not call hello_rust.');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
