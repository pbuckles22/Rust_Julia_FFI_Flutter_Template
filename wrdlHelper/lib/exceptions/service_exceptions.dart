/// Service-related exceptions for Wordle game
///
/// These exceptions handle service initialization, asset loading,
/// and service operation errors following TDD principles.
library;

/// Base class for all service exceptions
abstract class ServiceException implements Exception {
  /// Creates a new service exception
  const ServiceException(this.message, [this.details]);

  /// The main error message
  final String message;
  
  /// Optional additional details about the error
  final String? details;

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception thrown when a service is not initialized
class ServiceNotInitializedException extends ServiceException {
  /// Creates a new service not initialized exception
  const ServiceNotInitializedException([String? details])
    : super('Service not initialized', details);
}

/// Exception thrown when asset loading fails
class AssetLoadException extends ServiceException {
  /// Creates a new asset load exception
  const AssetLoadException([String? details])
    : super('Failed to load asset', details);
}

/// Exception thrown when concurrent access is detected
class ConcurrentAccessException extends ServiceException {
  /// Creates a new concurrent access exception
  const ConcurrentAccessException([String? details])
    : super('Concurrent access detected', details);
}

/// Exception thrown when a race condition occurs
class RaceConditionException extends ServiceException {
  /// Creates a new race condition exception
  const RaceConditionException([String? details])
    : super('Race condition detected', details);
}

/// Exception thrown when a deadlock occurs
class DeadlockException extends ServiceException {
  /// Creates a new deadlock exception
  const DeadlockException([String? details])
    : super('Deadlock detected', details);
}

/// Exception thrown when a memory leak is detected
class MemoryLeakException extends ServiceException {
  /// Creates a new memory leak exception
  const MemoryLeakException([String? details])
    : super('Memory leak detected', details);
}
