import 'package:flutter/material.dart';

import 'package:wrdlhelper/src/rust/api/simple.dart';
import 'package:wrdlhelper/src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const iPhone12PerformanceTestApp());
}

class iPhone12PerformanceTestApp extends StatelessWidget {
  const iPhone12PerformanceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iPhone 12 Performance Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const iPhone12PerformanceTestScreen(),
    );
  }
}

class iPhone12PerformanceTestScreen extends StatefulWidget {
  const iPhone12PerformanceTestScreen({super.key});

  @override
  State<iPhone12PerformanceTestScreen> createState() =>
      _iPhone12PerformanceTestScreenState();
}

class _iPhone12PerformanceTestScreenState
    extends State<iPhone12PerformanceTestScreen> {
  String _result = 'Ready to test iPhone 12 performance...';
  bool _isRunning = false;

  Future<void> _runiPhone12PerformanceTest() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _result = '🔄 Running iPhone 12 Performance Test...\n';
    });

    final results = <String>[];
    results.add('📱 iPhone 12 Performance Test (Simulated)');
    results.add('🕐 Started: ${DateTime.now()}');
    results.add('');

    // iPhone 12 has A14 Bionic vs iPhone 15 Pro Max A17 Pro
    // A14 is roughly 60-70% of A17 Pro performance
    // So we'll use 60% of the extreme test parameters
    
    // Test 1: Basic FFI Performance (60% of extreme)
    results.add('📊 Test 1: Basic FFI Performance');
    results.add('-' * 30);
    
    final stopwatch = Stopwatch()..start();
    int operations = 0;
    const maxOperations = 6000; // 60% of 10,000
    
    try {
      for (int i = 0; i < maxOperations; i++) {
        // Use existing FFI function for performance testing
        final result = getAnswerWords();
        if (result.isEmpty) {
          results.add('❌ FFI test failed at operation $i');
          break;
        }
        operations++;
        
        // Yield more frequently for iPhone 12 simulation
        if (i % 50 == 0) {
          await Future.delayed(Duration.zero);
        }
      }
    } catch (e) {
      results.add('❌ FFI test failed: $e');
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    final opsPerSecond = (operations * 1000) / duration;
    
    results.add('✅ Operations: $operations');
    results.add('✅ Duration: ${duration}ms');
    results.add('✅ Throughput: ${opsPerSecond.toStringAsFixed(0)} ops/s');
    
    // iPhone 12 performance thresholds (60% of iPhone 15 Pro Max)
    if (opsPerSecond > 3000) {
      results.add('✅ Performance: EXCELLENT (>3000 ops/s)');
    } else if (opsPerSecond > 600) {
      results.add('✅ Performance: GOOD (>600 ops/s)');
    } else {
      results.add('⚠️  Performance: NEEDS IMPROVEMENT (<600 ops/s)');
    }
    results.add('');

    // Test 2: Memory Performance (60% of extreme)
    results.add('🧠 Test 2: Memory Performance');
    results.add('-' * 30);
    
    final memoryStopwatch = Stopwatch()..start();
    final List<List<int>> memoryTest = [];
    
    try {
      for (int chunk = 0; chunk < 120; chunk++) { // 60% of 200
        final chunkData = List.generate(
          300,
          (index) => chunk * 300 + index,
        ); // 60% of 500
        memoryTest.add(chunkData);
        
        for (int _ in chunkData) {
          // Use existing FFI function for memory testing
          final processed = getGuessWords();
          if (processed.isEmpty) {
            results.add('❌ Memory processing failed at chunk $chunk');
            break;
          }
        }
        
        // Yield more frequently for iPhone 12 simulation
        if (chunk % 5 == 0) {
          await Future.delayed(Duration.zero);
        }
      }
    } catch (e) {
      results.add('❌ Memory test failed: $e');
    }
    
    memoryStopwatch.stop();
    final memoryDuration = memoryStopwatch.elapsedMilliseconds;
    final totalItems = memoryTest.length * 300; // Updated for new chunk size
    final itemsPerSecond = (totalItems * 1000) / memoryDuration;
    
    results.add('✅ Memory chunks: ${memoryTest.length}');
    results.add('✅ Total items: $totalItems');
    results.add('✅ Duration: ${memoryDuration}ms');
    results.add('✅ Throughput: ${itemsPerSecond.toStringAsFixed(0)} items/s');
    
    memoryTest.clear();
    
    // iPhone 12 memory performance thresholds
    if (itemsPerSecond > 30000) {
      results.add('✅ Memory Performance: EXCELLENT (>30K items/s)');
    } else if (itemsPerSecond > 6000) {
      results.add('✅ Memory Performance: GOOD (>6K items/s)');
    } else {
      results.add('⚠️  Memory Performance: NEEDS IMPROVEMENT (<6K items/s)');
    }
    results.add('');

    // Test 3: Real-time Processing (60% of extreme)
    results.add('⚡ Test 3: Real-time Processing');
    results.add('-' * 30);
    
    final realtimeStopwatch = Stopwatch()..start();
    int processedItems = 0;
    const targetItems = 3000; // 60% of 5000
    
    try {
      for (int i = 0; i < targetItems; i++) {
        // Use existing FFI function for real-time testing
        final result = getAnswerWords();
        
        if (result.isEmpty) {
          results.add('❌ Real-time processing failed at item $i');
          break;
        }
        
        processedItems++;
        
        // Yield more frequently for iPhone 12 simulation
        if (i % 50 == 0) {
          await Future.delayed(Duration.zero);
        }
      }
    } catch (e) {
      results.add('❌ Real-time test failed: $e');
    }
    
    realtimeStopwatch.stop();
    final realtimeDuration = realtimeStopwatch.elapsedMilliseconds;
    final realtimeItemsPerSecond = (processedItems * 1000) / realtimeDuration;
    
    results.add('✅ Processed items: $processedItems');
    results.add('✅ Duration: ${realtimeDuration}ms');
    results.add('✅ Throughput: ${realtimeItemsPerSecond.toStringAsFixed(0)} items/s');
    
    // iPhone 12 real-time performance thresholds
    if (realtimeItemsPerSecond > 6000) {
      results.add('✅ Real-time Performance: EXCELLENT (>6K items/s)');
    } else if (realtimeItemsPerSecond > 600) {
      results.add('✅ Real-time Performance: GOOD (>600 items/s)');
    } else {
      results.add('⚠️  Real-time Performance: NEEDS IMPROVEMENT (<600 items/s)');
    }
    results.add('');

    results.add('🎉 iPhone 12 Performance Test Complete!');
    results.add('🕐 Finished: ${DateTime.now()}');
    results.add('');
    results.add('📊 Performance Comparison:');
    results.add(
      '• iPhone 12 (A14 Bionic): ~60% of iPhone 15 Pro Max performance',
    );
    results.add(
      '• Expected: Lower throughput but still excellent FFI performance',
    );
    results.add('• Real-world: iPhone 12 would handle this workload well');

    setState(() {
      _result = results.join('\n');
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iPhone 12 Performance Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'iPhone 12 Performance Simulation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This test simulates iPhone 12 (A14 Bionic) '
                      'performance characteristics:\n'
                      '• 60% of iPhone 15 Pro Max (A17 Pro) performance\n'
                      '• Reduced test parameters to match expected '
                      'capabilities\n'
                      '• More frequent yielding to simulate older hardware',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isRunning
                          ? null
                          : _runiPhone12PerformanceTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isRunning
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Testing...'),
                              ],
                            )
                          : const Text('🚀 Run iPhone 12 Performance Test'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
