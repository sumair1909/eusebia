import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failure for network-related errors
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache failure for local storage errors
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network failure for connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Validation failure for input validation errors
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
