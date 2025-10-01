#!/bin/bash

# Comprehensive Build Script for Flutter-Rust-Julia FFI Project
# 
# This script builds the entire project for Apple-focused platforms:
# - Flutter mobile apps (iOS, Android for future use)
# - Flutter desktop apps (macOS)
# - Rust library for Apple platforms
# - Julia compiled system image
#
# Usage: ./build_all.sh [options]
# Options:
#   --platform PLATFORM    Build for specific platform (android, ios, macos)
#   --release              Build in release mode
#   --debug                Build in debug mode (default)
#   --clean                Clean build artifacts before building
#   --rust-only            Build only Rust components
#   --flutter-only         Build only Flutter components
#   --julia-only           Build only Julia components
#   --help                 Show this help message

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
PLATFORM=""
RELEASE=false
DEBUG=true
CLEAN=false
RUST_ONLY=false
FLUTTER_ONLY=false
JULIA_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --release)
            RELEASE=true
            DEBUG=false
            shift
            ;;
        --debug)
            DEBUG=true
            RELEASE=false
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --rust-only)
            RUST_ONLY=true
            shift
            ;;
        --flutter-only)
            FLUTTER_ONLY=true
            shift
            ;;
        --julia-only)
            JULIA_ONLY=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --platform PLATFORM    Build for specific platform (android, ios, macos)"
            echo "  --release              Build in release mode"
            echo "  --debug                Build in debug mode (default)"
            echo "  --clean                Clean build artifacts before building"
            echo "  --rust-only            Build only Rust components"
            echo "  --flutter-only         Build only Flutter components"
            echo "  --julia-only           Build only Julia components"
            echo "  --help                 Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking build prerequisites..."
    
    local missing_deps=()
    
    if [ "$RUST_ONLY" = false ] && [ "$JULIA_ONLY" = false ]; then
        if ! command_exists flutter; then
            missing_deps+=("flutter")
        fi
    fi
    
    if [ "$FLUTTER_ONLY" = false ] && [ "$JULIA_ONLY" = false ]; then
        if ! command_exists cargo; then
            missing_deps+=("rust/cargo")
        fi
    fi
    
    if [ "$FLUTTER_ONLY" = false ] && [ "$RUST_ONLY" = false ]; then
        if ! command_exists julia; then
            missing_deps+=("julia")
        fi
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install the missing dependencies and try again"
        exit 1
    fi
    
    log_success "All build prerequisites satisfied"
}

# Function to clean build artifacts
clean_build_artifacts() {
    if [ "$CLEAN" = true ]; then
        log_info "Cleaning build artifacts..."
        
        # Clean Flutter build artifacts
        if [ -d "build" ]; then
            rm -rf build
            log_info "Cleaned Flutter build directory"
        fi
        
        # Clean Rust build artifacts
        if [ -d "rust/target" ]; then
            cd rust
            cargo clean
            cd ..
            log_info "Cleaned Rust build artifacts"
        fi
        
        # Clean Julia build artifacts
        if [ -d "julia/compiled" ]; then
            rm -rf julia/compiled
            log_info "Cleaned Julia build artifacts"
        fi
        
        log_success "Build artifacts cleaned"
    fi
}

# Function to build Rust components
build_rust() {
    log_info "Building Rust components..."
    
    if [ ! -f "rust/Cargo.toml" ]; then
        log_error "rust/Cargo.toml not found"
        exit 1
    fi
    
    cd rust
    
    # Build for different targets
    local build_mode=""
    if [ "$RELEASE" = true ]; then
        build_mode="--release"
    fi
    
    # Build for host platform
    log_info "Building Rust library for host platform..."
    if cargo build $build_mode; then
        log_success "Rust library built successfully"
    else
        log_error "Failed to build Rust library"
        exit 1
    fi
    
    # Build for additional targets if needed
    if [ "$PLATFORM" = "android" ]; then
        log_info "Building Rust library for Android..."
        if cargo build $build_mode --target aarch64-linux-android; then
            log_success "Rust library built for Android"
        else
            log_warning "Failed to build Rust library for Android"
        fi
    fi
    
    if [ "$PLATFORM" = "ios" ]; then
        log_info "Building Rust library for iOS..."
        if cargo build $build_mode --target aarch64-apple-ios; then
            log_success "Rust library built for iOS"
        else
            log_warning "Failed to build Rust library for iOS"
        fi
    fi
    
    cd ..
    log_success "Rust components built successfully"
}

# Function to build Julia components
build_julia() {
    log_info "Building Julia components..."
    
    if [ ! -f "julia/Project.toml" ]; then
        log_error "julia/Project.toml not found"
        exit 1
    fi
    
    cd julia
    
    # Install dependencies
    log_info "Installing Julia dependencies..."
    julia --project=. -e "using Pkg; Pkg.instantiate()"
    
    # Create system image for better performance
    log_info "Creating Julia system image..."
    if julia --project=. -e "using PackageCompiler; create_sysimage(:JuliaLibMyWorkingFfiApp, sysimage_path=\"compiled/sysimage.so\")"; then
        log_success "Julia system image created"
    else
        log_warning "Failed to create Julia system image"
    fi
    
    cd ..
    log_success "Julia components built successfully"
}

