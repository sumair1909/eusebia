import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/core/error/failures.dart';
import 'package:eusebia_app/core/usecases/usecase.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:eusebia_app/features/tasks/domain/usecases/get_all_tasks.dart';

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
}

void main() {
  group('GetAllTasks Use Case', () {
    test('should create GetAllTasks use case', () {
      // This test verifies that the GetAllTasks class can be instantiated
      final mockRepository = MockTaskRepository();
      expect(() => GetAllTasks(mockRepository), returnsNormally);
    });

    test('should have correct type parameters', () {
      // This test verifies the use case has the correct type signature
      final mockRepository = MockTaskRepository();
      final useCase = GetAllTasks(mockRepository);
      expect(useCase, isA<UseCase<List<Task>, NoParams>>());
    });
  });

  group('NoParams', () {
    test('should create NoParams instance', () {
      const params = NoParams();
      expect(params, isA<NoParams>());
    });

    test('should be equal to other NoParams instances', () {
      const params1 = NoParams();
      const params2 = NoParams();
      expect(params1, equals(params2));
    });
  });
}
