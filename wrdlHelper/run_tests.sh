#!/bin/bash

# Comprehensive Test Runner for Flutter-Rust-Julia FFI Project
# 
# This script runs all tests across the Apple-focused project, including:
# - Flutter/Dart unit and integration tests
# - Rust unit and integration tests  
# - Julia unit and performance tests
# - Apple platform compatibility tests
#
# Usage: ./run_tests.sh [options]
# Options:
#   --flutter-only    Run only Flutter tests
#   --rust-only       Run only Rust tests
#   --julia-only      Run only Julia tests
#   --performance     Include performance benchmarks
#   --coverage        Generate test coverage reports
#   --verbose         Enable verbose output
#   --help            Show this help message

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
FLUTTER_ONLY=false
RUST_ONLY=false
JULIA_ONLY=false
PERFORMANCE=false
COVERAGE=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --flutter-only)
            FLUTTER_ONLY=true
            shift
            ;;
        --rust-only)
            RUST_ONLY=true
            shift
            ;;
        --julia-only)
            JULIA_ONLY=true
            shift
            ;;
        --performance)
            PERFORMANCE=true
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --flutter-only    Run only Flutter tests"
            echo "  --rust-only       Run only Rust tests"
            echo "  --julia-only      Run only Julia tests"
            echo "  --performance     Include performance benchmarks"
            echo "  --coverage        Generate test coverage reports"
            echo "  --verbose         Enable verbose output"
            echo "  --help            Show this help message"
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

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Test result tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    log_info "Running $test_name..."
    log_verbose "Command: $test_command"
    
    if eval "$test_command"; then
        log_success "$test_name passed"
        ((PASSED_TESTS++))
    else
        log_error "$test_name failed"
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing_deps=()
    
    if [ "$FLUTTER_ONLY" = false ] && [ "$RUST_ONLY" = false ] && [ "$JULIA_ONLY" = false ]; then
        if ! command_exists flutter; then
            missing_deps+=("flutter")
        fi
    fi
    
    if [ "$FLUTTER_ONLY" = false ] && [ "$RUST_ONLY" = false ] && [ "$JULIA_ONLY" = false ]; then
        if ! command_exists cargo; then
            missing_deps+=("rust/cargo")
        fi
    fi
    
    if [ "$FLUTTER_ONLY" = false ] && [ "$RUST_ONLY" = false ] && [ "$JULIA_ONLY" = false ]; then
        if ! command_exists julia; then
            missing_deps+=("julia")
        fi
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install the missing dependencies and try again"
        exit 1
    fi
    
    log_success "All prerequisites satisfied"
}

# Function to run Flutter tests
run_flutter_tests() {
    log_info "Starting Flutter tests..."
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        log_error "pubspec.yaml not found. Please run this script from the Flutter project root."
        exit 1
    fi
    
    # Get Flutter dependencies
    log_info "Getting Flutter dependencies..."
    flutter pub get
    
    # Run unit tests
    if [ "$COVERAGE" = true ]; then
        run_test "Flutter Unit Tests (with coverage)" "flutter test --coverage"
    else
        run_test "Flutter Unit Tests" "flutter test"
    fi
    
    # Run integration tests
    if [ -d "integration_test" ]; then
        run_test "Flutter Integration Tests" "flutter test integration_test/"
    else
        log_warning "No integration tests found"
    fi
    
    # Run widget tests
    if [ -f "test/widget_test.dart" ]; then
        run_test "Flutter Widget Tests" "flutter test test/widget_test.dart"
    fi
    
    # Run FFI tests
    if [ -f "test/rust_ffi_test.dart" ]; then
        run_test "Flutter FFI Tests" "flutter test test/rust_ffi_test.dart"
    fi
    
    # Run Julia-Rust cross-integration tests
    if [ -f "test/julia_rust_cross_integration_test.dart" ]; then
        run_test "Flutter Julia-Rust Cross-Integration Tests" "flutter test test/julia_rust_cross_integration_test.dart"
    fi
    
    log_success "Flutter tests completed"
}

# Function to run Rust tests
run_rust_tests() {
    log_info "Starting Rust tests..."
    
    # Check if we're in the right directory
    if [ ! -f "rust/Cargo.toml" ]; then
        log_error "rust/Cargo.toml not found. Please run this script from the project root."
        exit 1
    fi
    
    cd rust
    
    # Run unit tests
    if [ "$COVERAGE" = true ]; then
        run_test "Rust Unit Tests (with coverage)" "cargo test --lib"
    else
        run_test "Rust Unit Tests" "cargo test --lib"
    fi
    
    # Run Julia-Rust bridge tests
    if [ -f "src/api/julia_rust_bridge.rs" ]; then
        run_test "Rust Julia-Rust Bridge Tests" "cargo test julia_rust_bridge"
    fi
    
    # Run integration tests
    if [ -d "tests" ]; then
        run_test "Rust Integration Tests" "cargo test --test '*'"
    fi
    
    # Run release tests
    run_test "Rust Release Tests" "cargo test --release"
    
    # Run clippy for code quality
    if command_exists cargo-clippy; then
        run_test "Rust Clippy (code quality)" "cargo clippy -- -D warnings"
    else
        log_warning "cargo-clippy not found, skipping code quality checks"
    fi
    
    # Run fmt check
    if command_exists rustfmt; then
        run_test "Rust Format Check" "cargo fmt -- --check"
    else
        log_warning "rustfmt not found, skipping format checks"
    fi
    
    cd ..
    log_success "Rust tests completed"
}

