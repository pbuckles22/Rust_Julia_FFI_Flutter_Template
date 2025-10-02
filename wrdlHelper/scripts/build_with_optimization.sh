#!/bin/bash

echo "🚀 Building wrdlHelper with optimal guess pre-computation..."

# Create assets directory if it doesn't exist
mkdir -p assets

# Pre-compute optimal guesses
echo "📊 Pre-computing optimal guesses..."
cd scripts
rustc precompute_optimal_guesses.rs --extern serde_json -o precompute_optimal_guesses
./precompute_optimal_guesses
cd ..

# Build Rust library
echo "🔨 Building Rust library..."
cd rust
cargo build --release
cd ..

# Generate FFI bindings
echo "🔗 Generating FFI bindings..."
flutter_rust_bridge_codegen generate

# Build Flutter app
echo "📱 Building Flutter app..."
flutter build

echo "✅ Build complete with optimal guess pre-computation!"
echo "🎯 Optimal guesses saved to: assets/optimal_guesses.json"
