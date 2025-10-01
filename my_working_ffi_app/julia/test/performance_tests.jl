"""
    Performance Test Suite for JuliaLibMyWorkingFfiApp

Comprehensive performance benchmarks and stress tests for the Julia FFI library.
This test suite measures performance characteristics and ensures the library
can handle production workloads efficiently.

# Test Categories
- Algorithm performance benchmarks
- Memory usage tests
- Stress tests with large datasets
- Concurrent operation tests
- FFI overhead measurements

# Usage
```bash
julia --project=. test/performance_tests.jl
```
"""
using Test
using BenchmarkTools
using JuliaLibMyWorkingFfiApp

# Performance test configuration
const LARGE_DATASET_SIZE = 100000
const STRESS_TEST_ITERATIONS = 1000
const PERFORMANCE_THRESHOLD_MS = 1000.0  # 1 second threshold

@testset "Performance Tests" begin
    
    @testset "Fibonacci Performance" begin
        @testset "Small numbers performance" begin
            # Test performance for small Fibonacci numbers
            result = @benchmark compute_fibonacci(20)
            @test median(result).time < 1000  # Should complete in < 1μs
            
            result = @benchmark compute_fibonacci(50)
            @test median(result).time < 10000  # Should complete in < 10μs
        end
        
        @testset "Large numbers performance" begin
            # Test performance for larger Fibonacci numbers
            result = @benchmark compute_fibonacci(1000)
            @test median(result).time < 1000000  # Should complete in < 1ms
            
            result = @benchmark compute_fibonacci(10000)
            @test median(result).time < 10000000  # Should complete in < 10ms
        end
        
        @testset "Scalability test" begin
            # Test that performance scales reasonably
            times = Float64[]
            for n in [100, 500, 1000, 2000]
                result = @benchmark compute_fibonacci($n)
                push!(times, median(result).time)
            end
            
            # Performance should not degrade exponentially
            @test times[end] < times[1] * 100  # 100x slower is acceptable for 20x input
        end
    end
    
    @testset "Prime Generation Performance" begin
        @testset "Small limits performance" begin
            result = @benchmark compute_prime_numbers(1000)
            @test median(result).time < 1000000  # Should complete in < 1ms
            
            result = @benchmark compute_prime_numbers(10000)
            @test median(result).time < 10000000  # Should complete in < 10ms
        end
        
        @testset "Large limits performance" begin
            result = @benchmark compute_prime_numbers(100000)
            @test median(result).time < 100000000  # Should complete in < 100ms
            
            result = @benchmark compute_prime_numbers(1000000)
            @test median(result).time < 1000000000  # Should complete in < 1s
        end
        
        @testset "Memory efficiency" begin
            # Test memory usage for large prime generation
            result = @benchmark compute_prime_numbers(100000)
            @test result.memory < 10 * 1024 * 1024  # Should use < 10MB
        end
    end
    
    @testset "Matrix Operations Performance" begin
        @testset "Small matrices performance" begin
            A = rand(10, 10)
            B = rand(10, 10)
            
            result = @benchmark matrix_multiply($A, $B)
            @test median(result).time < 1000  # Should complete in < 1μs
        end
        
        @testset "Medium matrices performance" begin
            A = rand(100, 100)
            B = rand(100, 100)
            
            result = @benchmark matrix_multiply($A, $B)
            @test median(result).time < 1000000  # Should complete in < 1ms
        end
        
        @testset "Large matrices performance" begin
            A = rand(500, 500)
            B = rand(500, 500)
            
            result = @benchmark matrix_multiply($A, $B)
            @test median(result).time < 100000000  # Should complete in < 100ms
        end
        
        @testset "Matrix multiplication scalability" begin
            # Test that performance scales with matrix size
            sizes = [10, 50, 100, 200]
            times = Float64[]
            
            for size in sizes
                A = rand(size, size)
                B = rand(size, size)
                result = @benchmark matrix_multiply($A, $B)
                push!(times, median(result).time)
            end
            
            # Performance should scale roughly as O(n³)
            # Allow for some variance due to BLAS optimizations
            @test times[end] < times[1] * 1000  # 1000x slower for 20x size is reasonable
        end
    end
    
    @testset "Statistical Analysis Performance" begin
        @testset "Small datasets performance" begin
            data = rand(1000)
            
            result = @benchmark statistical_analysis($data)
            @test median(result).time < 10000  # Should complete in < 10μs
        end
        
        @testset "Large datasets performance" begin
            data = rand(100000)
            
            result = @benchmark statistical_analysis($data)
            @test median(result).time < 1000000  # Should complete in < 1ms
        end
        
        @testset "Very large datasets performance" begin
            data = rand(1000000)
            
            result = @benchmark statistical_analysis($data)
            @test median(result).time < 10000000  # Should complete in < 10ms
        end
        
        @testset "Memory efficiency" begin
            data = rand(100000)
            result = @benchmark statistical_analysis($data)
            @test result.memory < 5 * 1024 * 1024  # Should use < 5MB
        end
    end
    
    @testset "Stress Tests" begin
        @testset "Fibonacci stress test" begin
            # Perform many Fibonacci calculations
            start_time = time()
            
            for i in 1:STRESS_TEST_ITERATIONS
                compute_fibonacci(50)
            end
            
            elapsed_time = time() - start_time
            @test elapsed_time < PERFORMANCE_THRESHOLD_MS / 1000  # Should complete in < 1s
        end
        
        @testset "Prime generation stress test" begin
            # Perform many prime calculations
            start_time = time()
            
            for i in 1:100  # Fewer iterations due to higher computational cost
                compute_prime_numbers(1000)
            end
            
            elapsed_time = time() - start_time
            @test elapsed_time < PERFORMANCE_THRESHOLD_MS / 1000  # Should complete in < 1s
        end
        
        @testset "Matrix operations stress test" begin
            # Perform many matrix operations
            start_time = time()
            
            for i in 1:STRESS_TEST_ITERATIONS
                A = rand(10, 10)
                B = rand(10, 10)
                matrix_multiply(A, B)
            end
            
            elapsed_time = time() - start_time
            @test elapsed_time < PERFORMANCE_THRESHOLD_MS / 1000  # Should complete in < 1s
        end
        
        @testset "Statistical analysis stress test" begin
            # Perform many statistical analyses
            start_time = time()
            
            for i in 1:STRESS_TEST_ITERATIONS
                data = rand(1000)
                statistical_analysis(data)
            end
            
            elapsed_time = time() - start_time
            @test elapsed_time < PERFORMANCE_THRESHOLD_MS / 1000  # Should complete in < 1s
        end
    end
    
    @testset "Memory Management Tests" begin
        @testset "Memory leak detection" begin
            # Perform many operations and check for memory leaks
            initial_memory = Base.gc_bytes()
            
            for i in 1:10000
                compute_fibonacci(20)
                compute_prime_numbers(100)
                A = rand(10, 10)
                B = rand(10, 10)
                matrix_multiply(A, B)
                data = rand(100)
                statistical_analysis(data)
            end
            
            # Force garbage collection
            GC.gc()
            final_memory = Base.gc_bytes()
            
            # Memory usage should not grow significantly
            memory_growth = final_memory - initial_memory
            @test memory_growth < 100 * 1024 * 1024  # Should not grow by more than 100MB
        end
        
        @testset "Large dataset memory usage" begin
            # Test memory usage with large datasets
            data = rand(LARGE_DATASET_SIZE)
            
            result = @benchmark statistical_analysis($data)
            @test result.memory < 50 * 1024 * 1024  # Should use < 50MB
        end
        
        @testset "Matrix memory usage" begin
            # Test memory usage with large matrices
            A = rand(1000, 1000)
            B = rand(1000, 1000)
            
            result = @benchmark matrix_multiply($A, $B)
            @test result.memory < 100 * 1024 * 1024  # Should use < 100MB
        end
    end
    
    @testset "Concurrent Operations Tests" begin
        @testset "Parallel Fibonacci computation" begin
            # Test concurrent Fibonacci computations
            start_time = time()
            
            tasks = Task[]
            for i in 1:10
                task = @async begin
                    for j in 1:100
                        compute_fibonacci(30)
                    end
                end
                push!(tasks, task)
            end
            
            # Wait for all tasks to complete
            for task in tasks
                wait(task)
            end
            
            elapsed_time = time() - start_time
            @test elapsed_time < PERFORMANCE_THRESHOLD_MS / 1000  # Should complete in < 1s
        end
        
        @testset "Parallel matrix operations" begin
            # Test concurrent matrix operations
            start_time = time()
            
            tasks = Task[]
            for i in 1:5  # Fewer tasks due to higher computational cost
                task = @async begin
                    for j in 1:20
                        A = rand(50, 50)
                        B = rand(50, 50)
                        matrix_multiply(A, B)
                    end
                end
                push!(tasks, task)
            end
            
            # Wait for all tasks to complete
            for task in tasks
                wait(task)
            end
            
            elapsed_time = time() - start_time
            @test elapsed_time < PERFORMANCE_THRESHOLD_MS / 1000  # Should complete in < 1s
        end
    end
    
    @testset "FFI Overhead Tests" begin
        @testset "Function call overhead" begin
            # Measure the overhead of FFI function calls
            result = @benchmark greet("Test")
            @test median(result).time < 1000  # Should complete in < 1μs
            
            result = @benchmark add_numbers(5, 3)
            @test median(result).time < 1000  # Should complete in < 1μs
        end
        
        @testset "Data transfer overhead" begin
            # Measure the overhead of data transfer
            large_string = "x" ^ 10000
            
            result = @benchmark greet($large_string)
            @test median(result).time < 10000  # Should complete in < 10μs
        end
    end
    
    @testset "Scalability Tests" begin
        @testset "Fibonacci scalability" begin
            # Test that Fibonacci performance scales reasonably
            sizes = [10, 50, 100, 500, 1000]
            times = Float64[]
            
            for size in sizes
                result = @benchmark compute_fibonacci($size)
                push!(times, median(result).time)
            end
            
            # Performance should scale linearly
            @test times[end] < times[1] * 100  # 100x slower for 100x input is reasonable
        end
        
        @testset "Prime generation scalability" begin
            # Test that prime generation performance scales reasonably
            limits = [100, 1000, 10000, 100000]
            times = Float64[]
            
            for limit in limits
                result = @benchmark compute_prime_numbers($limit)
                push!(times, median(result).time)
            end
            
            # Performance should scale roughly as O(n log log n)
            @test times[end] < times[1] * 1000  # 1000x slower for 1000x input is reasonable
        end
    end
