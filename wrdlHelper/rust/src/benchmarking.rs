//! Wordle Benchmarking System
//! 
//! This module provides comprehensive benchmarking tools to test our intelligent solver
//! against human performance statistics and validate algorithm effectiveness.

use crate::api::wrdl_helper::{IntelligentSolver, GuessResult, LetterResult};
use rand::Rng;
use std::collections::HashMap;
use std::time::Instant;

/// Format duration in a human-readable way
fn format_duration(duration: std::time::Duration) -> String {
    let total_seconds = duration.as_secs();
    let hours = total_seconds / 3600;
    let minutes = (total_seconds % 3600) / 60;
    let seconds = total_seconds % 60;
    
    if hours > 0 {
        format!("{}h {}m {}s", hours, minutes, seconds)
    } else if minutes > 0 {
        format!("{}m {}s", minutes, seconds)
    } else {
        format!("{}s", seconds)
    }
}

/// Represents the result of a single Wordle game
#[derive(Debug, Clone)]
pub struct GameResult {
    pub target_word: String,
    pub guesses: Vec<String>,
    pub guess_count: usize,
    pub solved: bool,
    pub max_guesses: usize,
}

/// Represents benchmark statistics
#[derive(Debug, Clone)]
pub struct BenchmarkStats {
    pub total_games: usize,
    pub solved_games: usize,
    pub success_rate: f64,
    pub average_guesses: f64,
    pub guess_distribution: HashMap<usize, usize>,
    pub solve_rate_by_guess: HashMap<usize, f64>,
}

/// Wordle benchmarking system
pub struct WordleBenchmark {
    solver: IntelligentSolver,
    answer_words: Vec<String>,
}

impl WordleBenchmark {
    /// Create a new benchmark system
    pub fn new(answer_words: Vec<String>, all_words: Vec<String>) -> Self {
        Self {
            // REFERENCE APPROACH: Initialize solver with all words (14,855) for maximum coverage
            // This matches the reference implementation that achieved 99.8% success rate
            solver: IntelligentSolver::new(all_words),
            answer_words,
        }
    }

    /// Run a single game simulation
    /// 
    /// The agent is unaware of the target word and must solve it using only
    /// the feedback from each guess (green, yellow, gray letters).
    pub fn simulate_game(&self, target_word: &str, max_guesses: usize) -> GameResult {
        let mut guesses = Vec::new();
        let mut guess_results: Vec<GuessResult> = Vec::new();

        for attempt in 1..=max_guesses {
            // NEW ARCHITECTURE: Use server-side filtering
            // Convert guess_results to FFI format
            let ffi_guess_results: Vec<(String, Vec<String>)> = guess_results.iter().map(|gr| {
                let pattern: Vec<String> = gr.results.iter().map(|lr| {
                    match lr {
                        LetterResult::Green => "G".to_string(),
                        LetterResult::Yellow => "Y".to_string(),
                        LetterResult::Gray => "X".to_string(),
                    }
                }).collect();
                (gr.word.clone(), pattern)
            }).collect();
            
            // DEBUG: Show complete game state payload for Dart replication
            println!("🔍 BENCHMARK GAME STATE PAYLOAD - Attempt {}", attempt);
            println!("  • Target word: {}", target_word);
            println!("  • Total constraints: {}", guess_results.len());
            println!("  • Complete payload structure:");
            println!("    guess_results: Vec<(String, Vec<String>)> = [");
            for (i, (word, pattern)) in ffi_guess_results.iter().enumerate() {
                println!("      (\"{}\", {:?}), // constraint {}", word, pattern, i + 1);
            }
            println!("    ]");
            println!("  • This is the EXACT payload passed to: get_best_guess(guess_results)");
            
            // NEW: Use single server function (CORRECT ARCHITECTURE)
            // Initialize WORD_MANAGER
            crate::api::simple::initialize_word_lists().unwrap();
            
            // Single server call - server handles everything internally
            let best_guess = crate::api::simple::get_best_guess(ffi_guess_results.clone());
            
            if let Some(guess) = best_guess {
                println!("  • Algorithm suggested: {}", guess);
                guesses.push(guess.clone());
                
                // Check if we solved it
                if guess == target_word {
                    return GameResult {
                        target_word: target_word.to_string(),
                        guesses,
                        guess_count: attempt,
                        solved: true,
                        max_guesses,
                    };
                }
                
                // Generate feedback for this guess
                let feedback = self.generate_feedback(&guess, target_word);
                guess_results.push(feedback);
            } else {
                // No valid guess available
                break;
            }
        }

        GameResult {
            target_word: target_word.to_string(),
            guesses: guesses.clone(),
            guess_count: guesses.len(),
            solved: false,
            max_guesses,
        }
    }

    
    /// Convert FFI format to internal format
    fn convert_ffi_to_internal(&self, guess_results: &[(String, Vec<String>)]) -> Vec<GuessResult> {
        let mut internal_guess_results = Vec::new();
        for (word, pattern) in guess_results {
            let mut results = Vec::new();
            for letter_result in pattern {
                let lr = letter_result.to_uppercase();
                let result = match lr.as_str() {
                    "G" | "GREEN" => LetterResult::Green,
                    "Y" | "YELLOW" => LetterResult::Yellow,
                    "X" | "GRAY" | "GREY" => LetterResult::Gray,
                    _ => LetterResult::Gray,
                };
                results.push(result);
            }
            internal_guess_results.push(GuessResult::new(word.clone(), [
                results[0], results[1], results[2], results[3], results[4]
            ]));
        }
        internal_guess_results
    }

