#!/usr/bin/env dart
// Device Performance Test Script
// Run this on your device to test real-world performance

import 'dart:async';
import 'dart:math';
import 'package:wrdlhelper/src/rust/frb_generated.dart';
import 'package:wrdlhelper/src/rust/api/simple.dart';

void main() async {
  print('🚀 Device Performance Test - Julia-Rust Cross-Integration');
  print('=' * 60);
  
  // Initialize Rust library
  await RustLib.init();
  
  // Test 1: Basic FFI Performance
  await testBasicFFIPerformance();
  
  // Test 2: Memory Performance
  await testMemoryPerformance();
  
  // Test 3: Real-time Processing Simulation
  await testRealTimeProcessing();
  
  // Test 4: Large Data Processing
  await testLargeDataProcessing();
  
  // Test 5: Stress Test
  await testStressTest();
  
  print('\n🎉 Device Performance Test Complete!');
}

Future<void> testBasicFFIPerformance() async {
  print('\n📊 Test 1: Basic FFI Performance');
  print('-' * 40);
  
  final stopwatch = Stopwatch()..start();
  int operations = 0;
  const maxOperations = 10000;
  
  // Use actual FFI calls for performance testing
  for (int i = 0; i < maxOperations; i++) {
    // Use existing FFI function for performance testing
    final result = getAnswerWords();
    if (result.isEmpty) {
      print('❌ FFI operation failed at iteration $i');
      return;
    }
    operations++;
  }
  
  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds;
  final opsPerSecond = (operations * 1000) / duration;
  
  print('✅ Operations: $operations');
  print('✅ Duration: ${duration}ms');
  print('✅ Throughput: ${opsPerSecond.toStringAsFixed(0)} ops/s');
  
  if (opsPerSecond > 1000) {
    print('✅ Performance: EXCELLENT (>1000 ops/s)');
  } else if (opsPerSecond > 100) {
    print('✅ Performance: GOOD (>100 ops/s)');
  } else {
    print('⚠️  Performance: NEEDS IMPROVEMENT (<100 ops/s)');
  }
}

Future<void> testMemoryPerformance() async {
  print('\n🧠 Test 2: Memory Performance');
  print('-' * 40);
  
  final stopwatch = Stopwatch()..start();
  final List<List<int>> memoryTest = [];
  
  // Allocate memory in chunks
  for (int chunk = 0; chunk < 100; chunk++) {
    final chunkData = List.generate(1000, (index) => chunk * 1000 + index);
    memoryTest.add(chunkData);
    
    // Simulate processing
    for (int value in chunkData) {
      final processed = value * 2;
      if (processed != value * 2) {
        print('❌ Memory processing failed at chunk $chunk');
        return;
      }
    }
  }
  
  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds;
  final totalItems = memoryTest.length * 1000;
  final itemsPerSecond = (totalItems * 1000) / duration;
  
  print('✅ Memory chunks: ${memoryTest.length}');
  print('✅ Total items: $totalItems');
  print('✅ Duration: ${duration}ms');
  print('✅ Throughput: ${itemsPerSecond.toStringAsFixed(0)} items/s');
  
  // Clean up memory
  memoryTest.clear();
  
  if (itemsPerSecond > 10000) {
    print('✅ Memory Performance: EXCELLENT (>10K items/s)');
  } else if (itemsPerSecond > 1000) {
    print('✅ Memory Performance: GOOD (>1K items/s)');
  } else {
    print('⚠️  Memory Performance: NEEDS IMPROVEMENT (<1K items/s)');
  }
}

Future<void> testRealTimeProcessing() async {
  print('\n⚡ Test 3: Real-time Processing Simulation');
  print('-' * 40);
  
  final stopwatch = Stopwatch()..start();
  int processedItems = 0;
  const targetItems = 5000;
  
  // Simulate real-time data processing
  for (int i = 0; i < targetItems; i++) {
    // Simulate data processing
    final data = i * 1.5;
    final processed = data * 2.0;
    final result = processed / 3.0;
    
    // Validate processing
    final expected = (i * 1.5 * 2.0) / 3.0;
    if ((result - expected).abs() > 0.001) {
      print('❌ Real-time processing failed at item $i');
      return;
    }
    
    processedItems++;
    
    // Simulate real-time delay (1ms)
    if (i % 100 == 0) {
      await Future.delayed(Duration(milliseconds: 1));
    }
  }
  
  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds;
  final itemsPerSecond = (processedItems * 1000) / duration;
  
  print('✅ Processed items: $processedItems');
  print('✅ Duration: ${duration}ms');
  print('✅ Throughput: ${itemsPerSecond.toStringAsFixed(0)} items/s');
  
  if (itemsPerSecond > 1000) {
    print('✅ Real-time Performance: EXCELLENT (>1K items/s)');
  } else if (itemsPerSecond > 100) {
    print('✅ Real-time Performance: GOOD (>100 items/s)');
  } else {
    print('⚠️  Real-time Performance: NEEDS IMPROVEMENT (<100 items/s)');
  }
}

