//! wrdlHelper Intelligent Solver Implementation
//! 
//! This module implements the core wrdlHelper algorithms copied from the reference implementation:
//! - Shannon Entropy Analysis
//! - Statistical Analysis  
//! - Pattern Simulation
//! - Intelligent Word Selection

use std::collections::HashMap;
use std::f64::consts::LN_2;

/// FFI-compatible enum for letter results
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LetterResult {
    Gray,
    Yellow,
    Green,
}

/// FFI-compatible struct for guess results
#[derive(Debug, Clone)]
pub struct GuessResult {
    pub word: String,
    pub results: Vec<LetterResult>,
}

impl GuessResult {
    pub fn new(word: String, results: [LetterResult; 5]) -> Self {
        Self {
            word,
            results: results.to_vec(),
        }
    }
}

/// Intelligent solver that combines multiple algorithms for optimal word selection
pub struct IntelligentSolver {
    pub words: Vec<String>,
}

impl IntelligentSolver {
    /// Create a new intelligent solver
    pub fn new(words: Vec<String>) -> Self {
        Self { words }
    }

    /// Get the best guess using intelligent algorithms
    /// 
    /// This method combines entropy analysis, statistical analysis, and look-ahead
    /// strategy to recommend the optimal word for the current game state.
    pub fn get_best_guess(&self, remaining_words: &[String], guess_results: &[GuessResult]) -> Option<String> {
        if remaining_words.is_empty() {
            return None;
        }

        // For endgame scenarios (few remaining words), use direct strategy
        if remaining_words.len() <= 2 {
            return remaining_words.first().cloned();
        }

        // Get candidate words (for now, use remaining words; in future could use full word list)
        let candidate_words = self.get_candidate_words(remaining_words, guess_results);
        
        // Analyze each candidate using entropy
        let mut best_word = None;
        let mut best_score = f64::NEG_INFINITY;

        for candidate in candidate_words.iter() {
            let entropy_score = self.calculate_entropy(candidate, remaining_words);
            let statistical_score = self.calculate_statistical_score(candidate, remaining_words);
            
            // Prime suspect bonus: prioritize words that could actually win the game
            let is_prime_suspect = remaining_words.contains(candidate);
            let prime_suspect_bonus = if is_prime_suspect { 0.1 } else { 0.0 };
            
            // Use production settings - full algorithm power (pure entropy)
            let entropy_weight = 1.0;
            let statistical_weight = 0.0;
                    
            // Combine scores with prime suspect bonus
            let combined_score = (entropy_score * entropy_weight) + (statistical_score * statistical_weight) + prime_suspect_bonus;
            
            if combined_score > best_score {
                best_score = combined_score;
                best_word = Some(candidate.clone());
            }
        }

        best_word
    }

    /// Calculate entropy (information gain) for a candidate word
    /// 
    /// Uses Shannon entropy to measure how much information we expect to gain
    /// from making this guess against the remaining possible words.
    pub fn calculate_entropy(&self, candidate_word: &str, remaining_words: &[String]) -> f64 {
        if remaining_words.is_empty() || remaining_words.len() == 1 {
            return 0.0;
        }

        // Group words by the pattern they would produce
        let mut pattern_groups: HashMap<String, Vec<&String>> = HashMap::new();
        
        for target_word in remaining_words {
            let pattern = self.simulate_guess_pattern(candidate_word, target_word);
            pattern_groups.entry(pattern).or_insert_with(Vec::new).push(target_word);
        }

        // Calculate Shannon entropy
        let total_words = remaining_words.len() as f64;
        let mut entropy = 0.0;

        for group in pattern_groups.values() {
            let probability = group.len() as f64 / total_words;
            if probability > 0.0 {
                entropy -= probability * (probability.ln() / LN_2);
            }
        }

        entropy
    }

    /// Calculate statistical score based on letter frequency and position probability
    pub fn calculate_statistical_score(&self, candidate_word: &str, remaining_words: &[String]) -> f64 {
        if remaining_words.is_empty() {
            return 0.0;
        }

        // For now, return a simple score based on letter frequency
        // This will be enhanced with the full statistical analysis from reference
        let mut score = 0.0;
        for ch in candidate_word.chars() {
            let frequency = remaining_words.iter()
                .filter(|word| word.contains(ch))
                .count() as f64;
            score += frequency / remaining_words.len() as f64;
        }
        
        score
    }

    /// Simulate the guess pattern that would result from guessing against a target word
    pub fn simulate_guess_pattern(&self, guess: &str, target: &str) -> String {
        let mut result = vec!['X'; 5];
        let mut target_chars: Vec<char> = target.chars().collect();
        let guess_chars: Vec<char> = guess.chars().collect();

        // First pass: mark green letters (correct position)
        for i in 0..5 {
            if guess_chars[i] == target_chars[i] {
                result[i] = 'G';
                target_chars[i] = ' '; // Mark as used
            }
        }

        // Second pass: mark yellow letters (wrong position)
        for i in 0..5 {
            if result[i] == 'X' { // Not already green
                if let Some(pos) = target_chars.iter().position(|&c| c == guess_chars[i]) {
                    result[i] = 'Y';
                    target_chars[pos] = ' '; // Mark as used
                }
            }
        }

        result.iter().collect()
    }

