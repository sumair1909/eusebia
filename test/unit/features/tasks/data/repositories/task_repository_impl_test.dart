import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:eusebia_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:eusebia_app/features/tasks/data/models/task_model.dart';
import 'package:eusebia_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';

// Simple mocks for testing
class MockTaskLocalDataSource implements TaskLocalDataSource {
  @override
  Future<List<TaskModel>> getAllTasks() async {
    throw UnimplementedError();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> clearAllTasks() async {
    throw UnimplementedError();
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    throw UnimplementedError();
  }
}

class MockTaskRemoteDataSource implements TaskRemoteDataSource {
  @override
  Future<List<TaskModel>> getAllTasks() async {
    throw UnimplementedError();
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    throw UnimplementedError();
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteTask(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  group('TaskRepositoryImpl', () {
    test('should create TaskRepositoryImpl instance', () {
      final mockLocalDataSource = MockTaskLocalDataSource();
      final mockRemoteDataSource = MockTaskRemoteDataSource();

      expect(
        () => TaskRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
        ),
        returnsNormally,
      );
    });

    test('should have correct dependencies', () {
      final mockLocalDataSource = MockTaskLocalDataSource();
      final mockRemoteDataSource = MockTaskRemoteDataSource();

      final repository = TaskRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
      );

      expect(repository, isA<TaskRepositoryImpl>());
    });
  });

  group('TaskModel', () {
    test('should create TaskModel with all fields', () {
      final taskModel = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        createdAt: DateTime(2024, 1, 15),
        dueDate: DateTime(2024, 1, 20),
        tags: ['work'],
      );

      expect(taskModel.id, '1');
      expect(taskModel.title, 'Test Task');
      expect(taskModel.description, 'Test Description');
      expect(taskModel.status, TaskStatus.pending);
      expect(taskModel.priority, TaskPriority.medium);
      expect(taskModel.createdAt, DateTime(2024, 1, 15));
      expect(taskModel.dueDate, DateTime(2024, 1, 20));
      expect(taskModel.tags, ['work']);
    });

    test('should convert to entity correctly', () {
      final taskModel = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        createdAt: DateTime(2024, 1, 15),
        dueDate: DateTime(2024, 1, 20),
        tags: ['work'],
      );

      final entity = taskModel.toEntity();

      expect(entity.id, taskModel.id);
      expect(entity.title, taskModel.title);
      expect(entity.description, taskModel.description);
      expect(entity.status, taskModel.status);
      expect(entity.priority, taskModel.priority);
      expect(entity.createdAt, taskModel.createdAt);
      expect(entity.dueDate, taskModel.dueDate);
      expect(entity.tags, taskModel.tags);
    });

    test('should create from entity correctly', () {
      final entity = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        createdAt: DateTime(2024, 1, 15),
        dueDate: DateTime(2024, 1, 20),
        tags: ['work'],
      );

      final taskModel = TaskModel.fromEntity(entity);

      expect(taskModel.id, entity.id);
      expect(taskModel.title, entity.title);
      expect(taskModel.description, entity.description);
      expect(taskModel.status, entity.status);
      expect(taskModel.priority, entity.priority);
      expect(taskModel.createdAt, entity.createdAt);
      expect(taskModel.dueDate, entity.dueDate);
      expect(taskModel.tags, entity.tags);
    });
  });
}
