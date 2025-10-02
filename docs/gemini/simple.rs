/**
 * Simple API Module for Flutter-Rust FFI Bridge
 * 
 * This module provides basic functionality for demonstrating Flutter-Rust FFI integration.
 * It serves as the foundation for more complex operations and showcases proper
 * FFI bridge patterns and error handling.
 * 
 * # Architecture
 * - Functions are marked with `#[flutter_rust_bridge::frb(sync)]` for synchronous calls
 * - Proper error handling with Result types where appropriate
 * - Memory-safe string handling for FFI boundaries
 * - Comprehensive documentation for all public functions
 * 
 * # Usage
 * These functions are automatically generated as Dart bindings and can be called
 * directly from Flutter/Dart code after proper initialization.
 * 
 * # Performance Considerations
 * - Synchronous functions are suitable for quick operations
 * - For long-running operations, consider async alternatives
 * - Memory allocation is handled automatically by flutter_rust_bridge
 */

use std::collections::HashMap;
use std::time::{SystemTime, UNIX_EPOCH};
use crate::api::wrdl_helper::{IntelligentSolver, GuessResult, LetterResult};

/**
 * Greet a user with a personalized message
 * 
 * This function demonstrates basic string handling across the FFI boundary.
 * It takes a name parameter and returns a formatted greeting string.
 * 
 * # Arguments
 * - `name`: The name of the person to greet
 * 
 * # Returns
 * A formatted greeting string
 * 
 * # Example
 * ```rust
 * let greeting = greet("Alice".to_string());
 * assert_eq!(greeting, "Hello, Alice!");
 * ```
 * 
 * # Performance
 * - Time complexity: O(1)
 * - Space complexity: O(n) where n is the length of the name
 */
#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

/**
 * Initialize the application with default utilities
 * 
 * This function sets up the flutter_rust_bridge with default user utilities.
 * It should be called once during application startup before any other
 * FFI functions are used.
 * 
 * # Safety
 * This function is safe to call multiple times, but it's recommended
 * to call it only once during application initialization.
 * 
 * # Example
 * ```rust
 * init_app(); // Call this during app startup
 * ```
 */
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

/**
 * Add two integers and return the result
 * 
 * Demonstrates basic arithmetic operations across the FFI boundary.
 * This function showcases how to handle primitive types in FFI calls.
 * 
 * # Arguments
 * - `a`: First integer
 * - `b`: Second integer
 * 
 * # Returns
 * The sum of a and b
 * 
 * # Example
 * ```rust
 * let result = add_numbers(5, 3);
 * assert_eq!(result, 8);
 * ```
 * 
 * # Performance
 * - Time complexity: O(1)
 * - Space complexity: O(1)
 */
#[flutter_rust_bridge::frb(sync)]
pub fn add_numbers(a: i32, b: i32) -> Option<i32> {
    a.checked_add(b)
}

/**
 * Multiply two floating-point numbers
 * 
 * Demonstrates floating-point arithmetic across the FFI boundary.
 * Useful for mathematical computations that need to be performed in Rust
 * for performance reasons.
 * 
 * # Arguments
 * - `a`: First floating-point number
 * - `b`: Second floating-point number
 * 
 * # Returns
 * The product of a and b
 * 
 * # Example
 * ```rust
 * let result = multiply_floats(2.5, 4.0);
 * assert_eq!(result, 10.0);
 * ```
 * 
 * # Performance
 * - Time complexity: O(1)
 * - Space complexity: O(1)
 */
#[flutter_rust_bridge::frb(sync)]
pub fn multiply_floats(a: f64, b: f64) -> f64 {
    a * b
}

/**
 * Check if a number is even
 * 
 * Demonstrates boolean return types across the FFI boundary.
 * This function showcases conditional logic and boolean operations.
 * 
 * # Arguments
 * - `number`: The integer to check
 * 
 * # Returns
 * `true` if the number is even, `false` otherwise
 * 
 * # Example
 * ```rust
 * assert!(is_even(4));
 * assert!(!is_even(3));
 * ```
 * 
 * # Performance
 * - Time complexity: O(1)
 * - Space complexity: O(1)
 */
#[flutter_rust_bridge::frb(sync)]
pub fn is_even(number: i32) -> bool {
    number % 2 == 0
}

