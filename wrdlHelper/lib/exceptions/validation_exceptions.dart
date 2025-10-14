/// Validation-related exceptions for Wordle game
///
/// These exceptions handle input validation, pattern matching,
/// and data validation errors following TDD principles.
library;

/// Base class for all validation exceptions
abstract class ValidationException implements Exception {
  /// Creates a new validation exception
  const ValidationException(this.message, [this.details]);

  /// The main error message
  final String message;
  
  /// Optional additional details about the error
  final String? details;

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception thrown when an invalid pattern is provided
class InvalidPatternException extends ValidationException {
  /// Creates a new invalid pattern exception
  const InvalidPatternException([String? details])
    : super('Invalid pattern provided', details);
}

/// Exception thrown when an invalid letter is provided
class InvalidLetterException extends ValidationException {
  /// Creates a new invalid letter exception
  const InvalidLetterException([String? details])
    : super('Invalid letter provided', details);
}
