import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

/// Parameters for deleting a task
class DeleteTaskParams {
  final String id;

  const DeleteTaskParams(this.id);
}

/// Use case to delete a task
class DeleteTask implements UseCase<bool, DeleteTaskParams> {
  final TaskRepository repository;

  const DeleteTask(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(params.id);
  }
}
