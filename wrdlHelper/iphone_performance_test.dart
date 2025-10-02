#!/usr/bin/env dart
// iPhone Performance Test - Real Device Testing
// This will test actual FFI performance on your physical iPhone

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_working_ffi_app/src/rust/frb_generated.dart';
import 'package:my_working_ffi_app/src/rust/api/simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(IPhonePerformanceTestApp());
}

class IPhonePerformanceTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iPhone Performance Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PerformanceTestScreen(),
    );
  }
}

class PerformanceTestScreen extends StatefulWidget {
  @override
  _PerformanceTestScreenState createState() => _PerformanceTestScreenState();
}

class _PerformanceTestScreenState extends State<PerformanceTestScreen> {
  List<String> testResults = [];
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iPhone Performance Test'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: testResults.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      testResults[index],
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isRunning ? null : runPerformanceTests,
              child: Text(isRunning ? 'Running Tests...' : 'Run Performance Tests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> runPerformanceTests() async {
    setState(() {
      isRunning = true;
      testResults.clear();
    });

    addResult('🚀 iPhone Performance Test - Julia-Rust Cross-Integration');
    addResult('=' * 60);
    addResult('📱 Device: iPhone 15 Pro Max (Physical Device)');
    addResult('🕐 Started: ${DateTime.now()}');
    addResult('');

    // Test 1: Basic FFI Performance
    await testBasicFFIPerformance();
    
    // Test 2: Memory Performance
    await testMemoryPerformance();
    
    // Test 3: Real-time Processing
    await testRealTimeProcessing();
    
    // Test 4: Large Data Processing
    await testLargeDataProcessing();
    
    // Test 5: Stress Test
    await testStressTest();
    
    addResult('');
    addResult('🎉 iPhone Performance Test Complete!');
    addResult('🕐 Finished: ${DateTime.now()}');

    setState(() {
      isRunning = false;
    });
  }

  void addResult(String result) {
    setState(() {
      testResults.add(result);
    });
  }

