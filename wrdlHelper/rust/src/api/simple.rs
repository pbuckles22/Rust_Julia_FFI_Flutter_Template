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

use crate::api::wrdl_helper::{IntelligentSolver, GuessResult, LetterResult, WORD_MANAGER};
use crate::api::wrdl_helper_reference::IntelligentSolver as ReferenceSolver;


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










// ============================================================================
// wrdlHelper Intelligent Solver FFI Functions
// ============================================================================

/**
 * Initialize word lists in Rust (call once at startup)
 * 
 * This function loads word lists directly from Rust assets, eliminating
 * the need for Flutter to manage word lists. Centralizes all word list
 * management in Rust for better performance and consistency.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn initialize_word_lists() -> Result<(), String> {
    use crate::api::wrdl_helper::WORD_MANAGER;
    
    let mut manager = WORD_MANAGER.lock().map_err(|e| format!("Failed to lock word manager: {}", e))?;
    
    // Load word lists directly from Rust assets (same as benchmark)
    let answer_words = load_answer_words_from_assets()?;
    let guess_words = load_guess_words_from_assets()?;
    
    manager.answer_words = answer_words;
    manager.guess_words = guess_words;
    manager.compute_optimal_first_guess();
    
    println!("✅ Rust loaded {} answer words and {} guess words directly from assets", 
             manager.answer_words.len(), 
             manager.guess_words.len());
    
    Ok(())
}

/// Load answer words directly from Rust assets (same as benchmark)
fn load_answer_words_from_assets() -> Result<Vec<String>, String> {
    let word_list_path = "assets/word_lists/official_wordle_words.json";
    
    if std::path::Path::new(word_list_path).exists() {
        let content = std::fs::read_to_string(word_list_path)
            .map_err(|e| format!("Failed to read word list file: {}", e))?;
        let word_data: serde_json::Value = serde_json::from_str(&content)
            .map_err(|e| format!("Failed to parse JSON: {}", e))?;
        
        if let Some(answers) = word_data.get("answer_words").and_then(|v| v.as_array()) {
            let answer_words: Vec<String> = answers
                .iter()
                .filter_map(|v| v.as_str().map(|s| s.to_uppercase()))
                .collect();
            println!("📚 Loaded {} answer words from {}", answer_words.len(), word_list_path);
            return Ok(answer_words);
        }
    }
    
    Err(format!("Failed to load answer words from {}", word_list_path))
}

/// Load guess words directly from Rust assets (same as benchmark)
fn load_guess_words_from_assets() -> Result<Vec<String>, String> {
    let word_list_path = "assets/word_lists/official_guess_words.txt";
    
    if std::path::Path::new(word_list_path).exists() {
        let content = std::fs::read_to_string(word_list_path)
            .map_err(|e| format!("Failed to read word list file: {}", e))?;
        
        let all_words: Vec<String> = content
            .lines()
            .map(|line| line.trim().to_uppercase())
            .filter(|word| !word.is_empty() && word.len() == 5)
            .collect();
        
        println!("📚 Loaded {} guess words from {}", all_words.len(), word_list_path);
        return Ok(all_words);
    }
    
    Err(format!("Failed to load guess words from {}", word_list_path))
}

/**
 * Load word lists from Dart to Rust (call after Dart loads word lists)
 * 
 * This function receives the actual word lists from Dart and stores them in Rust
 * for optimal performance. This replaces the hardcoded 18 words with the full
 * 15k+ word lists.
 * 
 * # Arguments
 * - `answer_words`: The 2,315 answer words from official_wordle_words.json
 * - `guess_words`: The 14,854+ guess words from official_guess_words.txt
 * 
 * # Performance
 * - This is called once at startup after Dart loads the word lists
 * - Subsequent calls to get_intelligent_guess_fast() will use these full lists
 */
#[flutter_rust_bridge::frb(sync)]
pub fn load_word_lists_from_dart(
    answer_words: Vec<String>,
    guess_words: Vec<String>,
) -> Result<(), String> {
    use crate::api::wrdl_helper::WORD_MANAGER;
    
    let mut manager = WORD_MANAGER.lock().map_err(|e| format!("Failed to lock word manager: {}", e))?;
    
    // Store the actual word lists from Dart
    manager.answer_words = answer_words;
    manager.guess_words = guess_words;
    
    // Recompute optimal first guess with the full word list
    manager.compute_optimal_first_guess();
    
    println!("✅ Rust loaded {} answer words and {} guess words", 
             manager.answer_words.len(), 
             manager.guess_words.len());
    
    Ok(())
}

