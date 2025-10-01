#!/bin/bash

# Code Quality Script
# Comprehensive linting, formatting, and quality checks for all languages

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run Flutter/Dart quality checks
run_flutter_quality() {
    log_info "Running Flutter/Dart quality checks..."
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        log_error "pubspec.yaml not found. Please run this script from the project root."
        exit 1
    fi
    
    # Flutter analyze
    if command_exists flutter; then
        log_info "Running Flutter analyze..."
        flutter analyze --no-fatal-infos
        log_success "Flutter analyze completed"
    else
        log_warning "Flutter not found, skipping Flutter analyze"
    fi
    
    # Dart format check
    if command_exists dart; then
        log_info "Checking Dart formatting..."
        dart format --set-exit-if-changed .
        log_success "Dart formatting check completed"
    else
        log_warning "Dart not found, skipping format check"
    fi
    
    # Dart test
    if command_exists dart; then
        log_info "Running Dart tests..."
        dart test
        log_success "Dart tests completed"
    else
        log_warning "Dart not found, skipping tests"
    fi
}

# Function to run Rust quality checks
run_rust_quality() {
    log_info "Running Rust quality checks..."
    
    # Check if we're in the right directory
    if [ ! -f "rust/Cargo.toml" ]; then
        log_error "rust/Cargo.toml not found. Please run this script from the project root."
        exit 1
    fi
    
    cd rust
    
    # Cargo fmt check
    if command_exists cargo; then
        log_info "Checking Rust formatting..."
        cargo fmt -- --check
        log_success "Rust formatting check completed"
    else
        log_warning "Cargo not found, skipping format check"
    fi
    
    # Cargo clippy
    if command_exists cargo-clippy; then
        log_info "Running Rust clippy..."
        cargo clippy -- -D warnings
        log_success "Rust clippy completed"
    elif command_exists cargo; then
        log_info "Running Rust clippy (via cargo)..."
        cargo clippy -- -D warnings
        log_success "Rust clippy completed"
    else
        log_warning "Cargo not found, skipping clippy"
    fi
    
    # Cargo test
    if command_exists cargo; then
        log_info "Running Rust tests..."
        cargo test
        log_success "Rust tests completed"
    else
        log_warning "Cargo not found, skipping tests"
    fi
    
    cd ..
}

# Function to run Julia Bridge quality checks
run_julia_bridge_quality() {
    log_info "Running Julia Bridge quality checks..."
    
    # Check if we're in the right directory
    if [ ! -f "julia_bridge/Cargo.toml" ]; then
        log_error "julia_bridge/Cargo.toml not found. Please run this script from the project root."
        exit 1
    fi
    
    cd julia_bridge
    
    # Cargo fmt check
    if command_exists cargo; then
        log_info "Checking Julia Bridge formatting..."
        cargo fmt -- --check
        log_success "Julia Bridge formatting check completed"
    else
        log_warning "Cargo not found, skipping format check"
    fi
    
    # Cargo clippy
    if command_exists cargo-clippy; then
        log_info "Running Julia Bridge clippy..."
        cargo clippy -- -D warnings
        log_success "Julia Bridge clippy completed"
    elif command_exists cargo; then
        log_info "Running Julia Bridge clippy (via cargo)..."
        cargo clippy -- -D warnings
        log_success "Julia Bridge clippy completed"
    else
        log_warning "Cargo not found, skipping clippy"
    fi
    
    # Cargo test
    if command_exists cargo; then
        log_info "Running Julia Bridge tests..."
        cargo test
        log_success "Julia Bridge tests completed"
    else
        log_warning "Cargo not found, skipping tests"
    fi
    
    cd ..
}

# Function to run Julia quality checks
run_julia_quality() {
    log_info "Running Julia quality checks..."
    
    # Check if we're in the right directory
    if [ ! -f "julia/Project.toml" ]; then
        log_error "julia/Project.toml not found. Please run this script from the project root."
        exit 1
    fi
    
    cd julia
    
    # Julia tests
    if command_exists julia; then
        log_info "Running Julia tests..."
        julia --project=. test/runtests.jl
        log_success "Julia tests completed"
    else
        log_warning "Julia not found, skipping tests"
    fi
    
    # Julia formatting (if JuliaFormatter is available)
    if command_exists julia; then
        log_info "Checking Julia formatting..."
        julia --project=. -e "using JuliaFormatter; format(\".\")" 2>/dev/null || log_warning "JuliaFormatter not available, skipping format check"
        log_success "Julia formatting check completed"
    else
        log_warning "Julia not found, skipping format check"
    fi
    
    cd ..
}

# Function to run all quality checks
run_all_quality() {
    log_info "Running comprehensive code quality checks..."
    
    # Flutter/Dart quality
    run_flutter_quality
    
    # Rust quality
    run_rust_quality
    
    # Julia Bridge quality
    run_julia_bridge_quality
    
    # Julia quality
    run_julia_quality
    
    log_success "All code quality checks completed successfully!"
}

# Function to show help
show_help() {
    echo "Code Quality Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --flutter     Run Flutter/Dart quality checks only"
    echo "  --rust        Run Rust quality checks only"
    echo "  --julia-bridge Run Julia Bridge quality checks only"
    echo "  --julia       Run Julia quality checks only"
    echo "  --all         Run all quality checks (default)"
    echo "  --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all quality checks"
    echo "  $0 --flutter          # Run Flutter/Dart checks only"
    echo "  $0 --rust             # Run Rust checks only"
    echo "  $0 --julia            # Run Julia checks only"
}

# Main script logic
main() {
    case "${1:-}" in
        --flutter)
            run_flutter_quality
            ;;
        --rust)
            run_rust_quality
            ;;
        --julia-bridge)
            run_julia_bridge_quality
            ;;
        --julia)
            run_julia_quality
            ;;
        --all|"")
            run_all_quality
            ;;
        --help|-h)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
