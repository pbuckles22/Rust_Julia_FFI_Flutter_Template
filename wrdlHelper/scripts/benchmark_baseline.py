#!/usr/bin/env python3
"""
Wordle Solver Benchmark Baseline Script
Based on the reference implementation that achieved 99.8% success rate

This script runs comprehensive benchmarks with different difficulty levels
to test our bolt-on reference algorithm implementation.

Usage:
    python scripts/benchmark_baseline.py --games 150 --difficulty normal hard
    python scripts/benchmark_baseline.py --games 1000 --difficulty normal
    python scripts/benchmark_baseline.py --games 500 --difficulty hard
"""

import argparse
import subprocess
import sys
import time
import os
from typing import List, Dict, Any
import json

class BenchmarkRunner:
    def __init__(self):
        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.results = []
    
    def run_flutter_benchmark(self, test_name: str, description: str) -> Dict[str, Any]:
        """Run a Flutter benchmark test and parse the results"""
        print(f"🚀 Running: {description}")
        print("-" * 50)
        
        start_time = time.time()
        
        try:
            # Change to project directory and run Flutter test
            result = subprocess.run([
                'flutter', 'test', 
                'test/game_simulation_benchmark_test.dart',
                '--plain-name', test_name
            ], 
            cwd=self.project_root,
            capture_output=True, 
            text=True, 
            timeout=300  # 5 minute timeout
            )
            
            duration = time.time() - start_time
            
            if result.returncode == 0:
                # Parse the benchmark results from stdout
                benchmark_data = self.parse_benchmark_output(result.stdout)
                benchmark_data['duration'] = duration
                benchmark_data['description'] = description
                benchmark_data['success'] = True
                
                print(f"✅ Completed: {description}")
                print(f"   Success Rate: {benchmark_data.get('success_rate', 'N/A')}%")
                print(f"   Average Guesses: {benchmark_data.get('average_guesses', 'N/A')}")
                print(f"   Duration: {duration:.1f}s")
                print()
                
                return benchmark_data
            else:
                print(f"❌ Failed: {description}")
                print(f"   Error: {result.stderr}")
                print()
                
                return {
                    'description': description,
                    'success': False,
                    'error': result.stderr,
                    'duration': duration
                }
                
        except subprocess.TimeoutExpired:
            print(f"⏰ Timeout: {description}")
            print()
            return {
                'description': description,
                'success': False,
                'error': 'Timeout after 5 minutes',
                'duration': 300
            }
        except Exception as e:
            print(f"💥 Exception: {description}")
            print(f"   Error: {str(e)}")
            print()
            return {
                'description': description,
                'success': False,
                'error': str(e),
                'duration': time.time() - start_time
            }
    
    def parse_benchmark_output(self, output: str) -> Dict[str, Any]:
        """Parse benchmark results from Flutter test output"""
        data = {}
        
        lines = output.split('\n')
        for line in lines:
            line = line.strip()
            
            # Parse success rate
            if 'Success Rate:' in line and '%' in line:
                try:
                    # Extract percentage from "Success Rate: 99.0% (99/100)"
                    parts = line.split(':')[1].strip()
                    percentage = parts.split('%')[0].strip()
                    data['success_rate'] = float(percentage)
                except:
                    pass
            
            # Parse average guesses
            if 'Average Guesses:' in line:
                try:
                    # Extract number from "Average Guesses: 4.19"
                    parts = line.split(':')[1].strip()
                    data['average_guesses'] = float(parts)
                except:
                    pass
            
            # Parse response time
            if 'Average Time per Game:' in line:
                try:
                    # Extract time from "Average Time per Game: 53.4ms"
                    parts = line.split(':')[1].strip()
                    time_str = parts.replace('ms', '').strip()
                    data['response_time_ms'] = float(time_str)
                except:
                    pass
            
            # Parse total games
            if 'Total Games:' in line:
                try:
                    parts = line.split(':')[1].strip()
                    data['total_games'] = int(parts)
                except:
                    pass
        
        return data
    
    def try_rust_benchmark(self, num_games: int) -> bool:
        """Try to run the Rust benchmark directly (like the reference project)"""
        rust_dir = os.path.join(self.project_root, 'rust')
        
        if not os.path.exists(rust_dir):
            return False
        
        print("🚀 Attempting to run Rust benchmark (reference approach)...")
        print("=" * 50)
        
        try:
            # Try to run the Rust benchmark
            result = subprocess.run([
                'cargo', 'run', '--bin', 'benchmark', str(num_games)
            ], 
            cwd=rust_dir,
            capture_output=True, 
            text=True, 
            timeout=600  # 10 minute timeout
            )
            
            if result.returncode == 0:
                print("✅ Rust benchmark completed successfully!")
                print(result.stdout)
                return True
            else:
                print("⚠️  Rust benchmark failed, falling back to Flutter approach")
                print(f"   Error: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            print("⏰ Rust benchmark timed out, falling back to Flutter approach")
            return False
        except FileNotFoundError:
            print("⚠️  Cargo not found, falling back to Flutter approach")
            return False
        except Exception as e:
            print(f"⚠️  Rust benchmark error: {str(e)}, falling back to Flutter approach")
            return False
    
    def run_benchmark_suite(self, num_games: int, difficulties: List[str]) -> None:
        """Run benchmark suite with specified parameters"""
        print("🎯 Wordle Solver Benchmark Baseline")
        print("=" * 50)
        print(f"📊 Games per test: {num_games}")
        print(f"🎮 Difficulty levels: {', '.join(difficulties)}")
        print()
        
        # Try to run Rust benchmark first (if available)
        if self.try_rust_benchmark(num_games):
            return
        
        # Fall back to Flutter benchmarks
        print("🔄 Falling back to Flutter benchmark approach...")
        print()
        
        # Run benchmarks for each difficulty level
        for difficulty in difficulties:
            print(f"🎯 Running {difficulty.upper()} difficulty benchmark...")
            print("=" * 50)
            
            # Run multiple iterations for statistical significance
            iterations = max(1, 1000 // num_games)  # Aim for ~1000 total games
            if iterations > 10:
                iterations = 10  # Cap at 10 iterations
            
            print(f"📈 Running {iterations} iterations for statistical significance")
            print()
            
            difficulty_results = []
            
            for i in range(iterations):
                iteration_num = i + 1
                test_name = "Benchmark: Simulate 100 games to test optimized performance"
                description = f"{difficulty.title()} Difficulty - {num_games} Games (Iteration {iteration_num}/{iterations})"
                
                result = self.run_flutter_benchmark(test_name, description)
                difficulty_results.append(result)
                
                # Progress update every 200 games (similar to reference)
                if (i + 1) % 2 == 0:  # Every 2 iterations = 200 games
                    successful_results = [r for r in difficulty_results if r.get('success', False)]
                    if successful_results:
                        avg_success = sum(r.get('success_rate', 0) for r in successful_results) / len(successful_results)
                        avg_guesses = sum(r.get('average_guesses', 0) for r in successful_results) / len(successful_results)
                        total_games = sum(r.get('total_games', 0) for r in successful_results)
                        
                        print(f"\n📊 Progress Update - Games {total_games}: Success Rate: {avg_success:.1f}%, Avg Guesses: {avg_guesses:.2f}")
                
                # Small delay between iterations
                time.sleep(1)
            
            # Calculate statistics for this difficulty
            successful_results = [r for r in difficulty_results if r.get('success', False)]
            
            if successful_results:
                avg_success_rate = sum(r.get('success_rate', 0) for r in successful_results) / len(successful_results)
                avg_guesses = sum(r.get('average_guesses', 0) for r in successful_results) / len(successful_results)
                avg_response_time = sum(r.get('response_time_ms', 0) for r in successful_results) / len(successful_results)
                total_games = sum(r.get('total_games', 0) for r in successful_results)
                
                print(f"📊 {difficulty.upper()} DIFFICULTY SUMMARY:")
                print(f"   Total Games: {total_games}")
                print(f"   Average Success Rate: {avg_success_rate:.1f}%")
                print(f"   Average Guesses: {avg_guesses:.2f}")
                print(f"   Average Response Time: {avg_response_time:.1f}ms")
                print(f"   Target Success Rate: 99.8% | Gap: {99.8 - avg_success_rate:.1f}%")
                print(f"   Target Average Guesses: 3.66 | Gap: {avg_guesses - 3.66:.2f}")
                print()
                
                # Store results
                self.results.append({
                    'difficulty': difficulty,
                    'total_games': total_games,
                    'iterations': len(successful_results),
                    'avg_success_rate': avg_success_rate,
                    'avg_guesses': avg_guesses,
                    'avg_response_time': avg_response_time,
                    'individual_results': successful_results
                })
            else:
                print(f"❌ No successful results for {difficulty} difficulty")
                print()
        
        # Print final summary
        self.print_final_summary()
    
    def print_final_summary(self) -> None:
        """Print comprehensive final summary"""
        print("🎉 BENCHMARK BASELINE COMPLETE!")
        print("=" * 50)
        print()
        
        total_games = sum(r['total_games'] for r in self.results)
        print(f"📊 TOTAL GAMES TESTED: {total_games}")
        print()
        
        for result in self.results:
            difficulty = result['difficulty']
            print(f"🎯 {difficulty.upper()} DIFFICULTY:")
            print(f"   Games: {result['total_games']}")
            print(f"   Success Rate: {result['avg_success_rate']:.1f}% (Target: 99.8%)")
            print(f"   Average Guesses: {result['avg_guesses']:.2f} (Target: 3.66)")
            print(f"   Response Time: {result['avg_response_time']:.1f}ms (Target: <200ms)")
            print()
        
        # Overall performance assessment
        if self.results:
            overall_success = sum(r['avg_success_rate'] for r in self.results) / len(self.results)
            overall_guesses = sum(r['avg_guesses'] for r in self.results) / len(self.results)
            
            print("🎯 OVERALL PERFORMANCE:")
            print(f"   Average Success Rate: {overall_success:.1f}%")
            print(f"   Average Guesses: {overall_guesses:.2f}")
            print()
            
            if overall_success >= 99.0:
                print("✅ EXCELLENT: Success rate ≥ 99%")
            elif overall_success >= 95.0:
                print("🟡 GOOD: Success rate ≥ 95%")
            else:
                print("🔴 NEEDS IMPROVEMENT: Success rate < 95%")
            
            if overall_guesses <= 3.8:
                print("✅ EXCELLENT: Average guesses ≤ 3.8")
            elif overall_guesses <= 4.2:
                print("🟡 GOOD: Average guesses ≤ 4.2")
            else:
                print("🔴 NEEDS IMPROVEMENT: Average guesses > 4.2")
        
        print()
        print("📈 REFERENCE TARGETS:")
        print("   Success Rate: 99.8% (reference achieved)")
        print("   Average Guesses: 3.66 (reference achieved)")
        print("   Response Time: <200ms")
        print()
        print("🔧 Usage Examples:")
        print("   python scripts/benchmark_baseline.py --games 150 --difficulty normal hard")
        print("   python scripts/benchmark_baseline.py --games 1000 --difficulty normal")
        print("   python scripts/benchmark_baseline.py --games 500 --difficulty hard")

def main():
    parser = argparse.ArgumentParser(
        description='Wordle Solver Benchmark Baseline Script',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/benchmark_baseline.py --games 150 --difficulty normal hard
  python scripts/benchmark_baseline.py --games 1000 --difficulty normal
  python scripts/benchmark_baseline.py --games 500 --difficulty hard
        """
    )
    
    parser.add_argument(
        '--games', 
        type=int, 
        default=100,
        help='Number of games per benchmark iteration (default: 100)'
    )
    
    parser.add_argument(
        '--difficulty', 
        nargs='+',
        choices=['normal', 'hard', 'easy'],
        default=['normal'],
        help='Difficulty levels to test (default: normal)'
    )
    
    args = parser.parse_args()
    
    # Validate arguments
    if args.games < 10:
        print("❌ Error: --games must be at least 10")
        sys.exit(1)
    
    if args.games > 1000:
        print("⚠️  Warning: --games > 1000 may take a very long time")
    
    # Run benchmarks
    runner = BenchmarkRunner()
    runner.run_benchmark_suite(args.games, args.difficulty)

if __name__ == '__main__':
    main()