/**
 * Get answer words from Rust (centralized word list management)
 * 
 * This function returns the answer words that are managed by Rust,
 * eliminating the need for Flutter to manage word lists.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_answer_words() -> Result<Vec<String>, String> {
    use crate::api::wrdl_helper::WORD_MANAGER;
    
    let manager = WORD_MANAGER.lock().map_err(|e| format!("Failed to lock word manager: {}", e))?;
    Ok(manager.get_answer_words().to_vec())
}

/**
 * Get guess words from Rust (centralized word list management)
 * 
 * This function returns the guess words that are managed by Rust,
 * eliminating the need for Flutter to manage word lists.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_guess_words() -> Result<Vec<String>, String> {
    use crate::api::wrdl_helper::WORD_MANAGER;
    
    let manager = WORD_MANAGER.lock().map_err(|e| format!("Failed to lock word manager: {}", e))?;
    Ok(manager.get_guess_words().to_vec())
}

/**
 * Check if a word is valid (centralized validation)
 * 
 * This function checks if a word exists in the Rust-managed word lists,
 * eliminating the need for Flutter to manage word validation.
 */
#[flutter_rust_bridge::frb(sync)]
pub fn is_valid_word(word: String) -> bool {
    use crate::api::wrdl_helper::WORD_MANAGER;
    
    // Normalize to uppercase and validate format
    let normalized_word = word.to_uppercase();
    if normalized_word.len() != 5 || !normalized_word.chars().all(|c| c.is_ascii_alphabetic()) {
        return false;
    }
    
    if let Ok(manager) = WORD_MANAGER.lock() {
        // Check if word is in guess words (all valid words for guessing)
        manager.get_guess_words().contains(&normalized_word)
    } else {
        false
    }
}

/**
 * Get intelligent guess using advanced algorithms (optimized version)
 * 
 * This function uses the wrdlHelper intelligent solver with Rust-managed word lists
 * to avoid passing large data structures across FFI. Much faster than the original.
 * 
 * # Arguments
 * - `remaining_words`: Words that are still possible given current constraints
 * - `guess_results`: Previous guess results with patterns
 * 
 * # Returns
 * The best word to guess next, or None if no valid guesses remain
 * 
 * # Performance
 * - Time complexity: O(n*m) where n is candidate words, m is remaining words
 * - Space complexity: O(n) for pattern analysis
 * - Target response time: < 200ms (much faster with Rust-managed words)
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_intelligent_guess_fast(
    remaining_words: Vec<String>,
    guess_results: Vec<(String, Vec<String>)>, // (word, pattern) where pattern is ["G", "Y", "X", ...]
) -> Option<String> {
    use crate::api::wrdl_helper::{WORD_MANAGER, IntelligentSolver};
    
    if remaining_words.is_empty() {
        return None;
    }

    // Get words from global manager
    let manager = WORD_MANAGER.lock().ok()?;
    let all_words = manager.get_guess_words().to_vec();
    drop(manager); // Release lock early
    
    let solver = IntelligentSolver::new(all_words);
    
    // Convert FFI guess results to internal format
    let mut internal_guess_results = Vec::new();
    for (word, pattern) in guess_results {
        let mut results = Vec::new();
        for letter_result in pattern {
            // Accept both compact (G,Y,X) and verbose (Green, Yellow, Gray), case-insensitive
            let lr = letter_result.to_uppercase();
            let result = match lr.as_str() {
                "G" | "GREEN" => LetterResult::Green,
                "Y" | "YELLOW" => LetterResult::Yellow,
                "X" | "GRAY" | "GREY" => LetterResult::Gray,
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
 * Get intelligent guess using the REFERENCE algorithm (99.8% success rate)
 * 
 * This function uses the exact same algorithm that achieved 99.8% success rate
 * in the Rust benchmark. This is the high-performance reference implementation.
 * 
 * # Arguments
 * - `remaining_words`: Words that are still possible given current constraints
 * - `guess_results`: Previous guess results with patterns
 * 
 * # Returns
 * The best word to guess next, or None if no valid guesses remain
 * 
 * # Performance
 * - Time complexity: O(n*m) where n is candidate words, m is remaining words
 * - Space complexity: O(n) for pattern analysis
 * - Target response time: < 200ms
 * - Success rate: 99.8% (matches Rust benchmark)
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_intelligent_guess_reference(
    remaining_words: Vec<String>,
    guess_results: Vec<(String, Vec<String>)>, // (word, pattern) where pattern is ["G", "Y", "X", ...]
) -> Option<String> {
    if remaining_words.is_empty() {
        return None;
    }

    // Get words from global manager to match the benchmark approach
    let manager = WORD_MANAGER.lock().ok()?;
    let all_words = manager.get_guess_words().to_vec();
    drop(manager); // Release lock early
    
    let solver = ReferenceSolver::new(all_words);
    
    // Convert FFI guess results to internal format
    let mut internal_guess_results = Vec::new();
    for (word, pattern) in guess_results {
        let mut results = Vec::new();
        for letter_result in pattern {
            // Accept both compact (G,Y,X) and verbose (Green, Yellow, Gray), case-insensitive
            let lr = letter_result.to_uppercase();
            let result = match lr.as_str() {
                "G" | "GREEN" => LetterResult::Green,
                "Y" | "YELLOW" => LetterResult::Yellow,
                "X" | "GRAY" | "GREY" => LetterResult::Gray,
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
 * Get the optimal first guess (pre-computed at startup)
 * 
 * This function returns the optimal first guess that was computed once at startup.
 * This avoids the expensive computation of analyzing all 14,854 words for the first guess.
 * 
 * # Returns
 * The optimal first guess word, or None if not computed yet
 * 
 * # Performance
 * - Time complexity: O(1) - just a lookup
 * - Space complexity: O(1) - cached value
 * - Target response time: < 1ms
 */
