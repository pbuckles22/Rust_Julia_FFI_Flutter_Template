/// Service-related exceptions for Wordle game
///
/// These exceptions handle service initialization, asset loading,
/// and service operation errors following TDD principles.
library;

/// Base class for all service exceptions
abstract class ServiceException implements Exception {
  final String message;
  final String? details;

  const ServiceException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception thrown when a service is not initialized
class ServiceNotInitializedException extends ServiceException {
  const ServiceNotInitializedException([String? details])
    : super('Service not initialized', details);
}

/// Exception thrown when asset loading fails
class AssetLoadException extends ServiceException {
  const AssetLoadException([String? details])
    : super('Failed to load asset', details);
}

/// Exception thrown when concurrent access is detected
class ConcurrentAccessException extends ServiceException {
  const ConcurrentAccessException([String? details])
    : super('Concurrent access detected', details);
}

/// Exception thrown when a race condition occurs
class RaceConditionException extends ServiceException {
  const RaceConditionException([String? details])
    : super('Race condition detected', details);
}

/// Exception thrown when a deadlock occurs
class DeadlockException extends ServiceException {
  const DeadlockException([String? details])
    : super('Deadlock detected', details);
}

/// Exception thrown when a memory leak is detected
class MemoryLeakException extends ServiceException {
  const MemoryLeakException([String? details])
    : super('Memory leak detected', details);
}