    /// Run benchmark on a random sample of words
    pub fn run_benchmark(&self, sample_size: usize, max_guesses: usize) -> BenchmarkStats {
        let mut rng = rand::thread_rng();
        let mut results = Vec::new();
        let start_time = Instant::now();
        
        // Select random words for benchmarking
        for i in 0..sample_size {
            let random_index = rng.gen_range(0..self.answer_words.len());
            let target_word = &self.answer_words[random_index];
            
            let game_result = self.simulate_game(target_word, max_guesses);
            
            results.push(game_result);
            
            // Progress update every 200 games
            if (i + 1) % 200 == 0 {
                let current_stats = self.calculate_stats(results.clone());
                let elapsed = start_time.elapsed();
                let games_remaining = sample_size - (i + 1);
                let avg_time_per_game = elapsed.as_secs_f64() / (i + 1) as f64;
                let estimated_remaining_seconds = (games_remaining as f64 * avg_time_per_game) as u64;
                let estimated_completion = chrono::Utc::now() + chrono::Duration::seconds(estimated_remaining_seconds as i64);
                let pst_completion = estimated_completion.with_timezone(&chrono_tz::US::Pacific);
                
                println!("\n📊 Progress Update - Games {}: Success Rate: {:.1}%, Avg Guesses: {:.2}", 
                    i + 1, current_stats.success_rate * 100.0, current_stats.average_guesses);
                println!("⏱️  Updated ETA: {} (PST: {})", 
                    format_duration(std::time::Duration::from_secs(estimated_remaining_seconds)),
                    pst_completion.format("%H:%M:%S %Z"));
            }
        }

        self.calculate_stats(results)
    }

    /// Run benchmark on specific words (for testing)
    pub fn run_benchmark_on_words(&self, target_words: Vec<String>, max_guesses: usize) -> BenchmarkStats {
        let mut results = Vec::new();
        
        for target_word in target_words {
            let game_result = self.simulate_game(&target_word, max_guesses);
            results.push(game_result);
        }

        self.calculate_stats(results)
    }

    /// Generate feedback for a guess against a target word
    fn generate_feedback(&self, guess: &str, target: &str) -> GuessResult {
        let guess_chars: Vec<char> = guess.chars().collect();
        let mut target_chars: Vec<char> = target.chars().collect();
        let mut results = [LetterResult::Gray; 5];

        // First pass: mark exact matches (green)
        for i in 0..5 {
            if guess_chars[i] == target_chars[i] {
                results[i] = LetterResult::Green;
                target_chars[i] = ' '; // Mark as used
            }
        }

        // Second pass: mark partial matches (yellow)
        for i in 0..5 {
            if results[i] == LetterResult::Gray {
                let letter = guess_chars[i];
                if let Some(pos) = target_chars.iter().position(|&c| c == letter) {
                    results[i] = LetterResult::Yellow;
                    target_chars[pos] = ' '; // Mark as used
                }
            }
        }

        GuessResult::new(guess.to_string(), results)
    }

    /// Filter words based on feedback from all guesses
    fn filter_words_with_feedback(&self, words: &[String], guess_results: &[GuessResult]) -> Vec<String> {
        words.iter()
            .filter(|word| self.word_matches_all_feedback(word, guess_results))
            .cloned()
            .collect()
    }

    /// Check if a word matches all feedback from previous guesses
    fn word_matches_all_feedback(&self, candidate: &str, guess_results: &[GuessResult]) -> bool {
        for guess_result in guess_results {
            if !self.word_matches_single_feedback(candidate, guess_result) {
                return false;
            }
        }
        true
    }

