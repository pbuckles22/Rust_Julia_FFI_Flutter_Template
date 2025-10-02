/// Validation-related exceptions for Wordle game
///
/// These exceptions handle input validation, pattern matching,
/// and data validation errors following TDD principles.
library;

/// Base class for all validation exceptions
abstract class ValidationException implements Exception {
  final String message;
  final String? details;

  const ValidationException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception thrown when an invalid pattern is provided
class InvalidPatternException extends ValidationException {
  const InvalidPatternException([String? details])
    : super('Invalid pattern provided', details);
}

/// Exception thrown when an invalid letter is provided
class InvalidLetterException extends ValidationException {
  const InvalidLetterException([String? details])
    : super('Invalid letter provided', details);
}
