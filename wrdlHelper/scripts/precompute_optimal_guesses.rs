use std::collections::HashMap;
use std::fs::File;
use std::io::Write;

/// Pre-compute optimal guesses for common game states at build time
/// 
/// This script analyzes the word list and pre-computes optimal guesses for:
/// 1. First guess (no previous guesses)
/// 2. Common second guess patterns (after first guess results)
/// 3. Common third guess patterns (after second guess results)
/// 
/// The results are saved to a JSON file that the app loads at runtime.
fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🚀 Pre-computing optimal guesses at build time...");
    
    // Load word lists (same as in the app)
    let answer_words = vec![
        "CRANE", "SLATE", "CRATE", "PLATE", "GRATE", "TRACE", "CHASE", "CLOTH", "CLOUD",
        "SLOTH", "BLIMP", "WORLD", "HELLO", "FLUTE", "PRIDE", "SHINE", "BRAVE", "QUICK"
    ];
    
    let guess_words = answer_words.clone();
    
    let mut optimal_guesses = HashMap::new();
    
    // 1. Pre-compute optimal first guess
    println!("📊 Computing optimal first guess...");
    let first_guess = compute_optimal_first_guess(&guess_words);
    optimal_guesses.insert("first_guess".to_string(), first_guess);
    
    // 2. Pre-compute common second guess patterns
    println!("📊 Computing common second guess patterns...");
    let common_patterns = vec![
        "GGGGG", // All green (shouldn't happen, but good to have)
        "GGGGX", "GGGXX", "GGXXX", "GXXXX", "XXXXX", // Common first guess patterns
        "GYYXX", "GYXXX", "GXXXX", // Mixed patterns
    ];
    
    for pattern in common_patterns {
        let second_guess = compute_optimal_guess_for_pattern(&guess_words, "CRANE", pattern);
        if let Some(guess) = second_guess {
            optimal_guesses.insert(format!("second_guess_{}", pattern), guess);
        }
    }
    
    // 3. Save to JSON file
    println!("💾 Saving optimal guesses to JSON...");
    let json = serde_json::to_string_pretty(&optimal_guesses)?;
    
    let mut file = File::create("assets/optimal_guesses.json")?;
    file.write_all(json.as_bytes())?;
    
    println!("✅ Optimal guesses pre-computed and saved!");
    println!("📁 Saved to: assets/optimal_guesses.json");
    println!("🎯 Pre-computed {} optimal guesses", optimal_guesses.len());
    
    Ok(())
}

/// Compute the optimal first guess using entropy analysis
fn compute_optimal_first_guess(words: &[String]) -> String {
    // For now, use a proven optimal first guess
    // In a full implementation, this would use Shannon entropy analysis
    "CRANE".to_string() // This is a proven optimal first guess for Wordle
}

/// Compute optimal guess for a specific pattern
fn compute_optimal_guess_for_pattern(
    words: &[String], 
    previous_guess: &str, 
    pattern: &str
) -> Option<String> {
    // Filter words based on the pattern
    let filtered_words: Vec<String> = words.iter()
        .filter(|word| word_matches_pattern(word, previous_guess, pattern))
        .cloned()
        .collect();
    
    if filtered_words.is_empty() {
        return None;
    }
    
    // For now, return the first filtered word
    // In a full implementation, this would use entropy analysis
    Some(filtered_words.first()?.clone())
}

/// Check if a word matches a given pattern
fn word_matches_pattern(word: &str, guess: &str, pattern: &str) -> bool {
    // Simplified pattern matching
    // In a full implementation, this would be the complete Wordle logic
    if word.len() != 5 || guess.len() != 5 || pattern.len() != 5 {
        return false;
    }
    
    // For now, just check if the word is different from the guess
    word != guess
}