  Future<void> testBasicFFIPerformance() async {
    addResult('📊 Test 1: Basic FFI Performance');
    addResult('-' * 40);
    
    final stopwatch = Stopwatch()..start();
    int operations = 0;
    const maxOperations = 10000;
    
    try {
      // Test actual RustLib calls
      for (int i = 0; i < maxOperations; i++) {
        final result = addNumbers(a: i, b: 1);
        if (result != i + 1) {
          addResult('❌ FFI operation failed at iteration $i');
          return;
        }
        operations++;
      }
    } catch (e) {
      addResult('❌ FFI test failed: $e');
      return;
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    final opsPerSecond = (operations * 1000) / duration;
    
    addResult('✅ Operations: $operations');
    addResult('✅ Duration: ${duration}ms');
    addResult('✅ Throughput: ${opsPerSecond.toStringAsFixed(0)} ops/s');
    
    if (opsPerSecond > 1000) {
      addResult('✅ Performance: EXCELLENT (>1000 ops/s)');
    } else if (opsPerSecond > 100) {
      addResult('✅ Performance: GOOD (>100 ops/s)');
    } else {
      addResult('⚠️  Performance: NEEDS IMPROVEMENT (<100 ops/s)');
    }
    addResult('');
  }

  Future<void> testMemoryPerformance() async {
    addResult('🧠 Test 2: Memory Performance');
    addResult('-' * 40);
    
    final stopwatch = Stopwatch()..start();
    final List<List<int>> memoryTest = [];
    
    try {
      // Allocate memory in chunks
      for (int chunk = 0; chunk < 100; chunk++) {
        final chunkData = List.generate(1000, (index) => chunk * 1000 + index);
        memoryTest.add(chunkData);
        
        // Process through Rust FFI
        for (int value in chunkData) {
          final processed = addNumbers(a: value, b: 0);
          if (processed != value) {
            addResult('❌ Memory processing failed at chunk $chunk');
            return;
          }
        }
      }
    } catch (e) {
      addResult('❌ Memory test failed: $e');
      return;
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    final totalItems = memoryTest.length * 1000;
    final itemsPerSecond = (totalItems * 1000) / duration;
    
    addResult('✅ Memory chunks: ${memoryTest.length}');
    addResult('✅ Total items: $totalItems');
    addResult('✅ Duration: ${duration}ms');
    addResult('✅ Throughput: ${itemsPerSecond.toStringAsFixed(0)} items/s');
    
    // Clean up memory
    memoryTest.clear();
    
    if (itemsPerSecond > 10000) {
      addResult('✅ Memory Performance: EXCELLENT (>10K items/s)');
    } else if (itemsPerSecond > 1000) {
      addResult('✅ Memory Performance: GOOD (>1K items/s)');
    } else {
      addResult('⚠️  Memory Performance: NEEDS IMPROVEMENT (<1K items/s)');
    }
    addResult('');
  }

  Future<void> testRealTimeProcessing() async {
    addResult('⚡ Test 3: Real-time Processing');
    addResult('-' * 40);
    
    final stopwatch = Stopwatch()..start();
    int processedItems = 0;
    const targetItems = 5000;
    
    try {
      // Simulate real-time data processing
      for (int i = 0; i < targetItems; i++) {
        // Process through Rust FFI
        final result = multiplyFloats(a: i * 1.5, b: 2.0);
        final expected = (i * 1.5) * 2.0;
        
        // Validate processing
        if ((result - expected).abs() > 0.001) {
          addResult('❌ Real-time processing failed at item $i');
          return;
        }
        
        processedItems++;
        
        // Simulate real-time delay (1ms)
        if (i % 100 == 0) {
          await Future.delayed(Duration(milliseconds: 1));
        }
      }
    } catch (e) {
      addResult('❌ Real-time test failed: $e');
      return;
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    final itemsPerSecond = (processedItems * 1000) / duration;
    
    addResult('✅ Processed items: $processedItems');
    addResult('✅ Duration: ${duration}ms');
    addResult('✅ Throughput: ${itemsPerSecond.toStringAsFixed(0)} items/s');
    
    if (itemsPerSecond > 1000) {
      addResult('✅ Real-time Performance: EXCELLENT (>1K items/s)');
    } else if (itemsPerSecond > 100) {
      addResult('✅ Real-time Performance: GOOD (>100 items/s)');
    } else {
      addResult('⚠️  Real-time Performance: NEEDS IMPROVEMENT (<100 items/s)');
    }
    addResult('');
  }

  Future<void> testLargeDataProcessing() async {
    addResult('📈 Test 4: Large Data Processing');
    addResult('-' * 40);
    
    final stopwatch = Stopwatch()..start();
    const dataSize = 50000;
    final largeData = List.generate(dataSize, (index) => index);
    
    try {
      // Process large dataset
      // int processedCount = 0;
      for (int i = 0; i < largeData.length; i += 100) {
        final chunkEnd = (i + 100).clamp(0, largeData.length);
        final chunk = largeData.sublist(i, chunkEnd);
        
        // Process chunk through Rust FFI
        for (int value in chunk) {
          final processed = multiplyFloats(a: value * 1.5, b: 1.0);
          final expected = (value * 1.5) * 1.0;
          
          if ((processed - expected).abs() > 0.001) {
            addResult('❌ Large data processing failed at index $i');
            return;
          }
          processedCount++;
        }
      }
    } catch (e) {
      addResult('❌ Large data test failed: $e');
      return;
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    final itemsPerSecond = (dataSize * 1000) / duration;
    
    addResult('✅ Data size: $dataSize items');
    addResult('✅ Processed: $dataSize items');
    addResult('✅ Duration: ${duration}ms');
    addResult('✅ Throughput: ${itemsPerSecond.toStringAsFixed(0)} items/s');
    
    if (itemsPerSecond > 5000) {
      addResult('✅ Large Data Performance: EXCELLENT (>5K items/s)');
    } else if (itemsPerSecond > 1000) {
      addResult('✅ Large Data Performance: GOOD (>1K items/s)');
    } else {
      addResult('⚠️  Large Data Performance: NEEDS IMPROVEMENT (<1K items/s)');
    }
    addResult('');
  }

  Future<void> testStressTest() async {
    addResult('🔥 Test 5: Stress Test');
    addResult('-' * 40);
    
    final stopwatch = Stopwatch()..start();
    int totalOperations = 0;
    const stressDuration = 5000; // 5 seconds
    
    try {
      while (stopwatch.elapsedMilliseconds < stressDuration) {
        // Simulate various operations through Rust FFI
        final operationType = Random().nextInt(4);
        
        switch (operationType) {
          case 0:
            // Basic arithmetic
            final a = Random().nextInt(1000);
            final b = Random().nextInt(1000);
                final result = addNumbers(a: a, b: b);
            if (result != a + b) {
              addResult('❌ Stress test failed: arithmetic');
              return;
            }
            break;
            
          case 1:
            // Float operations
            final value = Random().nextDouble() * 100;
                final result = multiplyFloats(a: value, b: 2.0);
            final expected = value * 2.0;
            if ((result - expected).abs() > 0.001) {
              addResult('❌ Stress test failed: float operations');
              return;
            }
            break;
            
          case 2:
            // String operations
            final str = 'test_${Random().nextInt(1000)}';
                final result = greet(name: str);
            if (!result.contains(str)) {
              addResult('❌ Stress test failed: string operations');
              return;
            }
            break;
            
          case 3:
            // Complex computation
            final value = Random().nextDouble() * 100;
                final result = multiplyFloats(a: value, b: value / 2.0);
            final expected = value * (value / 2.0);
            if ((result - expected).abs() > 0.001) {
              addResult('❌ Stress test failed: complex computation');
              return;
            }
            break;
        }
        
        totalOperations++;
      }
    } catch (e) {
      addResult('❌ Stress test failed: $e');
      return;
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    final opsPerSecond = (totalOperations * 1000) / duration;
    
    addResult('✅ Total operations: $totalOperations');
    addResult('✅ Duration: ${duration}ms');
    addResult('✅ Throughput: ${opsPerSecond.toStringAsFixed(0)} ops/s');
    
    if (opsPerSecond > 1000) {
      addResult('✅ Stress Test Performance: EXCELLENT (>1K ops/s)');
    } else if (opsPerSecond > 100) {
      addResult('✅ Stress Test Performance: GOOD (>100 ops/s)');
    } else {
      addResult('⚠️  Stress Test Performance: NEEDS IMPROVEMENT (<100 ops/s)');
    }
    addResult('');
  }
}
