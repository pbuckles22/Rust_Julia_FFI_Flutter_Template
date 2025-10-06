//! Benchmark Runner for Wordle Solver
//! 
//! This module provides a comprehensive benchmark runner that tests our intelligent solver
//! against human performance statistics and provides detailed analysis.

use crate::benchmarking::{WordleBenchmark, BenchmarkStats};
use std::time::{Duration, Instant};

/// Format duration in a human-readable way
fn format_duration(duration: Duration) -> String {
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

/// Human performance benchmarks based on research
#[derive(Debug, Clone)]
pub struct HumanBenchmarks {
    pub average_guesses: f64,
    pub success_rate: f64,
    pub guess_distribution: std::collections::HashMap<usize, f64>,
}

impl HumanBenchmarks {
    /// Create human benchmarks based on research data
    pub fn new() -> Self {
        let mut guess_distribution = std::collections::HashMap::new();
        // Based on research: average 4.0-4.2 guesses, ~89% success rate
        guess_distribution.insert(1, 0.01); // 1% solve in 1 guess
        guess_distribution.insert(2, 0.05); // 5% solve in 2 guesses  
        guess_distribution.insert(3, 0.20); // 20% solve in 3 guesses
        guess_distribution.insert(4, 0.35); // 35% solve in 4 guesses
        guess_distribution.insert(5, 0.20); // 20% solve in 5 guesses
        guess_distribution.insert(6, 0.08); // 8% solve in 6 guesses
        // 11% fail (not included in distribution)

        Self {
            average_guesses: 4.1,
            success_rate: 0.89,
            guess_distribution,
        }
    }
}

/// Comprehensive benchmark runner
pub struct BenchmarkRunner {
    benchmark: WordleBenchmark,
    human_benchmarks: HumanBenchmarks,
}

impl BenchmarkRunner {
    /// Create a new benchmark runner
    pub fn new() -> Result<Self, Box<dyn std::error::Error>> {
        // Load word lists from the current project's assets
        let answer_words = load_answer_words()?;
        let all_words = load_all_words()?;

        let benchmark = WordleBenchmark::new(answer_words, all_words);
        let human_benchmarks = HumanBenchmarks::new();

        Ok(Self {
            benchmark,
            human_benchmarks,
        })
    }

    /// Run comprehensive benchmark suite
    pub fn run_comprehensive_benchmark(&self) -> BenchmarkReport {
        println!("🚀 Starting Comprehensive Wordle Solver Benchmark");
        println!("📊 Testing against human performance statistics...");
        
        let start_time = Instant::now();

        // Run benchmark on comprehensive sample
        let sample_size = 30000; // Test on 30,000 words for maximum statistical significance
        let ai_stats = self.benchmark.run_benchmark(sample_size, 6);
        
        let duration = start_time.elapsed();

        // Compare with human benchmarks
        let comparison = self.compare_with_humans(&ai_stats);

        BenchmarkReport {
            ai_stats,
            human_benchmarks: self.human_benchmarks.clone(),
            comparison,
            duration,
            sample_size,
        }
    }

    /// Run benchmark on random Wordle answer words (same as comprehensive but with different sample size)
    pub fn run_random_benchmark(&self, sample_size: usize) -> BenchmarkReport {
        println!("🎲 Running Random Wordle Answer Benchmark");
        println!("📊 Testing on {} random Wordle answer words...", sample_size);
        
        // Estimate completion time based on previous performance (~0.88s per game)
        let estimated_seconds = (sample_size as f64 * 0.88) as u64;
        let estimated_duration = Duration::from_secs(estimated_seconds);
        let estimated_completion = chrono::Utc::now() + chrono::Duration::seconds(estimated_seconds as i64);
        let pst_completion = estimated_completion.with_timezone(&chrono_tz::US::Pacific);
        
        println!("⏱️  Estimated completion time: {} (PST: {})", 
            format_duration(estimated_duration),
            pst_completion.format("%Y-%m-%d %H:%M:%S %Z"));
        
        let start_time = Instant::now();

        let ai_stats = self.benchmark.run_benchmark(sample_size, 6);
        let duration = start_time.elapsed();

        let comparison = self.compare_with_humans(&ai_stats);

        BenchmarkReport {
            ai_stats,
            human_benchmarks: self.human_benchmarks.clone(),
            comparison,
            duration,
            sample_size,
        }
    }

    /// Compare AI performance with human benchmarks
    fn compare_with_humans(&self, ai_stats: &BenchmarkStats) -> PerformanceComparison {
        let guess_improvement = self.human_benchmarks.average_guesses - ai_stats.average_guesses;
        let success_improvement = ai_stats.success_rate - self.human_benchmarks.success_rate;
        
        let guess_improvement_percent = (guess_improvement / self.human_benchmarks.average_guesses) * 100.0;
        let success_improvement_percent = (success_improvement / self.human_benchmarks.success_rate) * 100.0;

        PerformanceComparison {
            guess_improvement,
            guess_improvement_percent,
            success_improvement,
            success_improvement_percent,
            ai_better_at_guesses: guess_improvement > 0.0,
            ai_better_at_success: success_improvement > 0.0,
        }
    }
}

/// Performance comparison between AI and humans
#[derive(Debug, Clone)]
pub struct PerformanceComparison {
    pub guess_improvement: f64,
    pub guess_improvement_percent: f64,
    pub success_improvement: f64,
    pub success_improvement_percent: f64,
    pub ai_better_at_guesses: bool,
    pub ai_better_at_success: bool,
}

/// Comprehensive benchmark report
#[derive(Debug, Clone)]
pub struct BenchmarkReport {
    pub ai_stats: BenchmarkStats,
    pub human_benchmarks: HumanBenchmarks,
    pub comparison: PerformanceComparison,
    pub duration: std::time::Duration,
    pub sample_size: usize,
}

impl BenchmarkReport {
    /// Print detailed benchmark report
    pub fn print_report(&self) {
        println!("\n📈 WORDLE SOLVER BENCHMARK REPORT");
        println!("=====================================");
        
        println!("\n🎯 PERFORMANCE SUMMARY");
        println!("Sample Size: {} words", self.sample_size);
        println!("Benchmark Duration: {:.2}s", self.duration.as_secs_f64());
        if self.sample_size < 100 {
            println!("⚠️  Note: Sample size < 100 may not be statistically significant");
        } else if self.sample_size < 857 {
            println!("📊 Note: For full statistical significance, consider running 857+ tests");
        } else {
            println!("✅ Sample size is statistically significant");
        }
        
        
        
        
        
        // Show guess distribution for wins
        println!("\n📊 Win Distribution by Guess Count:");
        for guess in 1..=6 {
            let wins_at_guess = self.ai_stats.guess_distribution.get(&guess).copied().unwrap_or(0);
            if wins_at_guess > 0 {
                let percentage = (wins_at_guess as f64 / self.ai_stats.solved_games as f64) * 100.0;
                println!("  {} guesses: {} wins ({:.1}% of wins)", guess, wins_at_guess, percentage);
            }
        }
        
        println!("\n📈 Performance Summary:");
        println!("Success Rate: {:.1}% (Human: {:.1}%)", 
            self.ai_stats.success_rate * 100.0, self.human_benchmarks.success_rate * 100.0);
        println!("Average Guesses: {:.2} (Human: {:.2})", 
            self.ai_stats.average_guesses, self.human_benchmarks.average_guesses);
        println!("Average Speed: {:.3}s per game", self.duration.as_secs_f64() / self.ai_stats.total_games as f64);
        println!("Total Games: {}", self.ai_stats.total_games);
        println!("Total Time: {:.2}s", self.duration.as_secs_f64());
    }
    
}

/// Load answer words from the current project's assets
fn load_answer_words() -> Result<Vec<String>, Box<dyn std::error::Error>> {
    // Try to load from the current project's word list
    let word_list_path = "../assets/word_lists/official_wordle_words.json";
    
    if std::path::Path::new(word_list_path).exists() {
        let content = std::fs::read_to_string(word_list_path)?;
        let word_data: serde_json::Value = serde_json::from_str(&content)?;
        
        if let Some(answers) = word_data.get("answer_words").and_then(|v| v.as_array()) {
            let answer_words: Vec<String> = answers
                .iter()
                .filter_map(|v| v.as_str().map(|s| s.to_uppercase()))
                .collect();
            println!("📚 Loaded {} answer words from {}", answer_words.len(), word_list_path);
            return Ok(answer_words);
        }
    }
    
    // Fallback to hardcoded list if file not found
    println!("⚠️  Using fallback hardcoded word list");
    Ok(vec![
        "CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string(),
        "RAISE".to_string(), "ADIEU".to_string(), "AUDIO".to_string(),
        "STARE".to_string(), "TEARS".to_string(), "AROSE".to_string(),
        "ALONE".to_string(), "ABOUT".to_string(), "ABOVE".to_string(),
    ])
}

/// Load all words (guess words) from the current project's assets
fn load_all_words() -> Result<Vec<String>, Box<dyn std::error::Error>> {
    // Try to load from the current project's word list
    let word_list_path = "../assets/word_lists/official_wordle_words.json";
    
    if std::path::Path::new(word_list_path).exists() {
        let content = std::fs::read_to_string(word_list_path)?;
        let word_data: serde_json::Value = serde_json::from_str(&content)?;
        
        if let Some(guesses) = word_data.get("guess_words").and_then(|v| v.as_array()) {
            let all_words: Vec<String> = guesses
                .iter()
                .filter_map(|v| v.as_str().map(|s| s.to_uppercase()))
                .collect();
            println!("📚 Loaded {} guess words from {}", all_words.len(), word_list_path);
            return Ok(all_words);
        }
    }
    
    // Fallback to hardcoded list if file not found
    println!("⚠️  Using fallback hardcoded word list");
    Ok(vec![
        "CRANE".to_string(), "SLATE".to_string(), "CRATE".to_string(),
        "RAISE".to_string(), "ADIEU".to_string(), "AUDIO".to_string(),
        "STARE".to_string(), "TEARS".to_string(), "AROSE".to_string(),
        "ALONE".to_string(), "ABOUT".to_string(), "ABOVE".to_string(),
        "VOMIT".to_string(), "PSYCH".to_string(), "GLYPH".to_string(),
        "JUMBO".to_string(), "ZEBRA".to_string(), "STOMP".to_string(),
    ])
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_human_benchmarks() {
        let benchmarks = HumanBenchmarks::new();
        assert_eq!(benchmarks.average_guesses, 4.1);
        assert_eq!(benchmarks.success_rate, 0.89);
        assert!(benchmarks.guess_distribution.contains_key(&4));
    }

    #[test]
    fn test_performance_comparison() {
        let ai_stats = BenchmarkStats {
            total_games: 100,
            solved_games: 95,
            success_rate: 0.95,
            average_guesses: 3.5,
            guess_distribution: std::collections::HashMap::new(),
            solve_rate_by_guess: std::collections::HashMap::new(),
        };
        
        let human_benchmarks = HumanBenchmarks::new();
        let runner = BenchmarkRunner {
            benchmark: WordleBenchmark::new(vec![], vec![]),
            human_benchmarks,
        };
        
        let comparison = runner.compare_with_humans(&ai_stats);
        assert!(comparison.ai_better_at_guesses);
        assert!(comparison.ai_better_at_success);
    }
}
