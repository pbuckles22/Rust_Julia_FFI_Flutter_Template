# Client-Server Architecture Flow

## 🎯 **GOAL: Both Benchmark and Dart call the EXACT same function**

## 📋 **Current Problem**
- **Benchmark**: Does its own filtering, then calls `solver.get_best_guess(filtered_words, ...)`
- **Dart**: Should call FFI `get_best_guess(gameState)` which does filtering internally
- **Result**: Different code paths = different behavior

## ✅ **CORRECT Architecture**

### **Single Function Call Pattern**
```
Client (Benchmark/Dart) → FFI get_best_guess(gameState) → Server handles everything
```

### **Server-Side Flow**
```
get_best_guess(gameState)
├── filter_words_from_gamestate(gameState) → returns filtered words
├── get_benchmark_guess(filtered_words, gameState) → returns best guess
└── return best guess to client
```

## 🔧 **Functions to REMOVE (Wrong Pattern)**
- `get_benchmark_guess(candidate_words, guess_results)` - receives pre-filtered words
- Any function that takes `candidate_words` parameter
- Any client-side filtering functions

## ✅ **Functions to KEEP (Correct Pattern)**
- `get_best_guess(guess_results)` - takes game state, does everything internally
- `filter_words_from_gamestate(guess_results)` - private server function
- `get_benchmark_guess(filtered_words, guess_results)` - internal server function

## 🎯 **Implementation Plan**

### **Step 1: Remove Wrong Functions**
- Remove `get_benchmark_guess(candidate_words, guess_results)` from FFI
- Remove any function that takes pre-filtered words
- This will cause compilation errors where wrong pattern is used

### **Step 2: Fix Benchmark**
- Change benchmark to call `get_best_guess(gameState)` instead of doing its own filtering
- Remove `self.filter_words_from_game_state()` call
- Remove `self.get_best_guess_from_game_state()` method

### **Step 3: Verify Dart**
- Ensure Dart calls `FfiService.getBestGuess(gameState)`
- No client-side filtering

## 📊 **Expected Result**
Both Benchmark and Dart will:
1. Create game state payload
2. Call `get_best_guess(gameState)` 
3. Server filters words internally
4. Server calculates best guess
5. Return best guess to client

**Same input → Same processing → Same output**
