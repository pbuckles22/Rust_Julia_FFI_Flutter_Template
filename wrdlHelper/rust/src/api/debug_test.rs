#[cfg(test)]
mod debug_tests {
    use super::super::wrdl_helper::{IntelligentSolver, GuessResult, LetterResult};

    #[test]
    fn test_word_filtering_debug() {
        let words = vec!["CRANE".to_string(), "SLATE".to_string()];
        let solver = IntelligentSolver::new(words.clone());
        
        // Test all gray pattern
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
        
        // Should return SLATE (not CRANE)
        assert_eq!(filtered, vec!["SLATE".to_string()]);
    }

    #[test]
    fn test_word_filtering_one_green() {
        let words = vec!["CRANE".to_string(), "SLATE".to_string(), "CHASE".to_string()];
        let solver = IntelligentSolver::new(words.clone());
        
        // Test one green pattern (GXXXX)
        let guess_result = GuessResult::new("CRANE".to_string(), [
            LetterResult::Green,  // C
            LetterResult::Gray,   // R
            LetterResult::Gray,   // A
            LetterResult::Gray,   // N
            LetterResult::Gray,   // E
        ]);
        
        println!("Testing one green pattern (GXXXX) for CRANE");
        println!("Words: {:?}", words);
        
        for word in &words {
            let matches = solver.word_matches_pattern(word, &guess_result);
            println!("Word '{}' matches pattern: {}", word, matches);
        }
        
        let filtered = solver.filter_words(&words, &[guess_result]);
        println!("Filtered words: {:?}", filtered);
        
        // Should return CHASE (starts with C, no R,A,N,E)
        assert_eq!(filtered, vec!["CHASE".to_string()]);
    }
}
