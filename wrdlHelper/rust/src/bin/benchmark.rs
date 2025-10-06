//! Wordle Solver Benchmark Executable
//! 
//! This executable runs comprehensive benchmarks of our intelligent Wordle solver
//! against human performance statistics.

use rust_lib_wrdlhelper::benchmark_runner::BenchmarkRunner;
use std::env;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🎯 Wordle Solver Benchmark Tool");
    println!("================================");
    
    let args: Vec<String> = env::args().collect();
    let benchmark_type = args.get(1).map(|s| s.as_str()).unwrap_or("comprehensive");
    
    let runner = BenchmarkRunner::new()?;
    
    match benchmark_type {
        "comprehensive" | "" => {
            println!("\n🚀 Running 900-Game Wordle Benchmark (Statistically Significant)...");
            let report = runner.run_random_benchmark(900);
            report.print_report();
        }
        "50" | "quick" => {
            println!("\n⚡ Running 50-Game Quick Benchmark...");
            let report = runner.run_random_benchmark(50);
            report.print_report();
        }
        "help" => {
            print_help();
        }
        _ => {
            // Try to parse as a number
            if let Ok(num_games) = benchmark_type.parse::<usize>() {
                if num_games > 0 {
                    println!("\n🎯 Running {}-Game Wordle Benchmark...", num_games);
                    let report = runner.run_random_benchmark(num_games);
                    report.print_report();
                } else {
                    println!("❌ Number of games must be greater than 0, got: {}", num_games);
                    print_help();
                }
            } else {
                println!("❌ Unknown benchmark type: {}", benchmark_type);
                print_help();
            }
        }
    }
    
    Ok(())
}

fn print_help() {
    println!("\n📖 Usage:");
    println!("  cargo run --bin benchmark [number_of_games]");
    println!("\n🎯 Benchmark Options:");
    println!("  900 or comprehensive - Run 900 random Wordle answer words (statistically significant)");
    println!("  50 or quick         - Run 50 random Wordle answer words");
    println!("  help                - Show this help message");
    println!("\n📊 What the benchmark tests:");
    println!("  • AI solver performance vs human statistics");
    println!("  • Success rate comparison");
    println!("  • Average guess count comparison");
    println!("  • Win distribution by guess count");
    println!("  • Timing metrics (total time, time per game)");
}