/**
 * Get current timestamp as milliseconds since Unix epoch
 * 
 * Demonstrates system time access across the FFI boundary.
 * This function can be useful for logging, caching, or time-based operations.
 * 
 * # Returns
 * Current timestamp in milliseconds since Unix epoch
 * 
 * # Example
 * ```rust
 * let timestamp = get_current_timestamp();
 * assert!(timestamp > 0);
 * ```
 * 
 * # Performance
 * - Time complexity: O(1)
 * - Space complexity: O(1)
 * 
 * # Errors
 * This function can panic if the system time is before Unix epoch,
 * which is extremely unlikely in practice.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_current_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards")
        .as_millis() as u64
}

/**
 * Process a list of strings and return their lengths
 * 
 * Demonstrates vector/array handling across the FFI boundary.
 * This function showcases how to work with collections in FFI calls.
 * 
 * # Arguments
 * - `strings`: Vector of strings to process
 * 
 * # Returns
 * Vector of string lengths
 * 
 * # Example
 * ```rust
 * let strings = vec!["hello".to_string(), "world".to_string()];
 * let lengths = get_string_lengths(strings);
 * assert_eq!(lengths, vec![5, 5]);
 * ```
 * 
 * # Performance
 * - Time complexity: O(n) where n is the number of strings
 * - Space complexity: O(n) for the result vector
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_string_lengths(strings: Vec<String>) -> Vec<u32> {
    strings.iter().map(|s| s.len() as u32).collect()
}

/**
 * Create a simple key-value mapping
 * 
 * Demonstrates HashMap handling across the FFI boundary.
 * This function showcases how to work with complex data structures in FFI calls.
 * 
 * # Arguments
 * - `pairs`: Vector of (key, value) tuples
 * 
 * # Returns
 * HashMap containing the key-value pairs
 * 
 * # Example
 * ```rust
 * let pairs = vec![("name".to_string(), "Alice".to_string())];
 * let map = create_string_map(pairs);
 * assert_eq!(map.get("name"), Some(&"Alice".to_string()));
 * ```
 * 
 * # Performance
 * - Time complexity: O(n) where n is the number of pairs
 * - Space complexity: O(n) for the HashMap
 */
#[flutter_rust_bridge::frb(sync)]
pub fn create_string_map(pairs: Vec<(String, String)>) -> HashMap<String, String> {
    pairs.into_iter().collect()
}