    /// Check if a word matches feedback from a single guess
    fn word_matches_single_feedback(&self, candidate: &str, guess_result: &GuessResult) -> bool {
        let candidate_chars: Vec<char> = candidate.chars().collect();
        let guess_chars: Vec<char> = guess_result.word.chars().collect();

        // Check green letters (exact position matches)
        for i in 0..5 {
            if guess_result.results[i] == LetterResult::Green {
                if candidate_chars[i] != guess_chars[i] {
                    return false;
                }
            }
        }

        // Check yellow letters (letter exists but not in this position)
        for i in 0..5 {
            if guess_result.results[i] == LetterResult::Yellow {
                let letter = guess_chars[i];
                // Letter can't be in the same position
                if candidate_chars[i] == letter {
                    return false;
                }
                // Letter must exist somewhere else
                if !candidate_chars.contains(&letter) {
                    return false;
                }
            }
        }

        // Check gray letters (letter doesn't exist or we have enough)
        let mut required_counts: HashMap<char, usize> = HashMap::new();
        for i in 0..5 {
            if guess_result.results[i] == LetterResult::Green || guess_result.results[i] == LetterResult::Yellow {
                let letter = guess_chars[i];
                *required_counts.entry(letter).or_insert(0) += 1;
            }
        }

        for i in 0..5 {
            if guess_result.results[i] == LetterResult::Gray {
                let letter = guess_chars[i];
                let required_count = required_counts.get(&letter).copied().unwrap_or(0);
                let actual_count = candidate_chars.iter().filter(|&&c| c == letter).count();
                
                if actual_count > required_count {
                    return false;
                }
            }
        }

        true
    }

    /// Calculate benchmark statistics from game results
    fn calculate_stats(&self, results: Vec<GameResult>) -> BenchmarkStats {
        let total_games = results.len();
        let solved_games = results.iter().filter(|r| r.solved).count();
        let success_rate = solved_games as f64 / total_games as f64;

        let total_guesses: usize = results.iter().map(|r| r.guess_count).sum();
        let average_guesses = total_guesses as f64 / total_games as f64;

        let mut guess_distribution: HashMap<usize, usize> = HashMap::new();
        for result in &results {
            if result.solved {
                *guess_distribution.entry(result.guess_count).or_insert(0) += 1;
            }
        }

        let mut solve_rate_by_guess: HashMap<usize, f64> = HashMap::new();
        for (guess_count, count) in &guess_distribution {
            solve_rate_by_guess.insert(*guess_count, *count as f64 / total_games as f64);
        }

        BenchmarkStats {
            total_games,
            solved_games,
            success_rate,
            average_guesses,
            guess_distribution,
            solve_rate_by_guess,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simulate_game_success() {
        let answer_words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string()];
        let all_words = vec!["CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string(), "RAISE".to_string()];
        let benchmark = WordleBenchmark::new(answer_words, all_words);
        
        let result = benchmark.simulate_game("CRANE", 6);
        
        assert!(result.solved);
        assert_eq!(result.target_word, "CRANE");
        assert!(result.guess_count <= 6);
    }

    #[test]
    fn test_generate_feedback() {
        let answer_words = vec!["CRANE".to_string()];
        let all_words = vec!["CRANE".to_string()];
        let benchmark = WordleBenchmark::new(answer_words, all_words);
        
        let feedback = benchmark.generate_feedback("CRANE", "CRANE");
        
        // All letters should be green
        for i in 0..5 {
            assert_eq!(feedback.results[i], LetterResult::Green);
        }
    }

    #[test]
    fn test_generate_feedback_partial() {
        let answer_words = vec!["CRANE".to_string()];
        let all_words = vec!["CRANE".to_string()];
        let benchmark = WordleBenchmark::new(answer_words, all_words);
        
        let feedback = benchmark.generate_feedback("CRATE", "CRANE");
        
        // Debug: print the actual results
        println!("CRATE vs CRANE feedback:");
        for (i, result) in feedback.results.iter().enumerate() {
            println!("Position {}: {:?}", i, result);
        }
        
        // C, R, A, and E should be green (same position), T should be gray
        assert_eq!(feedback.results[0], LetterResult::Green); // C
        assert_eq!(feedback.results[1], LetterResult::Green); // R
        assert_eq!(feedback.results[2], LetterResult::Green); // A (same position)
        assert_eq!(feedback.results[3], LetterResult::Gray); // T
        assert_eq!(feedback.results[4], LetterResult::Green); // E (same position)
    }

    #[test]
    fn test_benchmark_stats() {
        let answer_words = vec!["CRANE".to_string(), "SLATE".to_string()];
        let all_words = vec!["CRANE".to_string(), "SLATE".to_string(), "RAISE".to_string()];
        let benchmark = WordleBenchmark::new(answer_words, all_words);
        
        let stats = benchmark.run_benchmark_on_words(vec!["CRANE".to_string(), "SLATE".to_string()], 6);
        
        assert_eq!(stats.total_games, 2);
        assert!(stats.success_rate > 0.0);
        assert!(stats.average_guesses > 0.0);
    }
}
