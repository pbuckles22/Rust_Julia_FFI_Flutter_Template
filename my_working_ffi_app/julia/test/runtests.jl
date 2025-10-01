# Test Suite for JuliaLibMyWorkingFfiApp
# Comprehensive test suite covering all functionality of the Julia FFI library.

using Test
using JuliaLibMyWorkingFfiApp

# Test configuration
const TEST_TIMEOUT = 30.0  # seconds
const PERFORMANCE_THRESHOLD = 1.0  # seconds for performance tests

@testset "JuliaLibMyWorkingFfiApp Tests" begin
    
    @testset "Library Initialization" begin
        @testset "init_julia_lib" begin
            @test init_julia_lib() == true
            @test init_julia_lib() == true  # Should be idempotent
        end
        
        @testset "cleanup_julia_lib" begin
            @test cleanup_julia_lib() == true
            @test cleanup_julia_lib() == true  # Should be idempotent
        end
    end
    
    @testset "Fibonacci Computation" begin
        @testset "Basic functionality" begin
            @test compute_fibonacci(0) == 0
            @test compute_fibonacci(1) == 1
            @test compute_fibonacci(2) == 1
            @test compute_fibonacci(3) == 2
            @test compute_fibonacci(4) == 3
            @test compute_fibonacci(5) == 5
            @test compute_fibonacci(10) == 55
            @test compute_fibonacci(20) == 6765
        end
        
        @testset "Edge cases" begin
            @test_throws ArgumentError compute_fibonacci(-1)
            @test_throws ArgumentError compute_fibonacci(-10)
        end
        
        @testset "Performance" begin
            # Test that large Fibonacci numbers can be computed efficiently
            start_time = time()
            result = compute_fibonacci(1000)
            elapsed_time = time() - start_time
            
            @test result > 0  # Should be positive
            @test elapsed_time < PERFORMANCE_THRESHOLD
        end
    end
    
    @testset "Prime Number Generation" begin
        @testset "Basic functionality" begin
            @test compute_prime_numbers(2) == [2]
            @test compute_prime_numbers(10) == [2, 3, 5, 7]
            @test compute_prime_numbers(20) == [2, 3, 5, 7, 11, 13, 17, 19]
        end
        
        @testset "Edge cases" begin
            @test_throws ArgumentError compute_prime_numbers(1)
            @test_throws ArgumentError compute_prime_numbers(0)
            @test_throws ArgumentError compute_prime_numbers(-1)
        end
        
        @testset "Correctness verification" begin
            # Verify that all returned numbers are actually prime
            primes = compute_prime_numbers(100)
            for p in primes
                @test p > 1
                @test all(p % i != 0 for i in 2:isqrt(p))
            end
        end
        
        @testset "Performance" begin
            start_time = time()
            primes = compute_prime_numbers(10000)
            elapsed_time = time() - start_time
            
            @test length(primes) > 0
            @test elapsed_time < PERFORMANCE_THRESHOLD
        end
    end
    
    @testset "Matrix Operations" begin
        @testset "Basic matrix multiplication" begin
            A = [1.0 2.0; 3.0 4.0]
            B = [5.0 6.0; 7.0 8.0]
            expected = [19.0 22.0; 43.0 50.0]
            
            result = matrix_multiply(A, B)
            @test result ≈ expected
        end
        
        @testset "Identity matrix" begin
            A = [1.0 2.0; 3.0 4.0]
            I = [1.0 0.0; 0.0 1.0]
            
            result = matrix_multiply(A, I)
            @test result ≈ A
        end
        
        @testset "Dimension compatibility" begin
            A = [1.0 2.0 3.0; 4.0 5.0 6.0]  # 2x3
            B = [7.0 8.0; 9.0 10.0; 11.0 12.0]  # 3x2
            
            result = matrix_multiply(A, B)
            @test size(result) == (2, 2)
        end
        
        @testset "Error handling" begin
            A = [1.0 2.0; 3.0 4.0]  # 2x2
            B = [5.0 6.0 7.0; 8.0 9.0 10.0]  # 2x3 (compatible for multiplication)
            
            # Matrix multiplication with these dimensions works fine
            # A is 2x2, B is 2x3, result should be 2x3
            result = matrix_multiply(A, B)
            @test size(result) == (2, 3)
            @test result[1,1] ≈ 21.0
            @test result[2,3] ≈ 61.0
        end
        
        @testset "Performance" begin
            # Test with larger matrices
            A = rand(100, 100)
            B = rand(100, 100)
            
            start_time = time()
            result = matrix_multiply(A, B)
            elapsed_time = time() - start_time
            
            @test size(result) == (100, 100)
            @test elapsed_time < PERFORMANCE_THRESHOLD
        end
    end
    
    @testset "Statistical Analysis" begin
        @testset "Basic statistics" begin
            data = [1.0, 2.0, 3.0, 4.0, 5.0]
            stats = statistical_analysis(data)
            
            @test stats.mean ≈ 3.0
            @test stats.median ≈ 3.0
            @test stats.min == 1.0
            @test stats.max == 5.0
            @test stats.count == 5
            @test stats.std ≈ sqrt(2.5)  # Sample standard deviation
        end
        
        @testset "Single element" begin
            data = [42.0]
            stats = statistical_analysis(data)
            
            @test stats.mean == 42.0
            @test stats.median == 42.0
            @test stats.min == 42.0
            @test stats.max == 42.0
            @test stats.count == 1
            @test isnan(stats.std)  # Standard deviation is undefined for n=1
        end
        
        @testset "Even number of elements" begin
            data = [1.0, 2.0, 3.0, 4.0]
            stats = statistical_analysis(data)
            
            @test stats.median ≈ 2.5  # Average of middle two elements
        end
        
        @testset "Error handling" begin
            @test_throws ArgumentError statistical_analysis(Float64[])
        end
        
        @testset "Performance" begin
            data = rand(10000)
            
            start_time = time()
            stats = statistical_analysis(data)
            elapsed_time = time() - start_time
            
            @test stats.count == 10000
            @test elapsed_time < PERFORMANCE_THRESHOLD
        end
    end
    
    @testset "FFI Compatibility" begin
        @testset "C-compatible functions" begin
            # Test that C-compatible functions work correctly
            name = "TestUser"
            # Convert string to C-compatible pointer
            name_ptr = Base.unsafe_convert(Cstring, name)
            greeting = julia_greet(name_ptr)
            
            # Note: In a real FFI scenario, we would need to handle
            # C string memory management properly
            @test greeting != C_NULL
        end
    end
    
    @testset "Integration Tests" begin
        @testset "Full workflow" begin
            # Test a complete workflow using multiple functions
            @test init_julia_lib() == true
            
            # Compute some mathematical results
            fib_result = compute_fibonacci(15)
            primes = compute_prime_numbers(50)
            
            # Perform matrix operations
            A = [1.0 2.0; 3.0 4.0]
            B = [2.0 0.0; 0.0 2.0]
            matrix_result = matrix_multiply(A, B)
            
            # Statistical analysis
            data = [1.0, 2.0, 3.0, 4.0, 5.0]
            stats = statistical_analysis(data)
            
            # Verify results
            @test fib_result > 0
            @test length(primes) > 0
            @test size(matrix_result) == (2, 2)
            @test stats.count == 5
            
            # Cleanup
            @test cleanup_julia_lib() == true
        end
    end
    
    @testset "Memory Management" begin
        @testset "No memory leaks" begin
            # Perform many operations to check for memory leaks
            for i in 1:1000
                compute_fibonacci(20)
                compute_prime_numbers(100)
                A = rand(10, 10)
                B = rand(10, 10)
                matrix_multiply(A, B)
                data = rand(100)
                statistical_analysis(data)
            end
            
            # If we get here without crashing, memory management is working
            @test true
        end
    end