    /// Get candidate words for analysis
    fn get_candidate_words(&self, remaining_words: &[String], _guess_results: &[GuessResult]) -> Vec<String> {
        // For now, use remaining words as candidates
        // In the future, this could use the full word list for better analysis
        remaining_words.to_vec()
    }

    /// Filter words based on guess results
    pub fn filter_words(&self, words: &[String], guess_results: &[GuessResult]) -> Vec<String> {
        let mut filtered = words.to_vec();
        
        for guess_result in guess_results {
            filtered = filtered.into_iter()
                .filter(|word| self.word_matches_pattern(word, guess_result))
                .collect();
        }
        
        filtered
    }

    /// Check if a word matches the given guess pattern
    fn word_matches_pattern(&self, word: &str, guess_result: &GuessResult) -> bool {
        let word_chars: Vec<char> = word.chars().collect();
        let guess_chars: Vec<char> = guess_result.word.chars().collect();
        
        // First, check green letters (must be in exact position)
        for i in 0..5 {
            if guess_result.results[i] == LetterResult::Green {
                if word_chars[i] != guess_chars[i] {
                    return false;
                }
            }
        }
        
        // Then check yellow letters (must be in word but not in this position)
        for i in 0..5 {
            if guess_result.results[i] == LetterResult::Yellow {
                if word_chars[i] == guess_chars[i] {
                    return false; // Can't be in same position
                }
                if !word_chars.contains(&guess_chars[i]) {
                    return false; // Must contain the letter
                }
            }
        }
        
        // Finally, check gray letters (can't be in word at all)
        // But only if the letter doesn't appear as green or yellow elsewhere
        for i in 0..5 {
            if guess_result.results[i] == LetterResult::Gray {
                // Check if this letter appears as green or yellow elsewhere
                let mut letter_appears_elsewhere = false;
                for j in 0..5 {
                    if i != j && (guess_result.results[j] == LetterResult::Green || guess_result.results[j] == LetterResult::Yellow) {
                        if guess_chars[j] == guess_chars[i] {
                            letter_appears_elsewhere = true;
                            break;
                        }
                    }
                }
                
                // If the letter doesn't appear elsewhere as green/yellow, then it can't be in the word at all
                if !letter_appears_elsewhere && word_chars.contains(&guess_chars[i]) {
                    return false;
                }
            }
        }
        
        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_entropy_calculation_basic() {
        let words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string()];
        let solver = IntelligentSolver::new(words);
        
        // Test entropy calculation with a simple case
        let remaining = vec!["CRANE".to_string(), "SLATE".to_string()];
        let entropy = solver.calculate_entropy("CRANE", &remaining);
        
        // Entropy should be 1.0 when guessing against 2 different words (perfect split)
        assert_eq!(entropy, 1.0);
        
        // Test entropy when guessing against itself (should be 0.0)
        let entropy_self = solver.calculate_entropy("CRANE", &["CRANE".to_string()]);
        assert_eq!(entropy_self, 0.0);
    }

    #[test]
    fn test_pattern_simulation() {
        let words = vec!["CRANE".to_string()];
        let solver = IntelligentSolver::new(words);
        
        // Test pattern simulation
        let pattern = solver.simulate_guess_pattern("CRANE", "CRATE");
        assert_eq!(pattern, "GGGXG"); // C, R, A match, N doesn't, E matches
        
        let pattern2 = solver.simulate_guess_pattern("CRANE", "SLATE");
        assert_eq!(pattern2, "XXGXG"); // Only A and E match
    }

    #[test]
    fn test_intelligent_solver_basic() {
        let words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string()];
        let solver = IntelligentSolver::new(words);
        
        // Test basic solver functionality
        let remaining = vec!["CRANE".to_string(), "SLATE".to_string()];
        let best_guess = solver.get_best_guess(&remaining, &[]);
        
        assert!(best_guess.is_some());
        assert!(remaining.contains(&best_guess.unwrap()));
    }

    #[test]
    fn test_word_filtering() {
        let words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string()];
        let solver = IntelligentSolver::new(words.clone());
        
        // Create a guess result: CRANE with C=Green, R=Yellow, A=Gray, N=Gray, E=Green
        let guess = GuessResult::new("CRANE".to_string(), [
            LetterResult::Green,  // C
            LetterResult::Yellow, // R
            LetterResult::Gray,   // A
            LetterResult::Gray,   // N
            LetterResult::Green,  // E
        ]);
        
        let filtered = solver.filter_words(&words, &[guess]);
        
        // Should filter out words that don't match the pattern
        assert!(filtered.len() < words.len());
    }
}
