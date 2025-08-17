import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

/// Use case for syncing tasks with remote database
class SyncTasks implements UseCase<bool, NoParams> {
  final TaskRepository repository;

  const SyncTasks(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.syncWithRemote();
  }
}