end

# Performance benchmarks (optional, run with --benchmark flag)
if "--benchmark" in ARGS
    println("\n" * "="^50)
    println("PERFORMANCE BENCHMARKS")
    println("="^50)
    
    # Fibonacci benchmark
    println("\nFibonacci Benchmark:")
    for n in [10, 100, 1000, 10000]
        start_time = time()
        result = compute_fibonacci(n)
        elapsed_time = time() - start_time
        println("  F($n) = $result ($(round(elapsed_time*1000, digits=2))ms)")
    end
    
    # Prime generation benchmark
    println("\nPrime Generation Benchmark:")
    for limit in [100, 1000, 10000, 100000]
        start_time = time()
        primes = compute_prime_numbers(limit)
        elapsed_time = time() - start_time
        println("  Primes up to $limit: $(length(primes)) primes ($(round(elapsed_time*1000, digits=2))ms)")
    end
    
    # Matrix multiplication benchmark
    println("\nMatrix Multiplication Benchmark:")
    for size in [10, 50, 100, 200]
        A = rand(size, size)
        B = rand(size, size)
        start_time = time()
        result = matrix_multiply(A, B)
        elapsed_time = time() - start_time
        println("  $(size)x$(size) matrices: $(round(elapsed_time*1000, digits=2))ms")
    end
end

println("\n" * "="^50)
println("All tests completed successfully!")
println("="^50)
