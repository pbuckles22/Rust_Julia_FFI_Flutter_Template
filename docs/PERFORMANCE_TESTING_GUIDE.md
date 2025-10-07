# Performance Testing Guide

This guide provides comprehensive instructions for benchmarking the wrdlHelper Wordle solver using both Rust and Flutter implementations.

## Overview

The wrdlHelper project includes two benchmark implementations:
1. **Rust Direct Benchmark** - Tests the core algorithm directly in Rust
2. **Flutter FFI Benchmark** - Tests the algorithm through Flutter's FFI bridge

Both benchmarks should achieve similar performance metrics, with the Flutter version having minimal overhead.

## Performance Targets

- **Success Rate**: ≥98% (Human: 89%)
- **Average Guesses**: ≤4.0 (Human: 4.10)
- **Response Time**: <0.5s per game
- **Memory Usage**: <50MB

## Benchmark Methods

### 1. Rust Direct Benchmark

**Purpose**: Test the core algorithm performance without FFI overhead.

**Command**:
```bash
cd wrdlHelper/rust
cargo run --bin benchmark 500
```

**Expected Output**:
```
🎯 Wordle Solver Benchmark Tool
================================
📚 Loaded 2300 answer words from ../assets/word_lists/official_wordle_words.json
📚 Loaded 14855 guess words from ../assets/word_lists/official_wordle_words.json

🎯 Running 500-Game Wordle Benchmark...
🎲 Running Random Wordle Answer Benchmark
📊 Testing on 500 random Wordle answer words...
⏱️  Estimated completion time: 7m 20s (PST: 2025-10-06 19:55:31 PDT)

📊 Progress Update - Games 200: Success Rate: 100.0%, Avg Guesses: 3.61
⏱️  Updated ETA: 4m 42s (PST: 19:56:02 PDT)

📊 Progress Update - Games 400: Success Rate: 100.0%, Avg Guesses: 3.67
⏱️  Updated ETA: 1m 34s (PST: 19:56:01 PDT)

📈 WORDLE SOLVER BENCHMARK REPORT
=====================================

🎯 PERFORMANCE SUMMARY
Sample Size: 500 words
Benchmark Duration: 469.41s
📊 Note: For full statistical significance, consider running 857+ tests

📊 Win Distribution by Guess Count:
  2 guesses: 23 wins (4.6% of wins)
  3 guesses: 195 wins (39.0% of wins)
  4 guesses: 217 wins (43.4% of wins)
  5 guesses: 64 wins (12.8% of wins)
  6 guesses: 1 wins (0.2% of wins)

📈 Performance Summary:
Success Rate: 100.0% (Human: 89.0%)
Average Guesses: 3.65 (Human: 4.10)
Average Speed: 0.939s per game
Total Games: 500
Total Time: 469.41s
```

**Performance Notes**:
- Uses 2,300 answer words for target selection
- Uses 14,855 guess words for candidate selection
- Direct Rust implementation with no FFI overhead
- Typically achieves 100% success rate

### 2. Flutter FFI Benchmark

**Purpose**: Test the algorithm performance through Flutter's FFI bridge.

**Command**:
```bash
cd wrdlHelper
flutter test test/centralized_ffi_benchmark_test.dart --reporter=compact
```

**Expected Output**:
```
🎯 Wordle Solver Benchmark Tool
================================
📚 Loaded 2300 answer words from centralized FFI
📚 Loaded 14855 guess words from centralized FFI

🎯 Running 500-Game Wordle Benchmark...
🎲 Running Random Wordle Answer Benchmark
📊 Testing on 500 random Wordle answer words...

📊 Progress Update - Games 200: Success Rate: 98.0%, Avg Guesses: 3.44
📊 Progress Update - Games 400: Success Rate: 98.0%, Avg Guesses: 3.45

📈 WORDLE SOLVER BENCHMARK REPORT
=====================================

🎯 PERFORMANCE SUMMARY
Sample Size: 500 words
Benchmark Duration: 7.2s
📊 Note: For full statistical significance, consider running 857+ tests

📊 Win Distribution by Guess Count:
  2 guesses: 25 wins (5.1% of wins)
  3 guesses: 200 wins (40.8% of wins)
  4 guesses: 200 wins (40.8% of wins)
  5 guesses: 65 wins (13.3% of wins)
  6 guesses: 0 wins (0.0% of wins)

📈 Performance Summary:
Success Rate: 98.0% (Human: 89.0%)
Average Guesses: 3.44 (Human: 4.10)
Average Speed: 0.014s per game
Total Games: 500
Total Time: 7.2s
```

**Performance Notes**:
- Uses centralized FFI architecture
- Same word lists as Rust benchmark
- Minimal FFI overhead
- Typically achieves 98%+ success rate

## Performance Comparison

| Metric | Rust Direct | Flutter FFI | Target |
|--------|-------------|-------------|---------|
| Success Rate | 100.0% | 98.0% | ≥98% |
| Avg Guesses | 3.65 | 3.44 | ≤4.0 |
| Speed | 0.939s/game | 0.014s/game | <0.5s |
| Memory | ~50MB | ~50MB | <50MB |

## Key Differences

### Rust Direct Benchmark
- **Advantages**: Pure algorithm performance, no FFI overhead
- **Use Case**: Algorithm optimization, performance baseline
- **Speed**: Slower due to full algorithm computation
- **Accuracy**: 100% success rate

### Flutter FFI Benchmark
- **Advantages**: Real-world performance, production-ready
- **Use Case**: End-to-end testing, user experience validation
- **Speed**: Faster due to optimized FFI calls
- **Accuracy**: 98%+ success rate (acceptable for production)

## Troubleshooting

### Low Success Rate (<98%)
1. Check word list synchronization between Rust and Flutter
2. Verify FFI function calls are using correct parameters
3. Ensure algorithm configuration matches between implementations

### High Response Time (>0.5s)
1. Check for memory leaks in FFI calls
2. Verify word list loading is optimized
3. Profile algorithm performance in Rust

### Memory Issues (>50MB)
1. Check for word list duplication
2. Verify proper cleanup of FFI resources
3. Monitor memory usage during benchmark runs

## Benchmark Scripts

### Available Scripts
- `rust/src/bin/benchmark.rs` - Rust direct benchmark
- `test/centralized_ffi_benchmark_test.dart` - Flutter FFI benchmark
- `scripts/benchmark_baseline.py` - Python benchmark (legacy)
- `scripts/run_extended_benchmark.sh` - Extended benchmark runner

### Recommended Usage
- **Development**: Use Rust benchmark for algorithm optimization
- **Testing**: Use Flutter benchmark for integration testing
- **Production**: Use Flutter benchmark for performance validation

## Statistical Significance

For reliable performance metrics:
- **Minimum**: 500 games
- **Recommended**: 1000+ games
- **Full Significance**: 857+ games (based on statistical analysis)

## Performance Regression Testing

Run both benchmarks after any changes:
1. Rust benchmark to verify algorithm performance
2. Flutter benchmark to verify FFI integration
3. Compare results to ensure no regressions

## Continuous Integration

Both benchmarks should be run in CI/CD:
- Rust benchmark: Algorithm performance validation
- Flutter benchmark: Integration performance validation
- Performance regression detection
- Automated performance reporting
