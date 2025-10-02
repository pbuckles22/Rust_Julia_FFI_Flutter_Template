import 'package:wrdlhelper/models/word.dart';

/// Represents a branch in the game tree analysis
class GameTreeBranch {
  /// The pattern that would result from this branch
  final String pattern;

  /// Probability of this pattern occurring
  final double probability;

  /// Words that would remain after this pattern
  final List<Word> remainingWords;

  /// Sub-branches for deeper analysis
  final List<GameTreeBranch> subBranches;

  /// Expected score for this branch
  final double expectedScore;

  /// Analysis metadata
  final BranchMetadata metadata;

  const GameTreeBranch({
    required this.pattern,
    required this.probability,
    required this.remainingWords,
    required this.subBranches,
    required this.expectedScore,
    required this.metadata,
  });

  @override
  String toString() {
    return 'GameTreeBranch(pattern: $pattern, probability: ${probability.toStringAsFixed(3)}, remaining: ${remainingWords.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameTreeBranch &&
        other.pattern == pattern &&
        other.probability == probability &&
        other.remainingWords == remainingWords &&
        other.subBranches == subBranches &&
        other.expectedScore == expectedScore &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return pattern.hashCode ^
        probability.hashCode ^
        remainingWords.hashCode ^
        subBranches.hashCode ^
        expectedScore.hashCode ^
        metadata.hashCode;
  }
}

/// Metadata for game tree branch analysis
class BranchMetadata {
  /// Depth of this branch in the tree
  final int depth;

  /// Number of words eliminated by this pattern
  final int wordsEliminated;

  /// Information gain from this branch
  final double informationGain;

  /// Whether this branch leads to game completion
  final bool leadsToCompletion;

  /// Confidence in this branch's analysis
  final double confidence;

  const BranchMetadata({
    required this.depth,
    required this.wordsEliminated,
    required this.informationGain,
    required this.leadsToCompletion,
    required this.confidence,
  });

  @override
  String toString() {
    return 'BranchMetadata(depth: $depth, eliminated: $wordsEliminated, infoGain: ${informationGain.toStringAsFixed(3)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchMetadata &&
        other.depth == depth &&
        other.wordsEliminated == wordsEliminated &&
        other.informationGain == informationGain &&
        other.leadsToCompletion == leadsToCompletion &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return depth.hashCode ^
        wordsEliminated.hashCode ^
        informationGain.hashCode ^
        leadsToCompletion.hashCode ^
        confidence.hashCode;
  }
}

/// Complete look-ahead analysis for a candidate word
class LookAheadAnalysis {
  /// The candidate word being analyzed
  final Word candidateWord;

  /// Maximum depth of analysis
  final int maxDepth;

  /// All possible branches from this word
  final List<GameTreeBranch> branches;

  /// Expected number of remaining words after this guess
  final double expectedRemainingWords;

  /// Overall expected score for this word
  final double expectedScore;

  /// Analysis metadata
  final LookAheadMetadata metadata;

  const LookAheadAnalysis({
    required this.candidateWord,
    required this.maxDepth,
    required this.branches,
    required this.expectedRemainingWords,
    required this.expectedScore,
    required this.metadata,
  });

  @override
  String toString() {
    return 'LookAheadAnalysis(word: ${candidateWord.value}, depth: $maxDepth, branches: ${branches.length}, expectedRemaining: ${expectedRemainingWords.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LookAheadAnalysis &&
        other.candidateWord == candidateWord &&
        other.maxDepth == maxDepth &&
        other.branches == branches &&
        other.expectedRemainingWords == expectedRemainingWords &&
        other.expectedScore == expectedScore &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return candidateWord.hashCode ^
        maxDepth.hashCode ^
        branches.hashCode ^
        expectedRemainingWords.hashCode ^
        expectedScore.hashCode ^
        metadata.hashCode;
  }
}

/// Metadata for look-ahead analysis
class LookAheadMetadata {
  /// Total number of words analyzed
  final int totalWordsAnalyzed;

