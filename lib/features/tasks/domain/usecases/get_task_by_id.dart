import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Parameters for getting a task by ID
class GetTaskByIdParams {
  final String id;

  const GetTaskByIdParams(this.id);
}

/// Use case to get a task by ID
class GetTaskById implements UseCase<Task, GetTaskByIdParams> {
  final TaskRepository repository;

  const GetTaskById(this.repository);

  @override
  Future<Either<Failure, Task>> call(GetTaskByIdParams params) async {
    return await repository.getTaskById(params.id);
  }
}
