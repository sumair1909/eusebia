import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/core/error/failures.dart';
import 'package:eusebia_app/core/usecases/usecase.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:eusebia_app/features/tasks/domain/usecases/create_task.dart';

// Simple mock for testing
class MockTaskRepository implements TaskRepository {
  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> deleteTask(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(
    TaskStatus status,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPriority(
    TaskPriority priority,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksDueToday() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByTags(List<String> tags) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<String>>> getAllLabels() {
    // TODO: implement getAllLabels
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> syncWithRemote() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksToSync() async {
    throw UnimplementedError();
  }
}

void main() {
  group('CreateTask Use Case', () {
    test('should create CreateTask use case', () {
      final mockRepository = MockTaskRepository();
      expect(() => CreateTask(mockRepository), returnsNormally);
    });

    test('should have correct type parameters', () {
      final mockRepository = MockTaskRepository();
      final useCase = CreateTask(mockRepository);
      expect(useCase, isA<UseCase<Task, CreateTaskParams>>());
    });
  });

  group('CreateTaskParams', () {
    test('should create CreateTaskParams with required fields', () {
      const params = CreateTaskParams(title: 'Test Task');
      expect(params.title, 'Test Task');
      expect(params.description, null);
      expect(params.priority, TaskPriority.medium);
      expect(params.dueDate, null);
      expect(params.tags, isEmpty);
    });

    test('should create CreateTaskParams with all fields', () {
      final dueDate = DateTime(2024, 1, 20);
      final params = CreateTaskParams(
        title: 'Test Task',
        description: 'Test Description',
        priority: TaskPriority.high,
        dueDate: dueDate,
        tags: ['work', 'important'],
      );

      expect(params.title, 'Test Task');
      expect(params.description, 'Test Description');
      expect(params.priority, TaskPriority.high);
      expect(params.dueDate, dueDate);
      expect(params.tags, ['work', 'important']);
    });

    test('should handle different priorities', () {
      const lowPriority = CreateTaskParams(
        title: 'Low Priority Task',
        priority: TaskPriority.low,
      );
      const highPriority = CreateTaskParams(
        title: 'High Priority Task',
        priority: TaskPriority.high,
      );

      expect(lowPriority.priority, TaskPriority.low);
      expect(highPriority.priority, TaskPriority.high);
    });
  });
}