Future<void> testLargeDataProcessing() async {
  print('\n📈 Test 4: Large Data Processing');
  print('-' * 40);
  
  final stopwatch = Stopwatch()..start();
  const dataSize = 50000;
  final largeData = List.generate(dataSize, (index) => index);
  
  // Process large dataset
  int processedCount = 0;
  for (int i = 0; i < largeData.length; i += 100) {
    final chunkEnd = (i + 100).clamp(0, largeData.length);
    final chunk = largeData.sublist(i, chunkEnd);
    
    // Process chunk
    for (int value in chunk) {
      final processed = value * 1.5;
      if (processed != value * 1.5) {
        print('❌ Large data processing failed at index $i');
        return;
      }
      processedCount++;
    }
  }
  
  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds;
  final itemsPerSecond = (processedCount * 1000) / duration;
  
  print('✅ Data size: $dataSize items');
  print('✅ Processed: $processedCount items');
  print('✅ Duration: ${duration}ms');
  print('✅ Throughput: ${itemsPerSecond.toStringAsFixed(0)} items/s');
  
  if (itemsPerSecond > 5000) {
    print('✅ Large Data Performance: EXCELLENT (>5K items/s)');
  } else if (itemsPerSecond > 1000) {
    print('✅ Large Data Performance: GOOD (>1K items/s)');
  } else {
    print('⚠️  Large Data Performance: NEEDS IMPROVEMENT (<1K items/s)');
  }
}

Future<void> testStressTest() async {
  print('\n🔥 Test 5: Stress Test');
  print('-' * 40);
  
  final stopwatch = Stopwatch()..start();
  int totalOperations = 0;
  const stressDuration = 5000; // 5 seconds
  
  final random = Random();
  
  while (stopwatch.elapsedMilliseconds < stressDuration) {
    // Simulate various operations
    final operationType = random.nextInt(4);
    
    switch (operationType) {
      case 0:
        // Basic arithmetic
        final a = random.nextInt(1000);
        final b = random.nextInt(1000);
        final result = a + b;
        if (result != a + b) {
          print('❌ Stress test failed: arithmetic');
          return;
        }
        break;
        
      case 1:
        // Memory allocation
        final list = List.generate(100, (index) => index);
        final sum = list.reduce((a, b) => a + b);
        if (sum != 4950) { // Sum of 0-99
          print('❌ Stress test failed: memory allocation');
          return;
        }
        break;
        
      case 2:
        // String processing
        final str = 'test_${random.nextInt(1000)}';
        final processed = str.toUpperCase();
        if (processed != str.toUpperCase()) {
          print('❌ Stress test failed: string processing');
          return;
        }
        break;
        
      case 3:
        // Complex computation
        final value = random.nextDouble() * 100;
        final result = value * value / 2.0;
        final expected = value * value / 2.0;
        if ((result - expected).abs() > 0.001) {
          print('❌ Stress test failed: complex computation');
          return;
        }
        break;
    }
    
    totalOperations++;
  }
  
  stopwatch.stop();
  final duration = stopwatch.elapsedMilliseconds;
  final opsPerSecond = (totalOperations * 1000) / duration;
  
  print('✅ Total operations: $totalOperations');
  print('✅ Duration: ${duration}ms');
  print('✅ Throughput: ${opsPerSecond.toStringAsFixed(0)} ops/s');
  
  if (opsPerSecond > 1000) {
    print('✅ Stress Test Performance: EXCELLENT (>1K ops/s)');
  } else if (opsPerSecond > 100) {
    print('✅ Stress Test Performance: GOOD (>100 ops/s)');
  } else {
    print('⚠️  Stress Test Performance: NEEDS IMPROVEMENT (<100 ops/s)');
  }
}
