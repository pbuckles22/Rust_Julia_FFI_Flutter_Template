#!/bin/bash

# Extended Wordle Solver Benchmark Script
# Based on the reference implementation that achieved 99.8% success rate
# 
# This script runs multiple Flutter benchmark iterations to get statistically
# significant results for our bolt-on reference algorithm.

set -e  # Exit on any error

echo "🎯 Extended Wordle Solver Benchmark"
echo "==================================="
echo ""

# Change to the Flutter project directory
cd "$(dirname "$0")/.."

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in Flutter project directory"
    echo "   Expected to find pubspec.yaml in current directory"
    exit 1
fi

echo "📁 Working directory: $(pwd)"
echo ""

# Function to run Flutter benchmark
run_flutter_benchmark() {
    local test_name="$1"
    local description="$2"
    
    echo "🚀 Running: $description"
    echo "----------------------------------------"
    
    # Run the Flutter test
    flutter test test/game_simulation_benchmark_test.dart --plain-name "$test_name"
    
    echo ""
    echo "✅ Completed: $description"
    echo ""
}

# Function to run multiple iterations for statistical significance
run_multiple_iterations() {
    local iterations="$1"
    local test_name="$2"
    local description="$3"
    
    echo "📊 Running $iterations iterations for statistical significance"
    echo "============================================================="
    echo ""
    
    for i in $(seq 1 $iterations); do
        echo "🔄 Iteration $i/$iterations"
        run_flutter_benchmark "$test_name" "$description (Iteration $i/$iterations)"
        
        # Small delay between iterations
        sleep 1
    done
    
    echo "✅ Completed $iterations iterations"
    echo ""
}

# Main benchmark execution
echo "🎮 Starting Extended Benchmark Suite..."
echo ""

# Run single 100-game benchmark
run_flutter_benchmark "Benchmark: Simulate 100 games to test optimized performance" "100-Game Benchmark"

# Run multiple iterations for statistical significance (equivalent to 900+ games)
run_multiple_iterations 9 "Benchmark: Simulate 100 games to test optimized performance" "100-Game Benchmark"

# Run reference mode benchmark if available
if flutter test test/reference_mode_benchmark_test.dart --plain-name "Reference Mode: Simulate 100 games with reference configuration" >/dev/null 2>&1; then
    echo "🎯 Running Reference Mode Benchmark..."
    echo "====================================="
    echo ""
    
    run_flutter_benchmark "Reference Mode: Simulate 100 games with reference configuration" "Reference Mode 100-Game Benchmark"
    
    # Run multiple iterations of reference mode
    run_multiple_iterations 5 "Reference Mode: Simulate 100 games with reference configuration" "Reference Mode 100-Game Benchmark"
else
    echo "⚠️  Reference mode benchmark not available, skipping..."
    echo ""
fi

echo "🎉 Extended Benchmark Suite Complete!"
echo "====================================="
echo ""
echo "📊 Summary:"
echo "  • Ran 1x 100-game benchmark"
echo "  • Ran 9x 100-game benchmarks (900 total games for statistical significance)"
echo "  • Each benchmark tests our bolt-on reference algorithm"
echo "  • Results show success rate and average guesses vs targets"
echo ""
echo "🎯 Target Metrics:"
echo "  • Success Rate: 99.8% (reference achieved)"
echo "  • Average Guesses: 3.66 (reference achieved)"
echo "  • Response Time: <200ms"
echo ""
echo "📈 Analysis:"
echo "  • 900+ games provides statistical significance"
echo "  • Multiple iterations show consistency"
echo "  • Compare results with reference implementation"
echo ""
echo "🔧 Usage:"
echo "  ./scripts/run_extended_benchmark.sh"
echo ""
echo "📊 Reference Approach:"
echo "  The reference project uses: cargo run --bin benchmark 900"
echo "  We achieve the same statistical significance with multiple Flutter runs"