#[flutter_rust_bridge::frb(sync)]
pub fn get_optimal_first_guess() -> Option<String> {
    use crate::api::wrdl_helper::WORD_MANAGER;
    
    let manager = WORD_MANAGER.lock().ok()?;
    manager.get_optimal_first_guess()
}

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

/**
 * Set solver configuration
 * 
 * This function sets the global solver configuration for all subsequent operations.
 * 
 * # Arguments
 * - `config`: Configuration struct with all solver settings
 * 
 * # Performance
 * - Time complexity: O(1)
 * - Space complexity: O(1)
 */
#[flutter_rust_bridge::frb(sync)]
pub fn set_solver_config(
    reference_mode: bool,
    include_killer_words: bool,
    candidate_cap: i32,
    early_termination_enabled: bool,
    early_termination_threshold: f64,
    entropy_only_scoring: bool,
) {
    use crate::api::wrdl_helper::{SOLVER_CONFIG, SolverConfig};
    
    let mut config = SOLVER_CONFIG.lock().unwrap();
    *config = SolverConfig {
        reference_mode,
        include_killer_words,
        candidate_cap,
        early_termination_enabled,
        early_termination_threshold,
        entropy_only_scoring,
    };
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

    #[test]
    fn test_word_filtering_debug() {
        use crate::api::wrdl_helper::{IntelligentSolver, GuessResult, LetterResult};
        
        // Use words that don't contain C,R,A,N,E for all-gray test
        let words = vec!["CRANE".to_string(), "SLOTH".to_string(), "BLIMP".to_string()];
        let solver = IntelligentSolver::new(words.clone());
        
        // Test all gray pattern - target should not contain C,R,A,N,E
        let guess_result = GuessResult::new("CRANE".to_string(), [
            LetterResult::Gray,
            LetterResult::Gray,
            LetterResult::Gray,
            LetterResult::Gray,
            LetterResult::Gray,
        ]);
        
        println!("Testing all gray pattern for CRANE");
        println!("Words: {:?}", words);
        
        for word in &words {
            let matches = solver.word_matches_pattern(word, &guess_result);
            println!("Word '{}' matches pattern: {}", word, matches);
        }
        
        let filtered = solver.filter_words(&words, &[guess_result]);
        println!("Filtered words: {:?}", filtered);
        
        // Should return SLOTH and BLIMP (don't contain C,R,A,N,E)
        assert_eq!(filtered, vec!["SLOTH".to_string(), "BLIMP".to_string()]);
    }

    #[test]
    fn test_word_filtering_partial_gray_debug() {
        use crate::api::wrdl_helper::{IntelligentSolver, GuessResult, LetterResult};
        
        // Test GXXXX pattern (C=Green, R,A,N,E=Gray)
        // Need words that start with C but don't contain R,A,N,E
        let words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string(), "CHASE".to_string(), "CLOTH".to_string(), "CLOUD".to_string()];
        let solver = IntelligentSolver::new(words.clone());
        
        let guess_result = GuessResult::new("CRANE".to_string(), [
            LetterResult::Green,  // C
            LetterResult::Gray,   // R
            LetterResult::Gray,   // A
            LetterResult::Gray,   // N
            LetterResult::Gray,   // E
        ]);
        
        println!("Testing GXXXX pattern for CRANE");
        println!("Words: {:?}", words);
        println!("Pattern: C=Green, R,A,N,E=Gray");
        println!("Guess word: CRANE");
        println!();
        
        for word in &words {
            let matches = solver.word_matches_pattern(word, &guess_result);
            println!("Word '{}' matches pattern GXXXX: {}", word, matches);
            
            // Debug each step for valid words
            if word.starts_with('C') {
                println!("  Debugging {}:", word);
                println!("  - {}[0] = '{}', should be 'C' (Green): {}", word, word.chars().nth(0).unwrap(), word.chars().nth(0).unwrap() == 'C');
                println!("  - {} contains 'R': {}", word, word.contains('R'));
                println!("  - {} contains 'A': {}", word, word.contains('A'));
                println!("  - {} contains 'N': {}", word, word.contains('N'));
                println!("  - {} contains 'E': {}", word, word.contains('E'));
            }
        }
        
        let filtered = solver.filter_words(&words, &[guess_result]);
        println!("Filtered words: {:?}", filtered);
        
        // Should return words that start with C and don't contain R,A,N,E
        // CLOTH and CLOUD should be valid
        assert!(filtered.contains(&"CLOTH".to_string()));
        assert!(filtered.contains(&"CLOUD".to_string()));
        assert!(!filtered.contains(&"CRANE".to_string())); // Contains R,A,N,E
        assert!(!filtered.contains(&"CHASE".to_string())); // Contains A,E
    }
}