end

# Performance benchmark report (optional, run with --benchmark flag)
if "--benchmark" in ARGS
    println("\n" * "="^60)
    println("PERFORMANCE BENCHMARK REPORT")
    println("="^60)
    
    # Fibonacci benchmarks
    println("\nFibonacci Performance:")
    for n in [10, 50, 100, 500, 1000]
        result = @benchmark compute_fibonacci($n)
        println("  F($n): $(median(result).time)ns ($(median(result).time/1000)μs)")
    end
    
    # Prime generation benchmarks
    println("\nPrime Generation Performance:")
    for limit in [100, 1000, 10000, 100000]
        result = @benchmark compute_prime_numbers($limit)
        println("  Primes up to $limit: $(median(result).time)ns ($(median(result).time/1000)μs)")
    end
    
    # Matrix multiplication benchmarks
    println("\nMatrix Multiplication Performance:")
    for size in [10, 50, 100, 200]
        A = rand(size, size)
        B = rand(size, size)
        result = @benchmark matrix_multiply($A, $B)
        println("  ${size}x${size}: $(median(result).time)ns ($(median(result).time/1000)μs)")
    end
    
    # Statistical analysis benchmarks
    println("\nStatistical Analysis Performance:")
    for size in [100, 1000, 10000, 100000]
        data = rand(size)
        result = @benchmark statistical_analysis($data)
        println("  Dataset size $size: $(median(result).time)ns ($(median(result).time/1000)μs)")
    end
    
    println("\n" * "="^60)
    println("Benchmark completed successfully!")
    println("="^60)
end
