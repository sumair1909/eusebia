import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base interface for all use cases in the application
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// No parameters class for use cases that don't require parameters
class NoParams {
  const NoParams();
}
