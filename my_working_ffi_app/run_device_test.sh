#!/bin/bash
# Device Performance Test Runner
# Run this script to test performance on your device

echo "🚀 Device Performance Test Runner"
echo "================================="

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Check if device is connected
echo "📱 Checking for connected devices..."
flutter devices

echo ""
echo "🔧 Running device performance test..."
echo "This will test:"
echo "  - Basic FFI Performance"
echo "  - Memory Performance" 
echo "  - Real-time Processing"
echo "  - Large Data Processing"
echo "  - Stress Test"
echo ""

# Run the performance test
dart run device_performance_test.dart

echo ""
echo "📊 Performance Test Complete!"
echo "Compare these results with the Julia-Rust performance:"
echo "  - Julia-Rust: 36M+ items/s (shared memory)"
echo "  - Julia-Rust: 202K+ items/s (large data)"
echo "  - Julia-Rust: 4.2M+ round trips/s (bidirectional)"
echo "  - Julia-Rust: 6.3M+ ops/s (scientific pipeline)"
echo "  - Julia-Rust: 19M+ ops/s (matrix operations)"
echo ""
echo "🎯 Next: Integrate actual RustLib calls for real performance testing!"
