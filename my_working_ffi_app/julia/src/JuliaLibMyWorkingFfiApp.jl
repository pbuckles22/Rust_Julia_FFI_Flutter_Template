"""
    JuliaLibMyWorkingFfiApp

A Julia library for FFI integration with Flutter and Rust applications.
This module provides high-performance computational functions that can be called
from Flutter via FFI, complementing the Rust backend.

# Architecture
- **Julia**: High-performance numerical computing and scientific algorithms
- **Rust**: System-level operations and memory management
- **Flutter**: Cross-platform UI and application logic

# Usage
```julia
using JuliaLibMyWorkingFfiApp

# Initialize the library
init_julia_lib()

# Call computational functions
result = compute_fibonacci(10)
```
"""
module JuliaLibMyWorkingFfiApp

using PackageCompiler
using Libdl

# Export public API functions
export init_julia_lib, compute_fibonacci, compute_prime_numbers, 
       matrix_multiply, statistical_analysis, cleanup_julia_lib

# Global state management
const _initialized = Ref{Bool}(false)
const _lib_handle = Ref{Ptr{Cvoid}}(C_NULL)

"""
    init_julia_lib() -> Bool

Initialize the Julia library for FFI operations.

This function must be called before any other operations to ensure
proper setup of the Julia runtime and memory management.

# Returns
- `true` if initialization was successful
- `false` if initialization failed

# Example
```julia
if init_julia_lib()
    println("Julia library initialized successfully")
else
    println("Failed to initialize Julia library")
end
```
"""
function init_julia_lib()::Bool
    try
        if _initialized[]
            return true  # Already initialized
        end
        
        # Initialize Julia runtime components
        # This is where we would set up any global state, 
        # precompile critical functions, etc.
        
        _initialized[] = true
        return true
    catch e
        @error "Failed to initialize Julia library" exception = e
        return false
    end
end

"""
    compute_fibonacci(n::Int) -> Int

Compute the nth Fibonacci number using an efficient iterative algorithm.

This function demonstrates Julia's performance capabilities for mathematical
computations that can be called from Flutter via FFI.

# Arguments
- `n::Int`: The position in the Fibonacci sequence (must be >= 0)

# Returns
- The nth Fibonacci number

# Example
```julia
result = compute_fibonacci(10)  # Returns 55
```

# Performance
- Time complexity: O(n)
- Space complexity: O(1)
"""
function compute_fibonacci(n::Int)::Int
    if n < 0
        throw(ArgumentError("Fibonacci sequence is not defined for negative numbers"))
    end
    
    if n <= 1
        return n
    end
    
    # Efficient iterative implementation
    a, b = 0, 1
    for _ in 2:n
        a, b = b, a + b
    end
    
    return b
end

"""
    compute_prime_numbers(limit::Int) -> Vector{Int}

Compute all prime numbers up to the given limit using the Sieve of Eratosthenes.

This function showcases Julia's array processing capabilities and can be used
for mathematical computations in the Flutter application.

# Arguments
- `limit::Int`: The upper bound for prime number generation (must be > 1)

# Returns
- A vector containing all prime numbers up to the limit

# Example
```julia
primes = compute_prime_numbers(20)  # Returns [2, 3, 5, 7, 11, 13, 17, 19]
```

# Performance
- Time complexity: O(n log log n)
- Space complexity: O(n)
"""
function compute_prime_numbers(limit::Int)::Vector{Int}
    if limit < 2
        throw(ArgumentError("Limit must be at least 2"))
    end
    
    # Sieve of Eratosthenes
    is_prime = trues(limit)
    is_prime[1] = false  # 1 is not prime
    
    for i in 2:isqrt(limit)
        if is_prime[i]
            for j in i*i:i:limit
                is_prime[j] = false
            end
        end
    end
    
    return findall(is_prime)
end

"""
    matrix_multiply(A::Matrix{Float64}, B::Matrix{Float64}) -> Matrix{Float64}

Perform matrix multiplication using Julia's optimized BLAS routines.

This function demonstrates Julia's high-performance linear algebra capabilities
that can be leveraged from Flutter for scientific computing applications.

# Arguments
- `A::Matrix{Float64}`: First matrix (m × k)
- `B::Matrix{Float64}`: Second matrix (k × n)

# Returns
- The resulting matrix (m × n)

# Example
```julia
A = [1.0 2.0; 3.0 4.0]
B = [5.0 6.0; 7.0 8.0]
C = matrix_multiply(A, B)
```

# Performance
- Uses optimized BLAS routines
- Time complexity: O(m × n × k)
"""
function matrix_multiply(A::Matrix{Float64}, B::Matrix{Float64})::Matrix{Float64}
    if size(A, 2) != size(B, 1)
        throw(ArgumentError("Matrix dimensions must be compatible for multiplication"))
    end
    
    return A * B
end

"""
    statistical_analysis(data::Vector{Float64}) -> NamedTuple

Perform comprehensive statistical analysis on a dataset.

This function demonstrates Julia's statistical computing capabilities,
providing multiple statistical measures in a single call.

# Arguments
- `data::Vector{Float64}`: Input dataset

# Returns
- Named tuple containing statistical measures:
  - `mean`: Arithmetic mean
  - `median`: Median value
  - `std`: Standard deviation
  - `min`: Minimum value
  - `max`: Maximum value
  - `count`: Number of elements

# Example
```julia
data = [1.0, 2.0, 3.0, 4.0, 5.0]
stats = statistical_analysis(data)
println("Mean: ", stats.mean)
```

# Performance
- Single-pass algorithms where possible
- Time complexity: O(n)
"""
function statistical_analysis(data::Vector{Float64})::NamedTuple
    if isempty(data)
        throw(ArgumentError("Data vector cannot be empty"))
    end
    
    n = length(data)
    mean_val = sum(data) / n
    
    # Calculate standard deviation
    variance = sum((x - mean_val)^2 for x in data) / (n - 1)
    std_val = sqrt(variance)
    
    # Calculate median
    sorted_data = sort(data)
    median_val = if n % 2 == 0
        (sorted_data[n ÷ 2] + sorted_data[n ÷ 2 + 1]) / 2
    else
        sorted_data[n ÷ 2 + 1]
    end
    
    return (
        mean = mean_val,
        median = median_val,
        std = std_val,
        min = minimum(data),
        max = maximum(data),
        count = n
    )
end

"""
    cleanup_julia_lib() -> Bool

Clean up resources and properly shut down the Julia library.

This function should be called when the application is shutting down
to ensure proper cleanup of resources and memory.

# Returns
- `true` if cleanup was successful
- `false` if cleanup failed

# Example
```julia
cleanup_julia_lib()
```
"""
function cleanup_julia_lib()::Bool
    try
        if !_initialized[]
            return true  # Already cleaned up
        end
        
        # Clean up any global resources
        _initialized[] = false
        _lib_handle[] = C_NULL
        
        return true
    catch e
        @error "Failed to cleanup Julia library" exception = e
        return false
    end
end

# C-compatible function exports for FFI
"""
    julia_greet(name::Cstring) -> Cstring

C-compatible wrapper for greeting functionality.
This function is designed to be called from C/FFI interfaces.

# Arguments
- `name::Cstring`: Name to greet (C string)

# Returns
- Greeting message as C string

# Note
- Memory management must be handled by the caller
- This is a simplified example for FFI demonstration
"""
function julia_greet(name::Cstring)::Cstring
    name_str = unsafe_string(name)
    greeting = "Hello from Julia, $(name_str)!"
    return Base.unsafe_convert(Cstring, greeting)
end

# Export C-compatible functions
export julia_greet

end # module
