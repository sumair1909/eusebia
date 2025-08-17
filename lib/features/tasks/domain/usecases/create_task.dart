import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Parameters for creating a task
class CreateTaskParams {
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final List<String> tags;
  final List<String> labels;

  const CreateTaskParams({
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.tags = const [],
    this.labels = const [],
  });
}

/// Use case to create a new task
class CreateTask implements UseCase<Task, CreateTaskParams> {
  final TaskRepository repository;

  const CreateTask(this.repository);

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: params.title,
      description: params.description,
      priority: params.priority,
      createdAt: DateTime.now(),
      dueDate: params.dueDate,
      tags: params.tags,
      labels: params.labels,
    );

    return await repository.createTask(task);
  }
}
