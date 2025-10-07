import 'package:wrdlhelper/exceptions/game_exceptions.dart';
import 'package:wrdlhelper/models/guess_result.dart';
import 'package:wrdlhelper/models/word.dart';

/// Game status enum for Wordle game
enum GameStatus {
  /// Game is in progress
  playing,

  /// Game has been won
  won,

  /// Game has been lost
  lost,
}

/// Guess entry for tracking guesses and results
class GuessEntry {
  final Word word;
  final GuessResult result;

  const GuessEntry({required this.word, required this.result});

  Map<String, dynamic> toJson() => {
    'word': word.toJson(),
    'result': result.toJson(),
  };

  factory GuessEntry.fromJson(Map<String, dynamic> json) {
    return GuessEntry(
      word: Word.fromJson(json['word'] as Map<String, dynamic>),
      result: GuessResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GuessEntry) return false;
    return word == other.word && result == other.result;
  }

  @override
  int get hashCode => Object.hash(word, result);
}

/// Game state model for Wordle game
///
/// Represents the current state of a Wordle game including guesses,
/// target word, and game progression following TDD principles.
class GameState {
  /// List of guesses made in the game
  final List<GuessEntry> guesses;

  /// Maximum number of guesses allowed
  final int maxGuesses;

  /// Current guess number (0-based)
  int currentGuess;

  /// Whether the game is over
  bool isGameOver;

  /// Whether the game has been won
  bool isWon;

  /// Whether the game has been lost
  bool isLost;

  /// The target word for this game
  final Word? targetWord;

  /// The current game status
  GameStatus gameStatus;

  /// When the game was started
  final DateTime startTime;

  /// Private constructor
  GameState._({
    required this.guesses,
    required this.maxGuesses,
    required this.currentGuess,
    required this.isGameOver,
    required this.isWon,
    required this.isLost,
    required this.targetWord,
    required this.gameStatus,
    required this.startTime,
  });

  /// Creates a new game with default settings
  factory GameState.newGame({Word? targetWord, int maxGuesses = 5}) {
    return GameState._(
      guesses: [],
      maxGuesses: maxGuesses,
      currentGuess: 0,
      isGameOver: false,
      isWon: false,
      isLost: false,
      targetWord: targetWord,
      gameStatus: GameStatus.playing,
      startTime: DateTime.now(),
    );
  }

  /// Number of guesses made
  int get guessCount => guesses.length;

  /// Number of remaining guesses
  int get remainingGuesses => maxGuesses - currentGuess;

  /// Game duration since start
  Duration get gameDuration => DateTime.now().difference(startTime);

  /// Adds a guess to the game state
  void addGuess(Word? guess, GuessResult? result) {
    // Validate inputs are not null
    if (guess == null) {
      throw const InvalidGuessException('Guess cannot be null');
    }

    if (result == null) {
      throw const InvalidGuessResultException('Guess result cannot be null');
    }

    // Validate guess
    if (!guess.isValid) {
      throw InvalidGuessException('Invalid guess: ${guess.value}');
    }

    if (guess.length != 5) {
      throw const InvalidGuessException('Guess must be 5 letters long');
    }

    if (guess.value.isEmpty) {
      throw const InvalidGuessException('Guess cannot be empty');
    }

    // Check if this guess has already been used in this game
    for (final existingGuess in guesses) {
      if (existingGuess.word == guess) {
        throw InvalidGuessException(
          'Word "${guess.value}" has already been used in this game',
        );
      }
    }

    // Check if max guesses reached
    if (currentGuess >= maxGuesses) {
      throw const MaxGuessesReachedException('Maximum guesses reached');
    }

    // Check if game is over
    if (isGameOver) {
      throw const GameOverException('Cannot add guess to finished game');
    }

    // Add the guess
    guesses.add(GuessEntry(word: guess, result: result));
    currentGuess++;

    // Update game state
    _updateGameState();
  }

  /// Updates the game state based on current guesses
  void _updateGameState() {
    // Check if won (all letters are green in any guess)
    if (guesses.isNotEmpty) {
      for (final guess in guesses) {
        if (guess.result.letterStates.every(
          (state) => state == LetterState.green,
        )) {
          _setGameWon();
          return;
        }
      }
    }

    // Check if lost (max guesses reached)
    if (currentGuess >= maxGuesses) {
      _setGameLost();
      return;
    }

    // Game continues
    _setGamePlaying();
  }