  /// Number of unique patterns generated
  final int uniquePatterns;

  /// Analysis computation time in milliseconds
  final int computationTimeMs;

  /// Memory usage during analysis
  final int memoryUsageBytes;

  /// Confidence in the analysis
  final double confidence;

  const LookAheadMetadata({
    required this.totalWordsAnalyzed,
    required this.uniquePatterns,
    required this.computationTimeMs,
    required this.memoryUsageBytes,
    required this.confidence,
  });

  @override
  String toString() {
    return 'LookAheadMetadata(words: $totalWordsAnalyzed, patterns: $uniquePatterns, time: ${computationTimeMs}ms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LookAheadMetadata &&
        other.totalWordsAnalyzed == totalWordsAnalyzed &&
        other.uniquePatterns == uniquePatterns &&
        other.computationTimeMs == computationTimeMs &&
        other.memoryUsageBytes == memoryUsageBytes &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return totalWordsAnalyzed.hashCode ^
        uniquePatterns.hashCode ^
        computationTimeMs.hashCode ^
        memoryUsageBytes.hashCode ^
        confidence.hashCode;
  }
}

/// Optimal strategy recommendation from look-ahead analysis
class OptimalStrategy {
  /// The recommended word to guess
  final Word recommendedWord;

  /// Expected score for this strategy
  final double expectedScore;

  /// Confidence in this recommendation (0.0 to 1.0)
  final double confidence;

  /// Reasoning for this recommendation
  final String reasoning;

  /// Alternative strategies considered
  final List<Word> alternatives;

  /// Strategy metadata
  final StrategyMetadata metadata;

  const OptimalStrategy({
    required this.recommendedWord,
    required this.expectedScore,
    required this.confidence,
    required this.reasoning,
    required this.alternatives,
    required this.metadata,
  });

  @override
  String toString() {
    return 'OptimalStrategy(word: ${recommendedWord.value}, score: ${expectedScore.toStringAsFixed(3)}, confidence: ${confidence.toStringAsFixed(3)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimalStrategy &&
        other.recommendedWord == recommendedWord &&
        other.expectedScore == expectedScore &&
        other.confidence == confidence &&
        other.reasoning == reasoning &&
        other.alternatives == alternatives &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return recommendedWord.hashCode ^
        expectedScore.hashCode ^
        confidence.hashCode ^
        reasoning.hashCode ^
        alternatives.hashCode ^
        metadata.hashCode;
  }
}

/// Metadata for strategy recommendations
class StrategyMetadata {
  /// Number of words analyzed for this strategy
  final int wordsAnalyzed;

  /// Depth of look-ahead analysis
  final int analysisDepth;

  /// Number of alternative strategies considered
  final int alternativesConsidered;

  /// Whether this is an endgame strategy
  final bool isEndgameStrategy;

  /// Expected number of remaining guesses
  final double expectedRemainingGuesses;

  const StrategyMetadata({
    required this.wordsAnalyzed,
    required this.analysisDepth,
    required this.alternativesConsidered,
    required this.isEndgameStrategy,
    required this.expectedRemainingGuesses,
  });

  @override
  String toString() {
    return 'StrategyMetadata(words: $wordsAnalyzed, depth: $analysisDepth, endgame: $isEndgameStrategy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StrategyMetadata &&
        other.wordsAnalyzed == wordsAnalyzed &&
        other.analysisDepth == analysisDepth &&
        other.alternativesConsidered == alternativesConsidered &&
        other.isEndgameStrategy == isEndgameStrategy &&
        other.expectedRemainingGuesses == expectedRemainingGuesses;
  }

  @override
  int get hashCode {
    return wordsAnalyzed.hashCode ^
        analysisDepth.hashCode ^
        alternativesConsidered.hashCode ^
        isEndgameStrategy.hashCode ^
        expectedRemainingGuesses.hashCode;
  }
}
