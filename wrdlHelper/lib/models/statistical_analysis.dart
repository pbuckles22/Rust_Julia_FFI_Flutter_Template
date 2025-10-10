import 'package:wrdlhelper/models/word.dart';

/// Analysis of letter frequency patterns in a word list
class LetterFrequencyAnalysis {
  /// Total number of words analyzed
  final int totalWords;

  /// Count of each letter across all words
  final Map<String, int> letterCounts;

  /// Probability of each letter appearing in any word
  final Map<String, double> letterProbabilities;

  /// Most common letters in order
  final List<String> mostCommonLetters;

  /// Least common letters in order
  final List<String> leastCommonLetters;

  const LetterFrequencyAnalysis({
    required this.totalWords,
    required this.letterCounts,
    required this.letterProbabilities,
    required this.mostCommonLetters,
    required this.leastCommonLetters,
  });

  @override
  String toString() {
    return 'LetterFrequencyAnalysis(totalWords: $totalWords, '
        'mostCommon: ${mostCommonLetters.take(5).toList()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LetterFrequencyAnalysis &&
        other.totalWords == totalWords &&
        other.letterCounts == letterCounts &&
        other.letterProbabilities == letterProbabilities &&
        other.mostCommonLetters == mostCommonLetters &&
        other.leastCommonLetters == leastCommonLetters;
  }

  @override
  int get hashCode {
    return totalWords.hashCode ^
        letterCounts.hashCode ^
        letterProbabilities.hashCode ^
        mostCommonLetters.hashCode ^
        leastCommonLetters.hashCode;
  }
}

/// Analysis of position-specific letter probabilities
class PositionProbabilityAnalysis {
  /// Total number of words analyzed
  final int totalWords;

  /// Probability of each letter at each position (0-4)
  /// Map of position to Map of letter to probability
  final Map<int, Map<String, double>> positionProbabilities;

  /// Most likely letters for each position
  final Map<int, List<String>> mostLikelyLetters;

  /// Least likely letters for each position
  final Map<int, List<String>> leastLikelyLetters;

  const PositionProbabilityAnalysis({
    required this.totalWords,
    required this.positionProbabilities,
    required this.mostLikelyLetters,
    required this.leastLikelyLetters,
  });

  @override
  String toString() {
    return 'PositionProbabilityAnalysis(totalWords: $totalWords, '
        'positions: ${positionProbabilities.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PositionProbabilityAnalysis &&
        other.totalWords == totalWords &&
        other.positionProbabilities == positionProbabilities &&
        other.mostLikelyLetters == mostLikelyLetters &&
        other.leastLikelyLetters == leastLikelyLetters;
  }

  @override
  int get hashCode {
    return totalWords.hashCode ^
        positionProbabilities.hashCode ^
        mostLikelyLetters.hashCode ^
        leastLikelyLetters.hashCode;
  }
}

/// Combined statistical analysis for word scoring
class WordStatisticalScore {
  /// The word being scored
  final Word word;

  /// Overall statistical score (0.0 to 1.0)
  final double score;

  /// Letter frequency score component
  final double letterFrequencyScore;

  /// Position probability score component
  final double positionProbabilityScore;

  /// Prime suspect bonus (if applicable)
  final double primeSuspectBonus;

  /// Analysis metadata
  final StatisticalScoreMetadata metadata;

  const WordStatisticalScore({
    required this.word,
    required this.score,
    required this.letterFrequencyScore,
    required this.positionProbabilityScore,
    required this.primeSuspectBonus,
    required this.metadata,
  });

  @override
  String toString() {
    return 'WordStatisticalScore(word: ${word.value}, '
        'score: ${score.toStringAsFixed(3)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordStatisticalScore &&
        other.word == word &&
        other.score == score &&
        other.letterFrequencyScore == letterFrequencyScore &&
        other.positionProbabilityScore == positionProbabilityScore &&
        other.primeSuspectBonus == primeSuspectBonus &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return word.hashCode ^
        score.hashCode ^
        letterFrequencyScore.hashCode ^
        positionProbabilityScore.hashCode ^
        primeSuspectBonus.hashCode ^
        metadata.hashCode;
  }
}

/// Metadata for statistical score calculation
class StatisticalScoreMetadata {
  /// Number of words used in analysis
  final int analysisWordCount;

  /// Whether this word is a prime suspect (in answer list)
  final bool isPrimeSuspect;

  /// Letter frequency rank (1 = most common)
  final int letterFrequencyRank;

  /// Position probability rank (1 = best positions)
  final int positionProbabilityRank;

  /// Combined rank
  final int combinedRank;

  const StatisticalScoreMetadata({
    required this.analysisWordCount,
    required this.isPrimeSuspect,
    required this.letterFrequencyRank,
    required this.positionProbabilityRank,
    required this.combinedRank,
  });

  @override
  String toString() {
    return 'StatisticalScoreMetadata(primeSuspect: $isPrimeSuspect, '
        'combinedRank: $combinedRank)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatisticalScoreMetadata &&
        other.analysisWordCount == analysisWordCount &&
        other.isPrimeSuspect == isPrimeSuspect &&
        other.letterFrequencyRank == letterFrequencyRank &&
        other.positionProbabilityRank == positionProbabilityRank &&
        other.combinedRank == combinedRank;
  }

  @override
  int get hashCode {
    return analysisWordCount.hashCode ^
        isPrimeSuspect.hashCode ^
        letterFrequencyRank.hashCode ^
        positionProbabilityRank.hashCode ^
        combinedRank.hashCode;
  }
}
