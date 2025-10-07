import 'package:wrdlhelper/models/word.dart';
import 'package:wrdlhelper/exceptions/game_exceptions.dart';

/// Letter state for Wordle game
enum LetterState {
  /// Gray - letter not in target word
  gray,
  /// Yellow - letter in target word but wrong position
  yellow,
  /// Green - letter in target word and correct position
  green,
}

/// Guess result model for Wordle game
/// 
/// Represents the result of a guess with letter states and analysis
/// for the Wordle game following TDD principles.
class GuessResult {
  /// The word that was guessed
  final Word word;
  
  /// The state of each letter in the guess
  final List<LetterState> letterStates;
  
  /// Whether this result is complete (has been properly evaluated)
  bool get isComplete => letterStates.length == word.length && 
      letterStates.any((state) => state != LetterState.gray);
  
  /// Whether this guess is correct (all letters are green)
  bool get isCorrect => letterStates.every((state) => state == LetterState.green);
  
  /// Whether this result has any correct letters (green or yellow)
  bool get hasCorrectLetters => letterStates.any((state) => 
      state == LetterState.green || state == LetterState.yellow);
  
  /// Number of green letters
  int get greenCount => letterStates.where((state) => state == LetterState.green).length;
  
  /// Number of yellow letters
  int get yellowCount => letterStates.where((state) => state == LetterState.yellow).length;
  
  /// Number of gray letters
  int get grayCount => letterStates.where((state) => state == LetterState.gray).length;
  
  /// Constructor that validates inputs
  GuessResult({
    required Word? word,
    required List<LetterState>? letterStates,
  }) : word = word ?? (throw InvalidGuessResultException('Word cannot be null')),
       letterStates = letterStates ?? (throw InvalidGuessResultException('Letter states cannot be null')) {
    if (this.letterStates.length != this.word.length) {
      throw InvalidGuessResultException(
      'Letter states length must match word length');
    }
  }
  
  /// Creates a GuessResult from a word with all gray letters
  factory GuessResult.fromWord(Word word) {
    final letterStates = List<LetterState>.filled(
      word.length, 
      LetterState.gray,
    );
    
    return GuessResult(
      word: word,
      letterStates: letterStates,
    );
  }
  
  /// Creates a validated GuessResult
  factory GuessResult.validated({
    required Word? word,
    required List<LetterState>? letterStates,
  }) {
    if (word == null) {
      throw InvalidGuessResultException('Word cannot be null');
    }
    if (letterStates == null) {
      throw InvalidGuessResultException('Letter states cannot be null');
    }
    if (letterStates.length != word.length) {
      throw InvalidGuessResultException(
      'Letter states length must match word length');
    }
    
    return GuessResult(
      word: word,
      letterStates: letterStates,
    );
  }
  
  /// Creates a GuessResult with custom letter states
  factory GuessResult.withStates({
    required Word word,
    required List<LetterState> letterStates,
  }) {
    return GuessResult(
      word: word,
      letterStates: List.from(letterStates),
    );
  }
  
  /// Gets the letter state at the specified position
  LetterState getLetterState(int position) {
    if (position < 0 || position >= letterStates.length) {
      return LetterState.gray;
    }
    return letterStates[position];
  }
  
  /// Gets the letter state at the specified position using [] operator
  LetterState operator [](int position) {
    if (position < 0 || position >= letterStates.length) {
      throw RangeError('Index out of range: $position');
    }
    return letterStates[position];
  }
  
  /// Sets the letter state at the specified position
  GuessResult setLetterState(int position, LetterState state) {
    if (position < 0 || position >= letterStates.length) {
      return this;
    }
    
    final newStates = List<LetterState>.from(letterStates);
    newStates[position] = state;
    
    return GuessResult(
      word: word,
      letterStates: newStates,
    );
  }
  
  /// Updates the letter state at the specified position (mutable)
  void updateLetterState(int position, LetterState state) {
    if (position < 0 || position >= letterStates.length) {
      throw RangeError('Index out of range: $position');
    }
    letterStates[position] = state;
  }
  
  /// Updates multiple letter states at once (mutable)
  void updateLetterStates(List<LetterState> newStates) {
    if (newStates.length != letterStates.length) {
      throw ArgumentError('New states length must match current states length');
    }
    for (int i = 0; i < newStates.length; i++) {
      letterStates[i] = newStates[i];
    }
  }
  
  /// Gets all positions of a specific letter state
  List<int> getPositionsOfState(LetterState state) {
    final positions = <int>[];
    
    for (int i = 0; i < letterStates.length; i++) {
      if (letterStates[i] == state) {
        positions.add(i);
      }
    }
    
    return positions;
  }
  
  /// Gets all positions with green letters
  List<int> getGreenPositions() {
    return getPositionsOfState(LetterState.green);
  }
  
  /// Gets all positions with yellow letters
  List<int> getYellowPositions() {
    return getPositionsOfState(LetterState.yellow);
  }
  
  /// Gets all positions with gray letters
  List<int> getGrayPositions() {
    return getPositionsOfState(LetterState.gray);
  }
  
  /// Gets all letters with a specific state
  List<String> getLettersByState(LetterState state) {
    final letters = <String>[];
    
    for (int i = 0; i < letterStates.length; i++) {
      if (letterStates[i] == state) {
        letters.add(word.charAt(i));
      }
    }
    
    return letters;
  }
  
  /// Checks if two results are equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GuessResult) return false;
    return word == other.word && 
           _listEquals(letterStates, other.letterStates);
  }
  
  /// Helper method to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  
  /// Gets the hash code for this result
  @override
  int get hashCode => Object.hash(word, letterStates);
  
  /// String representation of the result
  @override
  String toString() {
    final stateStrings = letterStates.map((state) {
      switch (state) {
        case LetterState.gray:
          return 'G';
        case LetterState.yellow:
          return 'Y';
        case LetterState.green:
          return 'G';
      }
    }).join('');
    
    return '${word.value}: $stateStrings';
  }
  
  /// Converts to JSON
  Map<String, dynamic> toJson() => {
    'word': word.toJson(),
    'letterStates': letterStates.map((state) => state.name).toList(),
  };
  
  /// Creates from JSON
  factory GuessResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw FormatException('Invalid JSON: null provided');
    }
    if (json['word'] == null) {
      throw FormatException('Invalid JSON: missing word field');
    }
    if (json['letterStates'] == null) {
      throw FormatException('Invalid JSON: missing letterStates field');
    }
    
    final word = Word.fromJson(json['word'] as Map<String, dynamic>);
    final letterStates = (json['letterStates'] as List<dynamic>)
        .map((state) => LetterState.values.firstWhere(
          (e) => e.name == state,
          orElse: () => LetterState.gray,
        ))
        .toList();
    
    return GuessResult(
      word: word,
      letterStates: letterStates,
    );
  }
  
}
