import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for getting tasks that need to be synced
class GetTasksToSync implements UseCase<List<Task>, NoParams> {
  final TaskRepository repository;

  const GetTasksToSync(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) async {
    return await repository.getTasksToSync();
  }
}
