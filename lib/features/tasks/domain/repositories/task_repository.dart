import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../entities/task.dart';

/// Repository interface for task operations in the domain layer
/// This defines the contract that the domain expects from data sources
abstract class TaskRepository {
  /// Get all tasks
  Future<Either<Failure, List<Task>>> getAllTasks();

  /// Get task by id
  Future<Either<Failure, Task>> getTaskById(String id);

  /// Create new task
  Future<Either<Failure, Task>> createTask(Task task);

  /// Update existing task
  Future<Either<Failure, Task>> updateTask(Task task);

  /// Delete task by id
  Future<Either<Failure, bool>> deleteTask(String id);

  /// Get tasks by status
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status);

  /// Get tasks by priority
  Future<Either<Failure, List<Task>>> getTasksByPriority(TaskPriority priority);

  /// Get overdue tasks
  Future<Either<Failure, List<Task>>> getOverdueTasks();

  /// Get tasks due today
  Future<Either<Failure, List<Task>>> getTasksDueToday();

  /// Get tasks by tags
  Future<Either<Failure, List<Task>>> getTasksByTags(List<String> tags);

  /// Get all unique labels from existing tasks
  Future<Either<Failure, List<String>>> getAllLabels();
}