/**
 * Calculate the factorial of a number
 * 
 * Demonstrates recursive algorithms across the FFI boundary.
 * This function showcases mathematical computations that can benefit
 * from Rust's performance characteristics.
 * 
 * # Arguments
 * - `n`: The number to calculate factorial for (must be >= 0)
 * 
 * # Returns
 * The factorial of n
 * 
 * # Example
 * ```rust
 * assert_eq!(factorial(5), 120);
 * assert_eq!(factorial(0), 1);
 * ```
 * 
 * # Performance
 * - Time complexity: O(n)
 * - Space complexity: O(n) due to recursion
 * 
 * # Panics
 * This function will panic if n is negative due to integer overflow.
 * In a production environment, consider using a Result type instead.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn factorial(n: u32) -> u32 {
    match n {
        0 | 1 => 1,
        _ => n * factorial(n - 1),
    }
}

/**
 * Check if a string is a palindrome
 * 
 * Demonstrates string manipulation and algorithm implementation
 * across the FFI boundary. This function showcases text processing
 * capabilities that can be efficiently implemented in Rust.
 * 
 * # Arguments
 * - `text`: The string to check
 * 
 * # Returns
 * `true` if the string is a palindrome, `false` otherwise
 * 
 * # Example
 * ```rust
 * assert!(is_palindrome("racecar".to_string()));
 * assert!(!is_palindrome("hello".to_string()));
 * ```
 * 
 * # Performance
 * - Time complexity: O(n) where n is the length of the string
 * - Space complexity: O(1) for the optimized version
 * 
 * # Note
 * This implementation is case-sensitive and does not ignore whitespace.
 * For a more robust implementation, consider normalizing the input.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn is_palindrome(text: String) -> bool {
    let chars: Vec<char> = text.chars().collect();
    let len = chars.len();
    
    for i in 0..len / 2 {
        if chars[i] != chars[len - 1 - i] {
            return false;
        }
    }
    
    true
}

/**
 * Generate a simple hash for a string
 * 
 * Demonstrates hashing algorithms across the FFI boundary.
 * This function showcases cryptographic or data integrity operations
 * that can be efficiently implemented in Rust.
 * 
 * # Arguments
 * - `input`: The string to hash
 * 
 * # Returns
 * A simple hash value as u32
 * 
 * # Example
 * ```rust
 * let hash1 = simple_hash("hello".to_string());
 * let hash2 = simple_hash("hello".to_string());
 * assert_eq!(hash1, hash2);
 * ```
 * 
 * # Performance
 * - Time complexity: O(n) where n is the length of the string
 * - Space complexity: O(1)
 * 
 * # Security Note
 * This is a simple hash function for demonstration purposes.
 * For cryptographic applications, use a proper hash function like SHA-256.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn simple_hash(input: String) -> u32 {
    let mut hash: u32 = 0;
    
    for byte in input.bytes() {
        hash = hash.wrapping_mul(31).wrapping_add(byte as u32);
    }
    
    hash
}

// ============================================================================
// wrdlHelper Intelligent Solver FFI Functions
// ============================================================================

/**
 * Get intelligent word suggestion using advanced algorithms
 * 
 * This function uses Shannon entropy analysis, statistical analysis, and
 * look-ahead strategy to recommend the optimal word for the current game state.
 * 
 * # Arguments
 * - `all_words`: Complete list of valid words
 * - `remaining_words`: Words that could still be the answer
 * - `guess_results`: Previous guess results with patterns
 * 
 * # Returns
 * The best word to guess next, or None if no valid suggestions
 * 
 * # Performance
 * - Time complexity: O(n*m) where n is candidate words, m is remaining words
 * - Space complexity: O(n) for pattern analysis
 * - Target response time: < 200ms
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_intelligent_guess(
    all_words: Vec<String>,
    remaining_words: Vec<String>,
    guess_results: Vec<(String, Vec<String>)>, // (word, pattern) where pattern is ["G", "Y", "X", ...]
) -> Option<String> {
    if remaining_words.is_empty() {
        return None;
    }

    let solver = IntelligentSolver::new(all_words);
    
    // Convert FFI guess results to internal format
    let mut internal_guess_results = Vec::new();
    for (word, pattern) in guess_results {
        let mut results = Vec::new();
        for letter_result in pattern {
            let result = match letter_result.as_str() {
                "G" => LetterResult::Green,
                "Y" => LetterResult::Yellow,
                "X" => LetterResult::Gray,
                _ => LetterResult::Gray, // Default to gray for unknown patterns
            };
            results.push(result);
        }
        internal_guess_results.push(GuessResult::new(word, [
            results[0], results[1], results[2], results[3], results[4]
        ]));
    }
    
    solver.get_best_guess(&remaining_words, &internal_guess_results)
}

/**
 * Filter words based on guess results
 * 
 * This function filters a word list based on previous guess results,
 * removing words that don't match the established patterns.
 * 
 * # Arguments
 * - `words`: List of words to filter
 * - `guess_results`: Previous guess results with patterns
 * 
 * # Returns
 * Filtered list of words that match all patterns
 * 
 * # Performance
 * - Time complexity: O(n*m) where n is words, m is guess results
 * - Space complexity: O(n) for filtered results
 */
#[flutter_rust_bridge::frb(sync)]
pub fn filter_words(
    words: Vec<String>,
    guess_results: Vec<(String, Vec<String>)>, // (word, pattern) where pattern is ["G", "Y", "X", ...]
) -> Vec<String> {
    let solver = IntelligentSolver::new(words.clone());
    
    // Convert FFI guess results to internal format
    let mut internal_guess_results = Vec::new();
    for (word, pattern) in guess_results {
        let mut results = Vec::new();
        for letter_result in pattern {
            let result = match letter_result.as_str() {
                "G" => LetterResult::Green,
                "Y" => LetterResult::Yellow,
                "X" => LetterResult::Gray,
                _ => LetterResult::Gray, // Default to gray for unknown patterns
            };
            results.push(result);
        }
        internal_guess_results.push(GuessResult::new(word, [
            results[0], results[1], results[2], results[3], results[4]
        ]));
    }
    
    solver.filter_words(&words, &internal_guess_results)
}