# Function to run Julia tests
run_julia_tests() {
    log_info "Starting Julia tests..."
    
    # Check if we're in the right directory
    if [ ! -f "julia/Project.toml" ]; then
        log_error "julia/Project.toml not found. Please run this script from the project root."
        exit 1
    fi
    
    cd julia
    
    # Install dependencies
    log_info "Installing Julia dependencies..."
    julia --project=. -e "using Pkg; Pkg.instantiate()"
    
    # Run unit tests
    run_test "Julia Unit Tests" "julia --project=. test/runtests.jl"
    
    # Run Julia-Rust cross-integration tests
    if [ -f "test/julia_rust_cross_integration.jl" ]; then
        run_test "Julia Julia-Rust Cross-Integration Tests" "julia --project=. test/julia_rust_cross_integration.jl"
    fi
    
    # Run Julia-Flutter integration tests
    if [ -f "test/julia_flutter_integration.jl" ]; then
        run_test "Julia Julia-Flutter Integration Tests" "julia --project=. test/julia_flutter_integration.jl"
    fi
    
    # Run performance tests
    if [ "$PERFORMANCE" = true ]; then
        run_test "Julia Performance Tests" "julia --project=. test/performance_tests.jl"
    fi
    
    # Run performance benchmarks
    if [ "$PERFORMANCE" = true ]; then
        run_test "Julia Performance Benchmarks" "julia --project=. test/performance_tests.jl --benchmark"
    fi
    
    cd ..
    log_success "Julia tests completed"
}

# Function to run cross-platform tests
run_cross_platform_tests() {
    log_info "Starting cross-platform tests..."
    
    # Test on different platforms if available
    if command_exists flutter; then
        # Test web build
        if flutter config --list | grep -q "enable-web: true"; then
            run_test "Flutter Web Build Test" "flutter build web --release"
        fi
        
        # Test desktop builds if available
        if flutter config --list | grep -q "enable-linux-desktop: true"; then
            run_test "Flutter Linux Desktop Build Test" "flutter build linux --release"
        fi
        
        if flutter config --list | grep -q "enable-macos-desktop: true"; then
            run_test "Flutter macOS Desktop Build Test" "flutter build macos --release"
        fi
        
        if flutter config --list | grep -q "enable-windows-desktop: true"; then
            run_test "Flutter Windows Desktop Build Test" "flutter build windows --release"
        fi
    fi
    
    log_success "Cross-platform tests completed"
}

# Function to generate coverage reports
generate_coverage_reports() {
    if [ "$COVERAGE" = true ]; then
        log_info "Generating coverage reports..."
        
        # Flutter coverage
        if [ -f "coverage/lcov.info" ]; then
            if command_exists genhtml; then
                run_test "Flutter Coverage Report" "genhtml coverage/lcov.info -o coverage/html"
                log_info "Flutter coverage report generated in coverage/html/"
            else
                log_warning "genhtml not found, skipping Flutter coverage report"
            fi
        fi
        
        # Rust coverage (if available)
        if command_exists cargo-tarpaulin; then
            cd rust
            run_test "Rust Coverage Report" "cargo tarpaulin --out Html"
            cd ..
            log_info "Rust coverage report generated in rust/tarpaulin-report.html"
        else
            log_warning "cargo-tarpaulin not found, skipping Rust coverage report"
        fi
        
        log_success "Coverage reports generated"
    fi
}

# Function to print test summary
print_summary() {
    echo
    echo "=========================================="
    echo "           TEST SUMMARY"
    echo "=========================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    echo "=========================================="
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "All tests passed! 🎉"
        exit 0
    else
        log_error "Some tests failed. Please check the output above."
        exit 1
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "    Flutter-Rust-Julia FFI Test Suite"
    echo "=========================================="
    echo
    
    # Check prerequisites
    check_prerequisites
    
    # Run tests based on options
    if [ "$FLUTTER_ONLY" = true ]; then
        run_flutter_tests
    elif [ "$RUST_ONLY" = true ]; then
        run_rust_tests
    elif [ "$JULIA_ONLY" = true ]; then
        run_julia_tests
    else
        # Run all tests
        run_flutter_tests
        run_rust_tests
        run_julia_tests
        run_cross_platform_tests
    fi
    
    # Generate coverage reports
    generate_coverage_reports
    
    # Print summary
    print_summary
}

# Run main function
main "$@"
