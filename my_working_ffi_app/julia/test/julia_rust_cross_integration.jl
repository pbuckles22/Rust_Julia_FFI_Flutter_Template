# Julia-Rust Cross-Integration Tests
# These tests define the requirements for Julia calling Rust functions
# Following TDD: Red -> Green -> Refactor

using Test
using JuliaLibMyWorkingFfiApp

# Include the JuliaRustBridge module
include("../src/JuliaRustBridge.jl")
using .JuliaRustBridge

# Test configuration
const TEST_TIMEOUT = 30.0  # seconds
const PERFORMANCE_THRESHOLD = 1.0  # seconds for performance tests

@testset "Julia-Rust Cross-Integration Tests" begin
    
    @testset "Julia Calling Rust Functions" begin
        
        @testset "Basic Rust Function Calls" begin
            # Initialize the bridge first
            @test init_julia_rust_bridge() == true
            
            # Test: Julia should be able to call Rust greet function
            result = julia_call_rust_greet("Alice")
            @test result == "Hello from Rust, Alice!"
            
            # Test: Julia should be able to call Rust add_numbers function
            result = julia_call_rust_add_numbers(Int32(5), Int32(3))
            @test result == Int32(8)
            
            # Test: Julia should be able to call Rust multiply_floats function
            result = julia_call_rust_multiply_floats(2.5, 4.0)
            @test result == 10.0
        end
        
        @testset "Data Type Conversion" begin
            # Test: Julia strings should convert to Rust strings
            result = julia_call_rust_greet("Hello from Julia")
            @test result == "Hello from Rust, Hello from Julia!"
            
            # Test: Julia integers should convert to Rust integers
            result = julia_call_rust_add_numbers(Int32(100), Int32(200))
            @test result == Int32(300)
            
            # Test: Julia floats should convert to Rust floats
            result = julia_call_rust_multiply_floats(3.14, 2.0)
            @test result ≈ 6.28
        end
        
        @testset "Complex Data Structures" begin
            # Test: Julia arrays should convert to Rust vectors
            result = julia_call_rust_get_string_lengths(["hello", "world", "julia"])
            @test result == [5, 5, 5]
            
            # Test: Julia dictionaries should convert to Rust HashMaps
            result = julia_call_rust_create_string_map([("key1", "value1"), ("key2", "value2")])
            @test result["key1"] == "value1"
            @test result["key2"] == "value2"
        end
        
        @testset "Error Handling" begin
            # Test: Julia should handle Rust errors gracefully
            result = julia_call_rust_add_numbers(typemax(Int32), Int32(1))
            @test result == -1  # Rust returns -1 for overflow
            
            # Test: Julia should handle invalid inputs
            result = julia_call_rust_factorial(Int32(-1))
            @test result == 1  # Factorial of negative number should return 1
        end
        
        @testset "Performance Tests" begin
            # Test: Cross-language calls should be reasonably fast
            start_time = time()
            for i in 1:1000
                julia_call_rust_add_numbers(Int32(i), Int32(i+1))
            end
            end_time = time()
            @test (end_time - start_time) < PERFORMANCE_THRESHOLD
            # Expected: 1000 calls should complete in under 1 second
        end
    end
    
    @testset "Julia-Rust Data Sharing" begin
        @testset "Shared Memory Operations" begin
            # Test: Julia should be able to share data with Rust
            @test julia_rust_shared_data_test() == true
            # Expected: Should work with shared memory
            
            # Test: Large data structures should be efficiently shared
            @test julia_rust_large_data_test(Int32(10000)) == true
            # Expected: Should handle large arrays efficiently
        end
        
        @testset "Bidirectional Communication" begin
            # Test: Julia should call Rust, Rust should call Julia
            @test julia_rust_bidirectional_test() == true
            # Expected: Should work both ways
            
            # Test: Nested calls (Julia -> Rust -> Julia)
            @test julia_rust_nested_calls_test() == true
            # Expected: Should handle nested calls properly
        end
    end
    
    @testset "Advanced Julia-Rust Integration" begin
        @testset "Scientific Computing Pipeline" begin
            # Test: Julia should use Rust for performance-critical operations
            @test julia_rust_scientific_pipeline() == true
            # Expected: Should combine Julia's math with Rust's performance
            
            # Test: Matrix operations with Rust backend
            @test julia_rust_matrix_operations() == true
            # Expected: Should use Rust for matrix computations
        end
        
        @testset "Real-time Data Processing" begin
            # Test: Julia should process data with Rust for real-time performance
            @test julia_rust_realtime_processing() == true
            # Expected: Should handle real-time data efficiently
            
            # Test: Streaming data between Julia and Rust
            @test julia_rust_streaming_data() == true
            # Expected: Should handle streaming efficiently
        end
    end
    
    @testset "Integration with Flutter App" begin
        @testset "Flutter-Julia-Rust Chain" begin
            # Test: Flutter should be able to call Julia, which calls Rust
            @test flutter_julia_rust_chain_test() == true
            # Expected: Should work end-to-end
            
            # Test: Complex data flow through all three languages
            @test flutter_julia_rust_complex_flow() == true
            # Expected: Should handle complex data flow
        end
        
        @testset "Performance in Flutter Context" begin
            # Test: Cross-language calls should be fast enough for Flutter UI
            @test flutter_julia_rust_performance_test() == true
            # Expected: Should not block Flutter UI thread
            
            # Test: Memory usage should be reasonable
            @test flutter_julia_rust_memory_test() == true
            # Expected: Should not cause memory leaks
        end
    end
end

# All advanced test functions are now implemented in JuliaRustBridge.jl
# This completes the TDD Green Phase for all advanced integration tests!