  /// Sets the game as won
  void _setGameWon() {
    isWon = true;
    isLost = false;
    isGameOver = true;
    gameStatus = GameStatus.won;
  }

  /// Sets the game as lost
  void _setGameLost() {
    isWon = false;
    isLost = true;
    isGameOver = true;
    gameStatus = GameStatus.lost;
  }

  /// Sets the game as playing
  void _setGamePlaying() {
    isWon = false;
    isLost = false;
    isGameOver = false;
    gameStatus = GameStatus.playing;
  }

  /// Sets the game as over (for testing)
  void setGameOver() {
    isGameOver = true;
    gameStatus = GameStatus.lost; // Default to lost when manually set
  }

  /// Manually updates the game state (useful when letter colors are changed)
  void updateGameState() {
    _updateGameState();
  }

  /// Disposes of the game state (for testing purposes)
  void dispose() {
    // Clean up any resources if needed
    // Currently no cleanup required, but method exists for test compatibility
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() => {
    'guesses': guesses.map((g) => g.toJson()).toList(),
    'maxGuesses': maxGuesses,
    'currentGuess': currentGuess,
    'isGameOver': isGameOver,
    'isWon': isWon,
    'isLost': isLost,
    'targetWord': targetWord?.toJson(),
    'gameStatus': gameStatus.name,
    'startTime': startTime.toIso8601String(),
  };

  /// Creates from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    if (json['guesses'] == null) {
      throw const FormatException('Invalid JSON: missing guesses field');
    }

    final guesses = (json['guesses'] as List<dynamic>)
        .map((g) => GuessEntry.fromJson(g as Map<String, dynamic>))
        .toList();

    final targetWord = json['targetWord'] != null
        ? Word.fromJson(json['targetWord'] as Map<String, dynamic>)
        : null;

    final gameStatus = GameStatus.values.firstWhere(
      (status) => status.name == json['gameStatus'],
      orElse: () => GameStatus.playing,
    );

    return GameState._(
      guesses: guesses,
      maxGuesses: json['maxGuesses'] ?? 5,
      currentGuess: json['currentGuess'] ?? 0,
      isGameOver: json['isGameOver'] ?? false,
      isWon: json['isWon'] ?? false,
      isLost: json['isLost'] ?? false,
      targetWord: targetWord,
      gameStatus: gameStatus,
      startTime: DateTime.parse(
        json['startTime'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Checks if two game states are equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameState) return false;
    return guesses == other.guesses &&
        maxGuesses == other.maxGuesses &&
        currentGuess == other.currentGuess &&
        isGameOver == other.isGameOver &&
        isWon == other.isWon &&
        isLost == other.isLost &&
        targetWord == other.targetWord &&
        gameStatus == other.gameStatus;
  }

  /// Gets the hash code for this game state
  @override
  int get hashCode => Object.hash(
    guesses,
    maxGuesses,
    currentGuess,
    isGameOver,
    isWon,
    isLost,
    targetWord,
    gameStatus,
  );

  /// Creates a copy of this game state with the given fields replaced
  GameState copyWith({
    List<GuessEntry>? guesses,
    int? maxGuesses,
    int? currentGuess,
    bool? isGameOver,
    bool? isWon,
    bool? isLost,
    Word? targetWord,
    GameStatus? gameStatus,
    DateTime? startTime,
  }) {
    return GameState._(
      guesses: guesses ?? this.guesses,
      maxGuesses: maxGuesses ?? this.maxGuesses,
      currentGuess: currentGuess ?? this.currentGuess,
      isGameOver: isGameOver ?? this.isGameOver,
      isWon: isWon ?? this.isWon,
      isLost: isLost ?? this.isLost,
      targetWord: targetWord ?? this.targetWord,
      gameStatus: gameStatus ?? this.gameStatus,
      startTime: startTime ?? this.startTime,
    );
  }

  /// String representation of the game state
  @override
  String toString() {
    return 'GameState(guesses: ${guesses.length}, maxGuesses: $maxGuesses, '
        'currentGuess: $currentGuess, isGameOver: $isGameOver, '
        'isWon: $isWon, isLost: $isLost, gameStatus: $gameStatus)';
  }
}
