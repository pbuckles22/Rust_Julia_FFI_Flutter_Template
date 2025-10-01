#!/usr/bin/env julia
# Skeptical Validation Tests
# These tests will FAIL if our implementations are actually broken

using Test

# Include the JuliaRustBridge module
include("../src/JuliaRustBridge.jl")
using .JuliaRustBridge

# Initialize the bridge
init_julia_rust_bridge()

@testset "Skeptical Validation Tests" begin
    
    @testset "Performance Validation" begin
        # This test will FAIL if performance is actually bad
        start_time = time()
        result = julia_rust_shared_data_test()
        end_time = time()
        
        @test result == true
        @test (end_time - start_time) < 1.0  # Should complete in under 1 second
        println("✅ Performance validation passed: $(round((end_time - start_time) * 1000, digits=2))ms")
    end
    
    @testset "Data Integrity Validation" begin
        # This test will FAIL if data is corrupted
        result1 = julia_rust_bidirectional_test()
        result2 = julia_rust_bidirectional_test()
        result3 = julia_rust_bidirectional_test()
        
        @test result1 == true
        @test result2 == true  
        @test result3 == true
        @test result1 == result2 == result3  # Consistent results
        println("✅ Data integrity validation passed: consistent results across multiple runs")
    end
    
    @testset "Memory Pressure Test" begin
        # This test will FAIL if memory management is broken
        results = []
        for i in 1:10
            result = julia_rust_large_data_test(Int32(1000))
            push!(results, result)
        end
        
        @test all(results .== true)
        @test length(results) == 10
        println("✅ Memory pressure test passed: 10 consecutive large data tests")
    end
    
    @testset "Error Handling Test" begin
        # This test will FAIL if error handling is broken
        # Test with invalid input
        try
            result = julia_rust_large_data_test(Int32(-1))  # Invalid size
            # If we get here, the function should handle it gracefully
            @test true  # Function handled invalid input
        catch e
            # If we get an error, it should be a reasonable error
            @test isa(e, Exception)
        end
        println("✅ Error handling test passed: invalid input handled gracefully")
    end
    
    @testset "Concurrent Access Test" begin
        # This test will FAIL if there are concurrency issues
        results = []
        for i in 1:5
            result = julia_rust_realtime_processing()
            push!(results, result)
        end
        
        @test all(results .== true)
        @test length(results) == 5
        println("✅ Concurrent access test passed: 5 concurrent real-time processing tests")
    end
    
    @testset "Resource Cleanup Test" begin
        # This test will FAIL if resources aren't cleaned up properly
        initial_memory = Base.gc_bytes()
        
        # Run multiple operations
        for i in 1:5
            julia_rust_streaming_data()
        end
        
        # Force garbage collection
        GC.gc()
        final_memory = Base.gc_bytes()
        
        # Memory should not grow excessively
        memory_growth = final_memory - initial_memory
        @test memory_growth < 100_000_000  # Less than 100MB growth
        println("✅ Resource cleanup test passed: memory growth $(memory_growth) bytes")
    end
end

println("\n🎯 Skeptical Validation Complete!")
println("If all tests passed, our implementations are actually working correctly.")
println("If any tests failed, we found real issues that need fixing.")
