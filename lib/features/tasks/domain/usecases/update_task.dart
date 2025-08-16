import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Parameters for updating a task
class UpdateTaskParams {
  final String id;
  final String? title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String>? tags;

  const UpdateTaskParams({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.dueDate,
    this.completedAt,
    this.tags,
  });
}

/// Use case to update an existing task
class UpdateTask implements UseCase<Task, UpdateTaskParams> {
  final TaskRepository repository;

  const UpdateTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(UpdateTaskParams params) async {
    // First get the existing task
    final existingTaskResult = await repository.getTaskById(params.id);

    return existingTaskResult.fold((failure) => Left(failure), (existingTask) {
      final updatedTask = existingTask.copyWith(
        title: params.title,
        description: params.description,
        status: params.status,
        priority: params.priority,
        dueDate: params.dueDate,
        completedAt: params.completedAt,
        tags: params.tags,
      );

      return repository.updateTask(updatedTask);
    });
  }
}
