//! Simple test to reproduce the TARES GYYXX → CRAFT constraint violation
//! 
//! This test demonstrates the bug where the algorithm suggests CRAFT
//! when given TARES GYYXX constraints, even though CRAFT violates the constraints.

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum LetterResult {
    Green,
    Yellow,
    Gray,
}

#[derive(Debug, Clone)]
pub struct GuessResult {
    pub word: String,
    pub results: [LetterResult; 5],
}

impl GuessResult {
    pub fn new(word: String, results: [LetterResult; 5]) -> Self {
        Self { word, results }
    }
}

/// Check if a word matches the given guess pattern
/// This is the function that has the constraint violation bug
pub fn word_matches_pattern(word: &str, guess_result: &GuessResult) -> bool {
    let word_chars: Vec<char> = word.chars().collect();
    let guess_chars: Vec<char> = guess_result.word.chars().collect();
    
    // Build letter count constraints from guess
    use std::collections::HashMap;
    let mut min_required: HashMap<char, usize> = HashMap::new();
    let mut banned_positions: HashMap<usize, char> = HashMap::new();
    let mut fixed_positions: HashMap<usize, char> = HashMap::new();
    let mut total_occurrence_cap: HashMap<char, usize> = HashMap::new();
    
    // First pass: fixed greens and count greens/yellows per letter
    for i in 0..5 {
        match guess_result.results[i] {
            LetterResult::Green => {
                fixed_positions.insert(i, guess_chars[i]);
                *min_required.entry(guess_chars[i]).or_insert(0) += 1;
            }
            LetterResult::Yellow => {
                banned_positions.insert(i, guess_chars[i]);
                *min_required.entry(guess_chars[i]).or_insert(0) += 1;
            }
            LetterResult::Gray => {}
        }
    }
    
    // Second pass: for grays, if the letter also appears as green/yellow elsewhere,
    // cap the total occurrences to that minimum (i.e., no extra occurrences)
    for i in 0..5 {
        if let LetterResult::Gray = guess_result.results[i] {
            let ch = guess_chars[i];
            if let Some(&required) = min_required.get(&ch) {
                // gray means no more than required occurrences across the word
                total_occurrence_cap.insert(ch, required);
            } else {
                // letter is completely absent
                total_occurrence_cap.insert(ch, 0);
            }
        }
    }
    
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
    
    // Gray letters and occurrence caps
    // Enforce position bans and total occurrence limits
    let mut counts: HashMap<char, usize> = HashMap::new();
    for (idx, ch) in word_chars.iter().enumerate() {
        // Position bans (from yellows)
        if let Some(&banned_ch) = banned_positions.get(&idx) {
            if *ch == banned_ch {
                return false;
            }
        }
        // Count occurrences
        *counts.entry(*ch).or_insert(0) += 1;
    }
    
    // Enforce minimums (greens+yellows) and caps (grays)
    for (ch, &min_cnt) in min_required.iter() {
        if counts.get(ch).cloned().unwrap_or(0) < min_cnt {
            return false;
        }
    }
    for (ch, &cap_cnt) in total_occurrence_cap.iter() {
        if counts.get(ch).cloned().unwrap_or(0) > cap_cnt {
            return false;
        }
    }
    
    true
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_constraint_violation_tares_gyyxx() {
        // Test case from handoff document: TARES GYYXX should NOT suggest CRAFT
        // TARES GYYXX means:
        // - T in position 1 = Green (must be T)
        // - A in position 2 = Yellow (must be in word but not position 2)
        // - R in position 3 = Yellow (must be in word but not position 3)
        // - E in position 4 = Gray (must not be in word)
        // - S in position 5 = Gray (must not be in word)
        
        // Create TARES GYYXX constraint
        let tares_constraint = GuessResult::new("TARES".to_string(), [
            LetterResult::Green,  // T in position 1
            LetterResult::Yellow, // A in position 2 (must be in word but not position 2)
            LetterResult::Yellow, // R in position 3 (must be in word but not position 3)
            LetterResult::Gray,  // E in position 4 (must not be in word)
            LetterResult::Gray,  // S in position 5 (must not be in word)
        ]);
        
        // Test CRAFT - should be filtered out
        let craft_matches = word_matches_pattern("CRAFT", &tares_constraint);
        println!("CRAFT matches TARES GYYXX: {}", craft_matches);
        
        // CRAFT should be filtered out because:
        // - C in position 1 violates Green constraint (should be T)
        // - R in position 3 violates Yellow constraint (R should not be in position 3)
        assert!(!craft_matches, 
            "CRAFT should be filtered out: C in position 1 (should be T), R in position 3 (should not be R)");
        
        // Test TRACK - should be valid
        let track_matches = word_matches_pattern("TRACK", &tares_constraint);
        println!("TRACK matches TARES GYYXX: {}", track_matches);
        
        // TRACK should be valid because:
        // - T in position 1 ✅ (Green constraint)
        // - A is in word but not position 2 ✅ (Yellow constraint)
        // - R is in word but not position 3 ✅ (Yellow constraint)
        // - No E or S ✅ (Gray constraints)
        assert!(track_matches, "TRACK should be valid");
        
        println!("✅ Constraint test passed: CRAFT correctly filtered out, TRACK correctly included");
    }
}
