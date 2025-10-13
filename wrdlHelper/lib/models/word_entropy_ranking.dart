import 'package:wrdlhelper/models/word.dart';

/// Represents a word with its entropy ranking for intelligent word selection
class WordEntropyRanking {
  /// The word being ranked
  final Word word;

  /// The entropy value (information gain) for this word
  final double entropy;

  /// Additional metadata about the ranking
  final EntropyMetadata metadata;

  /// Creates a new word entropy ranking
  const WordEntropyRanking({
    required this.word,
    required this.entropy,
    required this.metadata,
  });

  @override
  String toString() => 'WordEntropyRanking(word: ${word.value}, '
      'entropy: ${entropy.toStringAsFixed(4)}, metadata: $metadata)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordEntropyRanking &&
        other.word == word &&
        other.entropy == entropy &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => word.hashCode ^ entropy.hashCode ^ metadata.hashCode;
}

/// Metadata about the entropy calculation
class EntropyMetadata {
  /// Number of remaining possible words
  final int remainingWordCount;

  /// Number of different patterns this word could produce
  final int patternCount;

  /// Average words eliminated per pattern
  final double averageElimination;

  /// Whether this word is in the answer list (prime suspect)
  final bool isPrimeSuspect;

  /// Creates new entropy metadata
  const EntropyMetadata({
    required this.remainingWordCount,
    required this.patternCount,
    required this.averageElimination,
    required this.isPrimeSuspect,
  });

  @override
  String toString() => 'EntropyMetadata(remaining: $remainingWordCount, '
      'patterns: $patternCount, '
      'avgElimination: ${averageElimination.toStringAsFixed(2)}, '
      'primeSuspect: $isPrimeSuspect)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntropyMetadata &&
        other.remainingWordCount == remainingWordCount &&
        other.patternCount == patternCount &&
        other.averageElimination == averageElimination &&
        other.isPrimeSuspect == isPrimeSuspect;
  }

  @override
  int get hashCode => remainingWordCount.hashCode ^
      patternCount.hashCode ^
      averageElimination.hashCode ^
      isPrimeSuspect.hashCode;
}