# Function to build Flutter components
build_flutter() {
    log_info "Building Flutter components..."
    
    if [ ! -f "pubspec.yaml" ]; then
        log_error "pubspec.yaml not found"
        exit 1
    fi
    
    # Get Flutter dependencies
    log_info "Getting Flutter dependencies..."
    flutter pub get
    
    # Build for specific platform or all platforms
    if [ -n "$PLATFORM" ]; then
        build_flutter_platform "$PLATFORM"
    else
        build_flutter_all_platforms
    fi
    
    log_success "Flutter components built successfully"
}

# Function to build Flutter for specific platform
build_flutter_platform() {
    local platform="$1"
    local build_mode=""
    
    if [ "$RELEASE" = true ]; then
        build_mode="--release"
    else
        build_mode="--debug"
    fi
    
    case "$platform" in
        "android")
            log_info "Building Flutter app for Android..."
            if flutter build apk $build_mode; then
                log_success "Android APK built successfully"
            else
                log_error "Failed to build Android APK"
                exit 1
            fi
            ;;
        "ios")
            log_info "Building Flutter app for iOS..."
            if flutter build ios $build_mode; then
                log_success "iOS app built successfully"
            else
                log_error "Failed to build iOS app"
                exit 1
            fi
            ;;
        "macos")
            log_info "Building Flutter app for macOS..."
            if flutter build macos $build_mode; then
                log_success "macOS app built successfully"
            else
                log_error "Failed to build macOS app"
                exit 1
            fi
            ;;
        *)
            log_error "Unknown platform: $platform. Supported platforms: android, ios, macos"
            exit 1
            ;;
    esac
}

# Function to build Flutter for all platforms
build_flutter_all_platforms() {
    log_info "Building Flutter app for all platforms..."
    
    local build_mode=""
    if [ "$RELEASE" = true ]; then
        build_mode="--release"
    else
        build_mode="--debug"
    fi
    
    # Build for Android
    if flutter config --list | grep -q "enable-android: true"; then
        log_info "Building for Android..."
        if flutter build apk $build_mode; then
            log_success "Android APK built successfully"
        else
            log_warning "Failed to build Android APK"
        fi
    fi
    
    # Build for iOS
    if flutter config --list | grep -q "enable-ios: true"; then
        log_info "Building for iOS..."
        if flutter build ios $build_mode; then
            log_success "iOS app built successfully"
        else
            log_warning "Failed to build iOS app"
        fi
    fi
    
    # Build for macOS
    if flutter config --list | grep -q "enable-macos-desktop: true"; then
        log_info "Building for macOS..."
        if flutter build macos $build_mode; then
            log_success "macOS app built successfully"
        else
            log_warning "Failed to build macOS app"
        fi
    fi
}

# Function to print build summary
print_build_summary() {
    echo
    echo "=========================================="
    echo "           BUILD SUMMARY"
    echo "=========================================="
    echo "Build Mode: $([ "$RELEASE" = true ] && echo "Release" || echo "Debug")"
    echo "Platform: $([ -n "$PLATFORM" ] && echo "$PLATFORM" || echo "All platforms")"
    echo "=========================================="
    
    # List built artifacts
    log_info "Built artifacts:"
    
    if [ "$RUST_ONLY" = false ] && [ "$JULIA_ONLY" = false ]; then
        if [ -d "build" ]; then
            find build -name "*.apk" -o -name "*.app" -o -name "*.exe" -o -name "*.dmg" -o -name "*.deb" | while read -r artifact; do
                echo "  - $artifact"
            done
        fi
    fi
    
    if [ "$FLUTTER_ONLY" = false ] && [ "$JULIA_ONLY" = false ]; then
        if [ -d "rust/target" ]; then
            find rust/target -name "*.so" -o -name "*.dylib" -o -name "*.dll" -o -name "*.a" | while read -r artifact; do
                echo "  - $artifact"
            done
        fi
    fi
    
    if [ "$FLUTTER_ONLY" = false ] && [ "$RUST_ONLY" = false ]; then
        if [ -d "julia/compiled" ]; then
            find julia/compiled -name "*.so" -o -name "*.dylib" -o -name "*.dll" | while read -r artifact; do
                echo "  - $artifact"
            done
        fi
    fi
    
    log_success "Build completed successfully! 🎉"
}

# Main execution
main() {
    echo "=========================================="
    echo "    Flutter-Rust-Julia FFI Build Suite"
    echo "=========================================="
    echo
    
    # Check prerequisites
    check_prerequisites
    
    # Clean build artifacts if requested
    clean_build_artifacts
    
    # Build components based on options
    if [ "$RUST_ONLY" = true ]; then
        build_rust
    elif [ "$FLUTTER_ONLY" = true ]; then
        build_flutter
    elif [ "$JULIA_ONLY" = true ]; then
        build_julia
    else
        # Build all components
        build_rust
        build_julia
        build_flutter
    fi
    
    # Print build summary
    print_build_summary
}

# Run main function
main "$@"