/**
 * Calculate entropy for a candidate word
 * 
 * This function calculates the Shannon entropy (information gain) for a
 * candidate word against the remaining possible words.
 * 
 * # Arguments
 * - `candidate_word`: The word to analyze
 * - `remaining_words`: Words that could still be the answer
 * 
 * # Returns
 * Entropy value (higher = more information)
 * 
 * # Performance
 * - Time complexity: O(n) where n is remaining words
 * - Space complexity: O(n) for pattern grouping
 */
#[flutter_rust_bridge::frb(sync)]
pub fn calculate_entropy(candidate_word: String, remaining_words: Vec<String>) -> f64 {
    let solver = IntelligentSolver::new(vec![]);
    solver.calculate_entropy(&candidate_word, &remaining_words)
}

/**
 * Simulate guess pattern for testing
 * 
 * This function simulates what pattern would result from guessing
 * a word against a target word.
 * 
 * # Arguments
 * - `guess`: The word being guessed
 * - `target`: The target word
 * 
 * # Returns
 * Pattern string like "GGYXY" (G=Green, Y=Yellow, X=Gray)
 * 
 * # Performance
 * - Time complexity: O(1) for 5-letter words
 * - Space complexity: O(1)
 */
#[flutter_rust_bridge::frb(sync)]
pub fn simulate_guess_pattern(guess: String, target: String) -> String {
    let solver = IntelligentSolver::new(vec![]);
    solver.simulate_guess_pattern(&guess, &target)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_greet() {
        assert_eq!(greet("Alice".to_string()), "Hello, Alice!");
        assert_eq!(greet("Bob".to_string()), "Hello, Bob!");
        assert_eq!(greet("".to_string()), "Hello, !");
    }

    #[test]
    fn test_add_numbers() {
        assert_eq!(add_numbers(5, 3), Some(8));
        assert_eq!(add_numbers(-5, 3), Some(-2));
        assert_eq!(add_numbers(0, 0), Some(0));
        assert_eq!(add_numbers(i32::MAX, 1), None); // Overflow returns None
    }

    #[test]
    fn test_multiply_floats() {
        assert_eq!(multiply_floats(2.5, 4.0), 10.0);
        assert_eq!(multiply_floats(-2.0, 3.0), -6.0);
        assert_eq!(multiply_floats(0.0, 5.0), 0.0);
        assert_eq!(multiply_floats(1.0, 1.0), 1.0);
    }

    #[test]
    fn test_is_even() {
        assert!(is_even(4));
        assert!(is_even(0));
        assert!(is_even(-2));
        assert!(!is_even(3));
        assert!(!is_even(1));
        assert!(!is_even(-1));
    }

    #[test]
    fn test_get_current_timestamp() {
        let timestamp = get_current_timestamp();
        assert!(timestamp > 0);
        
        // Test that timestamp increases over time
        std::thread::sleep(std::time::Duration::from_millis(1));
        let later_timestamp = get_current_timestamp();
        assert!(later_timestamp >= timestamp);
    }

    #[test]
    fn test_get_string_lengths() {
        let strings = vec!["hello".to_string(), "world".to_string(), "".to_string()];
        let lengths = get_string_lengths(strings);
        assert_eq!(lengths, vec![5u32, 5u32, 0u32]);
        
        let empty_vec = vec![];
        let empty_lengths = get_string_lengths(empty_vec);
        assert_eq!(empty_lengths, vec![]);
    }

    #[test]
    fn test_create_string_map() {
        let pairs = vec![
            ("name".to_string(), "Alice".to_string()),
            ("age".to_string(), "30".to_string()),
        ];
        let map = create_string_map(pairs);
        
        assert_eq!(map.get("name"), Some(&"Alice".to_string()));
        assert_eq!(map.get("age"), Some(&"30".to_string()));
        assert_eq!(map.get("nonexistent"), None);
    }

    #[test]
    fn test_factorial() {
        assert_eq!(factorial(0), 1);
        assert_eq!(factorial(1), 1);
        assert_eq!(factorial(2), 2);
        assert_eq!(factorial(3), 6);
        assert_eq!(factorial(4), 24);
        assert_eq!(factorial(5), 120);
        assert_eq!(factorial(10), 3628800);
    }

    #[test]
    fn test_is_palindrome() {
        assert!(is_palindrome("racecar".to_string()));
        assert!(is_palindrome("level".to_string()));
        assert!(is_palindrome("a".to_string()));
        assert!(is_palindrome("".to_string()));
        assert!(is_palindrome("abccba".to_string()));
        
        assert!(!is_palindrome("hello".to_string()));
        assert!(!is_palindrome("world".to_string()));
        assert!(!is_palindrome("abc".to_string()));
    }

    #[test]
    fn test_simple_hash() {
        let hash1 = simple_hash("hello".to_string());
        let hash2 = simple_hash("hello".to_string());
        assert_eq!(hash1, hash2);
        
        let hash3 = simple_hash("world".to_string());
        assert_ne!(hash1, hash3);
        
        // Test empty string
        let empty_hash = simple_hash("".to_string());
        assert_eq!(empty_hash, 0);
    }

    #[test]
    fn test_init_app() {
        // This test ensures init_app doesn't panic
        init_app();
        // If we get here, the function executed successfully
        assert!(true);
    }

    #[test]
    fn test_integration_workflow() {
        // Test a complete workflow using multiple functions
        init_app();
        
        let greeting = greet("TestUser".to_string());
        assert!(greeting.contains("TestUser"));
        
        let sum = add_numbers(10, 20);
        assert_eq!(sum, Some(30));
        
        let product = multiply_floats(2.5, 4.0);
        assert_eq!(product, 10.0);
        
        let is_even_result = is_even(42);
        assert!(is_even_result);
        
        let timestamp = get_current_timestamp();
        assert!(timestamp > 0);
        
        let strings = vec!["test".to_string(), "strings".to_string()];
        let lengths = get_string_lengths(strings);
        assert_eq!(lengths, vec![4u32, 7u32]);
        
        let pairs = vec![("key".to_string(), "value".to_string())];
        let map = create_string_map(pairs);
        assert_eq!(map.get("key"), Some(&"value".to_string()));
        
        let fact = factorial(5);
        assert_eq!(fact, 120);
        
        let palindrome = is_palindrome("racecar".to_string());
        assert!(palindrome);
        
        let hash = simple_hash("test".to_string());
        assert!(hash > 0);
    }

    // ============================================================================
    // wrdlHelper Tests
    // ============================================================================

    #[test]
    fn test_get_intelligent_guess_basic() {
        let all_words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string()];
        let remaining = vec!["CRANE".to_string(), "SLATE".to_string()];
        let guess_results = vec![];
        
        let result = get_intelligent_guess(all_words, remaining, guess_results);
        assert!(result.is_some());
    }

    #[test]
    fn test_filter_words_basic() {
        let words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string()];
        let guess_results = vec![
            ("CRANE".to_string(), vec!["G".to_string(), "Y".to_string(), "X".to_string(), "X".to_string(), "G".to_string()])
        ];
        
        let filtered = filter_words(words, guess_results);
        assert!(filtered.len() < 3);
    }

    #[test]
    fn test_calculate_entropy_basic() {
        let candidate = "CRANE".to_string();
        let remaining = vec!["CRANE".to_string(), "SLATE".to_string()];
        
        let entropy = calculate_entropy(candidate, remaining);
        assert!(entropy >= 0.0);
    }

    #[test]
    fn test_simulate_guess_pattern() {
        let pattern = simulate_guess_pattern("CRANE".to_string(), "CRATE".to_string());
        assert_eq!(pattern, "GGGXG"); // C, R, A match, N doesn't, E matches
        
        let pattern2 = simulate_guess_pattern("CRANE".to_string(), "SLATE".to_string());
        assert_eq!(pattern2, "XXGXG"); // Only A and E match
    }

    #[test]
    fn test_wrdl_helper_integration() {
        // Test complete wrdlHelper workflow
        let all_words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string()];
        let remaining = vec!["CRANE".to_string(), "SLATE".to_string()];
        
        // Test entropy calculation
        let entropy = calculate_entropy("CRANE".to_string(), remaining.clone());
        assert!(entropy >= 0.0);
        
        // Test pattern simulation
        let pattern = simulate_guess_pattern("CRANE".to_string(), "SLATE".to_string());
        assert_eq!(pattern, "XXGXG");
        
        // Test intelligent guess
        let best_guess = get_intelligent_guess(all_words.clone(), remaining.clone(), vec![]);
        assert!(best_guess.is_some());
        
        // Test word filtering
        let guess_results = vec![
            ("CRANE".to_string(), vec!["G".to_string(), "Y".to_string(), "X".to_string(), "X".to_string(), "G".to_string()])
        ];
        let filtered = filter_words(all_words, guess_results);
        assert!(filtered.len() < 3);
    }
}